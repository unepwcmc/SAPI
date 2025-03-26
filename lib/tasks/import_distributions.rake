namespace :import do
  desc 'Import distributions from csv file (usage: rake import:distributions[path/to/file,path/to/another])'
  task :distributions, 10.times.map { |i| :"file_#{i}" } => [ :environment ] do |t, args|
    ApplicationRecord.transaction do
      import_helper = CsvImportHelper.new

      TMP_TABLE = 'distribution_import'

      def recheck_rolling_counts(prev_counts = nil)
        new_counts = {
          'taxon concept distributions' => Distribution.count,
          'distribution references' => DistributionReference.count
        }

        new_counts.entries.each do |count_type, new_count|
          delta = prev_counts && (new_count - prev_counts[count_type])
          delta = "+#{delta}" if delta && delta > 0
          delta = delta && " (#{delta})"

          puts "There are #{new_count} #{count_type} in the database#{delta}"
        end

        new_counts
      end

      rolling_counts = recheck_rolling_counts

      files = import_helper.files_from_args(t, args)

      files.each do |file|
        puts "Importing distributions from #{file}"

        import_helper.drop_table(TMP_TABLE)
        import_helper.create_table_from_csv_headers(file, TMP_TABLE)
        import_helper.copy_data(file, TMP_TABLE)
        puts "There are #{Distribution.from(TMP_TABLE).count} rows in the CSV"


        csv_headers = import_helper.csv_headers(file)
        has_tc_id = csv_headers.include? 'taxon_concept_id'
        has_reference = csv_headers.include? 'Reference'
        has_reference_id = csv_headers.include? 'Reference IDs'
        kingdom = has_tc_id ? '' : file.split('/').last.split('_')[0].titleize

        [ Taxonomy::CITES_EU, Taxonomy::CMS ].each do |taxonomy_name|
          puts "Importing #{taxonomy_name} distributions"

          taxonomy = Taxonomy.find_by(name: taxonomy_name)

          sql = <<-SQL.squish
            INSERT INTO distributions(taxon_concept_id, geo_entity_id, created_at, updated_at)
            SELECT subquery.*, NOW(), NOW()
            FROM (
              SELECT DISTINCT taxon_concepts.id, geo_entities.id
              FROM #{TMP_TABLE}
              INNER JOIN ranks ON UPPER(ranks.name) = UPPER(BTRIM(#{TMP_TABLE}.rank))
              INNER JOIN geo_entities ON geo_entities.iso_code2 = #{TMP_TABLE}.iso2 AND UPPER(geo_entities.legacy_type) = UPPER(BTRIM(geo_entity_type))
              #{if has_tc_id
                  "INNER JOIN taxon_concepts ON taxon_concepts.id = #{TMP_TABLE}.taxon_concept_id"
                else
                  "INNER JOIN taxon_concepts ON taxon_concepts.legacy_id = #{TMP_TABLE}.legacy_id AND taxon_concepts.legacy_type = '#{kingdom}'"
                end}
              AND taxon_concepts.rank_id = ranks.id
              INNER JOIN taxonomies ON taxonomies.id = taxon_concepts.taxonomy_id
              WHERE taxon_concepts.id IS NOT NULL AND geo_entities.id IS NOT NULL
                AND
                  #{if taxonomy_name == Taxonomy::CITES_EU
                      "( UPPER(BTRIM(#{TMP_TABLE}.designation)) like '%CITES%' OR UPPER(BTRIM(#{TMP_TABLE}.designation)) like '%EU%')"
                    else
                      "UPPER(BTRIM(#{TMP_TABLE}.designation)) like '%CMS%'"
                    end}
                AND taxonomies.id = #{taxonomy.id}

                EXCEPT

                SELECT taxon_concept_id, geo_entity_id FROM distributions

              ) AS subquery
            SQL

          # TODO: do sth about those unknown distributions!
          ApplicationRecord.connection.execute(sql)

          puts "Imported #{taxonomy_name} distributions"
        end

        ApplicationRecord.connection.execute(
          <<-SQL.squish
            UPDATE taxon_concepts tc
            SET dependents_updated_at = NOW(),
              dependents_updated_by_id = NULL
            WHERE id IN (SELECT taxon_concept_id FROM #{TMP_TABLE} tmp)
          SQL
        ) if has_tc_id

        import_helper.assert_no_rows(
          (
            <<-SQL.squish
              SELECT FROM #{TMP_TABLE} tmp
              LEFT JOIN taxon_concepts tc ON tc.id = tmp.taxon_concept_id
              WHERE tc.id IS NULL
            SQL
          ),
          'unidentified taxon concepts'
        ) if has_tc_id

        if has_reference_id

          sql = <<-SQL.squish
            INSERT INTO "distribution_references"
              (distribution_id, reference_id, created_at, updated_at)
            SELECT subquery.*, NOW(), NOW()
            FROM(
              SELECT d.id, tmp.reference_id
              FROM #{TMP_TABLE} tmp
              INNER JOIN geo_entities ge ON ge.iso_code2 = tmp.iso2
              INNER JOIN distributions d ON d.taxon_concept_id = tmp.taxon_concept_id
              AND d.geo_entity_id = ge.id
              AND tmp.reference_id IS NOT NULL

              EXCEPT

              SELECT distribution_id, reference_id FROM distribution_references
            ) AS subquery
          SQL

          ApplicationRecord.connection.execute(sql)

          # `DistributionReference` has `belongs_to :distribution, touch: true`;
          # because we're skipping the Rails layer we must do this manually.
          ApplicationRecord.connection.execute(
            <<-SQL.squish
              UPDATE "distributions"
              SET updated_at = dr.updated_at, updated_by_id = dr.updated_by_id
              FROM (
                SELECT DISTINCT ON (distribution_id) distribution_id, updated_at, updated_by_id
                FROM distribution_references dr
                ORDER BY distribution_id, updated_at DESC
              ) dr
              WHERE "distributions".id = dr.distribution_id
                AND "distributions".updated_at < dr.updated_at;
            SQL
          )
        end

        import_helper.assert_no_rows(
          (
            <<-SQL.squish
              SELECT tmp.* FROM #{TMP_TABLE} tmp
              LEFT JOIN taxon_concepts tc ON tc.id = tmp.taxon_concept_id
              LEFT JOIN geo_entities ge ON ge.iso_code2 = tmp.iso2
              LEFT JOIN distributions d
                ON d.taxon_concept_id = tmp.taxon_concept_id
                AND d.geo_entity_id = ge.id
              WHERE d.id IS NULL
            SQL
          ),
          'missing taxon concepts distributions'
        ) if has_tc_id

        import_helper.assert_no_rows(
          (
            <<-SQL.squish
              SELECT tmp.* FROM #{TMP_TABLE} tmp
              LEFT JOIN taxon_concepts tc ON tc.id = tmp.taxon_concept_id
              LEFT JOIN geo_entities ge ON ge.iso_code2 = tmp.iso2
              LEFT JOIN distributions d
                ON d.taxon_concept_id = tmp.taxon_concept_id
                AND d.geo_entity_id = ge.id
              LEFT JOIN distribution_references dr
                ON dr.distribution_id = d.id
                AND dr.reference_id = tmp.reference_id
              WHERE tmp.reference_id IS NOT NULL
                AND dr.id IS NULL
            SQL
          ),
          'taxon concept distributions without references'
        ) if has_tc_id && has_reference_id

        if has_reference
          sql = <<-SQL.squish
            INSERT INTO "references"
              (citation, created_at, updated_at)
            SELECT subquery.*, NOW(), NOW()
            FROM(
              SELECT tmp.citation
              FROM #{TMP_TABLE} tmp
              WHERE tmp.citation IS NOT NULL

              EXCEPT

              SELECT r.citation
              FROM "references" r
            ) AS subquery
          SQL

          ApplicationRecord.connection.execute(sql)

          distribution_references = DistributionReference.count

          sql = <<-SQL.squish
            INSERT INTO "distribution_references"
              (distribution_id, reference_id, created_at, updated_at)
            SELECT subquery.*, NOW(), NOW()
            FROM(
              SELECT d.id, r.id
              FROM #{TMP_TABLE} tmp
              INNER JOIN "references" r ON r.citation = tmp.citation
              INNER JOIN geo_entities ge ON ge.iso_code2 = tmp.iso2
              INNER JOIN distributions d ON d.taxon_concept_id = tmp.taxon_concept_id
              AND d.geo_entity_id = ge.id

              EXCEPT

              SELECT distribution_id, reference_id FROM distribution_references
            ) AS subquery
          SQL

          ApplicationRecord.connection.execute(sql)


          puts "Extra #{DistributionReference.count - distribution_references} distribution references have been added to the database"
        end

        rolling_counts = recheck_rolling_counts rolling_counts
      end

      import_helper.rollback_if_dry_run

      puts 'Committing'
    end
  end
end
