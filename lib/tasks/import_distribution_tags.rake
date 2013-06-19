namespace :import do

  desc 'Import distribution tags from csv file (usage: rake import:distribution_tags[path/to/file,path/to/another])'
  task :distribution_tags, 10.times.map { |i| "file_#{i}".to_sym } => [:environment] do |t, args|
    TMP_TABLE = 'distribution_tags_import'
    files = files_from_args(t, args)
    files.each do |file|
      drop_table(TMP_TABLE)
      create_table_from_csv_headers(file, TMP_TABLE)
      copy_data(file, TMP_TABLE)

      kingdom = file.split('/').last.split('_')[0].titleize

      #import all distinct tags to both PresetTags and Tags table
      puts "There are #{PresetTag.where(:model => 'Distribution').count} distribution tags"
      puts "There are #{ActiveRecord::Base.connection.execute('SELECT COUNT(*) FROM tags').first["count"]} tags in the tags table"
      puts "ADDING: preset_tags and tags"
      sql = <<-SQL
        INSERT INTO preset_tags(model, created_at, updated_at, name)
        SELECT DISTINCT 'Distribution', current_date, current_date, BTRIM(tmp.tag)
        FROM #{TMP_TABLE}, (
          SELECT DISTINCT regexp_split_to_table(#{TMP_TABLE}.tags, E',') AS tag
            FROM #{TMP_TABLE}
            ) AS tmp
        WHERE NOT EXISTS (
          SELECT * FROM preset_tags
          WHERE preset_tags.name = BTRIM(tmp.tag) AND
          model = 'Distribution'
        );
        INSERT INTO tags(name)
        SELECT name FROM preset_tags
        WHERE NOT EXISTS(
          SELECT * FROM tags where tags.name = preset_tags.name
        );
      SQL
      ActiveRecord::Base.connection.execute(sql)
      puts "There are now #{PresetTag.where(:model => 'Distribution').count} distribution tags"
      puts "There are now #{ActiveRecord::Base.connection.execute('SELECT COUNT(*) FROM tags').first["count"]} tags in the tags table"

      puts "There are #{ActiveRecord::Base.connection.execute('SELECT COUNT(*) FROM taggings').first["count"]} distribution tags"
      sql = <<-SQL
        WITH tmp AS (
          SELECT DISTINCT legacy_id, rank, geo_entity_type, iso_code2, regexp_split_to_table(#{TMP_TABLE}.tags, E',') AS tag
          FROM #{TMP_TABLE}
          WHERE UPPER(designation) like '%EU%' OR UPPER(designation) like '%CITES%'
        )
        INSERT INTO taggings(tag_id, taggable_id, taggable_type, context, created_at)
        SELECT tags.id, distributions.id, 'Distribution', 'tags', current_date
        FROM tmp
        INNER JOIN ranks ON UPPER(ranks.name) = UPPER(BTRIM(tmp.rank))
        INNER JOIN geo_entity_types ON UPPER(geo_entity_types.name) = UPPER(BTRIM(tmp.geo_entity_type))
        INNER JOIN taxon_concepts ON taxon_concepts.legacy_id = tmp.legacy_id AND
          taxon_concepts.legacy_type = '#{kingdom}' AND taxon_concepts.rank_id = ranks.id
        INNER JOIN geo_entities ON UPPER(geo_entities.iso_code2) = UPPER(BTRIM(tmp.iso_code2)) AND
          geo_entities.geo_entity_type_id = geo_entity_types.id
        INNER JOIN distributions ON distributions.geo_entity_id = geo_entities.id AND
          distributions.taxon_concept_id = taxon_concepts.id
        INNER JOIN tags ON UPPER(tags.name) = UPPER(BTRIM(tmp.tag))
        WHERE NOT EXISTS (
          SELECT * from taggings
          WHERE taggings.tag_id = tags.id AND
            taggings.taggable_id = distributions.id AND
            taggings.taggable_type = 'Distribution' AND
            taggings.context = 'tags'
        )
      SQL
      puts "ADDING: distribution taggings"
      ActiveRecord::Base.connection.execute(sql)
      puts "There are now #{ActiveRecord::Base.connection.execute('SELECT COUNT(*) FROM taggings').first["count"]} distribution tags"
    end
  end

end


