namespace :import do
  desc 'Import distribution tags from csv file (usage: rake import:distribution_tags[path/to/file,path/to/another])'
  task :distribution_tags, 10.times.map { |i| :"file_#{i}" } => [ :environment ] do |t, args|
    TMP_TABLE = 'distribution_tags_import'
    import_helper = CsvImportHelper.new

    files = import_helper.files_from_args(t, args)

    def recheck_rolling_counts(prev_counts = nil)
      new_counts = {
        'taggings' => ApplicationRecord.connection.execute(
          'SELECT COUNT(*) FROM taggings'
        ).first['count'].to_i,
        'distribution taggings' => ApplicationRecord.connection.execute(
          "SELECT COUNT(*) FROM taggings where taggable_type = 'Distribution'"
        ).first['count'].to_i,
        'tag types' => ApplicationRecord.connection.execute(
          'SELECT COUNT(*) FROM tags'
        ).first['count'].to_i,
        'preset distributon tag types' => PresetTag.where(model: 'Distribution').count
      }

      new_counts.entries.each do |count_type, new_count|
        delta = prev_counts && (new_count - prev_counts[count_type])
        delta = "+#{delta}" if delta && delta > 0
        delta = delta && " (#{delta})"

        puts "There are #{new_count} #{count_type} in the database#{delta}"
      end

      new_counts
    end

    ApplicationRecord.transaction do
      files.each do |file|
        import_helper.drop_table(TMP_TABLE)
        import_helper.create_table_from_csv_headers(file, TMP_TABLE)
        import_helper.copy_data(file, TMP_TABLE)

        rolling_counts = recheck_rolling_counts
        csv_headers = import_helper.csv_headers(file)
        has_legacy = csv_headers.include? 'Species RecID'
        id_type = has_legacy ? 'legacy_id' : 'taxon_concept_id'
        tc_id = has_legacy ? 'legacy_id' : 'id'
        kingdom = file.split('/').last.split('_')[0].titleize

        # import all distinct tags to both PresetTags and Tags table
        puts 'ADDING: preset_tags and tags'

        sql = <<-SQL.squish
          INSERT INTO preset_tags(model, name, created_at, updated_at)
          SELECT subquery.*, NOW(), NOW()
          FROM (
            SELECT DISTINCT 'Distribution', BTRIM(tmp.tag)
            FROM #{TMP_TABLE}, (
              SELECT DISTINCT regexp_split_to_table(
                #{TMP_TABLE}.tags, E','
              ) AS tag
                FROM #{TMP_TABLE}
            ) AS tmp
            EXCEPT

            SELECT model, preset_tags.name
            FROM preset_tags WHERE model = 'Distribution'
          ) AS subquery;

          INSERT INTO tags(name)
          SELECT name FROM preset_tags

          EXCEPT

          SELECT name FROM tags;
        SQL

        ApplicationRecord.connection.execute(sql)

        recheck_rolling_counts rolling_counts

        [ Taxonomy::CITES_EU, Taxonomy::CMS ].each do |taxonomy_name|
          puts "Import #{taxonomy_name} distribution tags"

          taxonomy = Taxonomy.find_by(name: taxonomy_name)

          sql = <<-SQL.squish
            WITH tmp AS (
              SELECT DISTINCT
                #{id_type}, rank, geo_entity_type, iso_code2,
                regexp_split_to_table(#{TMP_TABLE}.tags, E',') AS tag
              FROM #{TMP_TABLE}
              WHERE
                #{
                  if taxonomy_name == Taxonomy::CITES_EU
                    "( UPPER(BTRIM(#{TMP_TABLE}.designation)) like '%CITES%' OR UPPER(BTRIM(#{TMP_TABLE}.designation)) like '%EU%')"
                  else
                    "UPPER(BTRIM(#{TMP_TABLE}.designation)) like '%CMS%'"
                  end
                }
            )
            INSERT INTO taggings(tag_id, taggable_id, taggable_type, context, created_at)
            SELECT subquery.*, NOW()
            FROM (
              SELECT tags.id, distributions.id, 'Distribution', 'tags'
              FROM tmp
              INNER JOIN ranks ON UPPER(ranks.name) = UPPER(BTRIM(tmp.rank))
              INNER JOIN geo_entity_types ON UPPER(geo_entity_types.name) = UPPER(BTRIM(tmp.geo_entity_type))
              INNER JOIN taxon_concepts ON taxon_concepts.#{tc_id} = tmp.#{id_type} AND
                #{has_legacy ? "taxon_concepts.legacy_type = '#{kingdom}' AND" : ''} taxon_concepts.rank_id = ranks.id
              INNER JOIN geo_entities ON UPPER(geo_entities.iso_code2) = UPPER(BTRIM(tmp.iso_code2)) AND
                geo_entities.geo_entity_type_id = geo_entity_types.id
              INNER JOIN distributions ON distributions.geo_entity_id = geo_entities.id AND
                distributions.taxon_concept_id = taxon_concepts.id
              INNER JOIN tags ON UPPER(tags.name) = UPPER(BTRIM(tmp.tag))
              INNER JOIN taxonomies ON taxonomies.id = taxon_concepts.taxonomy_id
              WHERE taxonomies.id = #{taxonomy.id}

              EXCEPT

              SELECT tag_id, taggable_id, taggable_type, context
              FROM taggings
              WHERE taggable_type = 'Distribution' AND context = 'tags'

            ) AS subquery;
          SQL

          ApplicationRecord.connection.execute(sql)

          puts 'ADDING: distribution taggings'

          import_helper.assert_no_rows(
            (
              <<-SQL.squish
                SELECT tmp.* FROM (
                  SELECT *, regexp_split_to_table(
                    #{TMP_TABLE}.tags, E','
                  ) AS tag
                  FROM #{TMP_TABLE}
                ) tmp
                LEFT JOIN taxon_concepts tc ON tc.id = tmp.taxon_concept_id
                LEFT JOIN geo_entities ge ON ge.iso_code2 = tmp.iso_code2
                LEFT JOIN distributions d
                  ON d.taxon_concept_id = tmp.taxon_concept_id
                  AND d.geo_entity_id = ge.id
                LEFT JOIN (
                  SELECT taggings.*, tags.name
                  FROM taggings, tags
                  WHERE taggings.tag_id = tags.id
                    AND taggings.taggable_type = 'Distribution'
                ) t
                  ON UPPER(t.name) = UPPER(BTRIM(tmp.tag))
                  AND d.id = t.taggable_id
                WHERE t.id IS NULL
              SQL
            ),
            'missing distribution tags'
          )

          ApplicationRecord.connection.execute(
            <<-SQL.squish
              UPDATE taxon_concepts tc
              SET dependents_updated_at = NOW(),
                dependents_updated_by_id = NULL
              WHERE id IN (
                SELECT taxon_concept_id FROM #{TMP_TABLE} tmp
                WHERE tags IS NOT NULL
              )
            SQL
          )
        end

        rolling_counts = recheck_rolling_counts rolling_counts
      end

      import_helper.rollback_if_dry_run

      puts 'Committing'
    end
  end
end
