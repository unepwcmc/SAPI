namespace :import do

  desc 'Import distribution tags from csv file (usage: rake import:distribution_tags[path/to/file,path/to/another])'
  task :distribution_tags, 10.times.map { |i| "file_#{i}".to_sym } => [:environment] do |t, args|
    TMP_TABLE = 'distribution_tags_import'
    files = files_from_args(t, args)
    files.each do |file|
      drop_table(TMP_TABLE)
      create_table_from_csv_headers(file, TMP_TABLE)
      copy_data(file, TMP_TABLE)

      csv_headers = csv_headers(file)
      has_legacy = csv_headers.include? 'Species RecID'
      id_type = has_legacy ? 'legacy_id' : 'taxon_concept_id'
      tc_id = has_legacy ? 'legacy_id' : 'id'
      kingdom = file.split('/').last.split('_')[0].titleize

      # import all distinct tags to both PresetTags and Tags table
      puts "There are #{PresetTag.where(:model => 'Distribution').count} distribution tags"
      puts "There are #{ActiveRecord::Base.connection.execute('SELECT COUNT(*) FROM tags').first["count"]} tags in the tags table"
      puts "ADDING: preset_tags and tags"
      sql = <<-SQL
        INSERT INTO preset_tags(model, name, created_at, updated_at)
        SELECT subquery.*, NOW(), NOW()
        FROM (
          SELECT DISTINCT 'Distribution', BTRIM(tmp.tag)
          FROM #{TMP_TABLE}, (
            SELECT DISTINCT regexp_split_to_table(#{TMP_TABLE}.tags, E',') AS tag
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
      ActiveRecord::Base.connection.execute(sql)
      puts "There are now #{PresetTag.where(:model => 'Distribution').count} distribution tags"
      puts "There are now #{ActiveRecord::Base.connection.execute('SELECT COUNT(*) FROM tags').first["count"]} tags in the tags table"

      puts "There are #{ActiveRecord::Base.connection.execute('SELECT COUNT(*) FROM taggings').first["count"]} distribution tags"
      [Taxonomy::CITES_EU, Taxonomy::CMS].each do |taxonomy_name|
        puts "Import #{taxonomy_name} distribution tags"
        taxonomy = Taxonomy.find_by_name(taxonomy_name)
        sql = <<-SQL
          WITH tmp AS (
            SELECT DISTINCT #{id_type}, rank, geo_entity_type, iso_code2, regexp_split_to_table(#{TMP_TABLE}.tags, E',') AS tag
            FROM #{TMP_TABLE}
            WHERE
              #{if taxonomy_name == Taxonomy::CITES_EU
                  "( UPPER(BTRIM(#{TMP_TABLE}.designation)) like '%CITES%' OR UPPER(BTRIM(#{TMP_TABLE}.designation)) like '%EU%')"
                else
                  "UPPER(BTRIM(#{TMP_TABLE}.designation)) like '%CMS%'"
                end}
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
        puts "ADDING: distribution taggings"
        ActiveRecord::Base.connection.execute(sql)
      end
      puts "There are now #{ActiveRecord::Base.connection.execute('SELECT COUNT(*) FROM taggings').first["count"]} distribution tags"
    end
  end

end
