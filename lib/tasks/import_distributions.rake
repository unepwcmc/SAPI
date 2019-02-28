namespace :import do

  desc 'Import distributions from csv file (usage: rake import:distributions[path/to/file,path/to/another])'
  task :distributions, 10.times.map { |i| "file_#{i}".to_sym } => [:environment] do |t, args|
    TMP_TABLE = 'distribution_import'
    puts "There are #{Distribution.count} taxon concept distributions in the database."
    files = files_from_args(t, args)
    files.each do |file|
      drop_table(TMP_TABLE)
      create_table_from_csv_headers(file, TMP_TABLE)
      copy_data(file, TMP_TABLE)

      csv_headers = csv_headers(file)
      has_tc_id = csv_headers.include? 'taxon_concept_id'
      has_reference = csv_headers.include? 'Reference'
      has_reference_id = csv_headers.include? 'Reference IDs'
      kingdom = has_tc_id ? '' : file.split('/').last.split('_')[0].titleize

      [Taxonomy::CITES_EU, Taxonomy::CMS].each do |taxonomy_name|
        puts "Import #{taxonomy_name} distributions"
        taxonomy = Taxonomy.find_by_name(taxonomy_name)
        sql = <<-SQL
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
        ActiveRecord::Base.connection.execute(sql)
      end
      if has_reference_id
        puts "There are #{DistributionReference.count} distribution references in the database."
        sql = <<-SQL
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
        ActiveRecord::Base.connection.execute(sql)
      end
      if has_reference
        puts "There are #{Reference.count} references in the database."
        sql = <<-SQL
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
        ActiveRecord::Base.connection.execute(sql)
        puts "There are now #{Reference.count} references in the database"

        distribution_references = DistributionReference.count
        sql = <<-SQL
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
        ActiveRecord::Base.connection.execute(sql)
        puts "Extra #{DistributionReference.count - distribution_references} distribution references have been added to the database"
      end
    end
    puts "There are now #{Distribution.count} taxon concept distributions in the database"
    puts "There are now #{DistributionReference.count} distribution references in the database"
  end

end
