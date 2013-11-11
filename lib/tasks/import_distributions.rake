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

      kingdom = file.split('/').last.split('_')[0].titleize

      [Taxonomy::CITES_EU, Taxonomy::CMS].each do |taxonomy_name|
        puts "Import #{taxonomy_name} common names"
        taxonomy = Taxonomy.find_by_name(taxonomy_name)
        sql = <<-SQL
        INSERT INTO distributions(taxon_concept_id, geo_entity_id, created_at, updated_at)
        SELECT subquery.*, NOW(), NOW()
        FROM (
          SELECT DISTINCT taxon_concepts.id, geo_entities.id
          FROM #{TMP_TABLE}
          INNER JOIN ranks ON UPPER(ranks.name) = UPPER(BTRIM(#{TMP_TABLE}.rank))
          INNER JOIN geo_entities ON geo_entities.iso_code2 = #{TMP_TABLE}.iso2 AND UPPER(geo_entities.legacy_type) = UPPER(BTRIM(geo_entity_type))
          INNER JOIN taxon_concepts ON taxon_concepts.legacy_id = #{TMP_TABLE}.legacy_id AND taxon_concepts.legacy_type = '#{kingdom}' AND
           taxon_concepts.rank_id = ranks.id
          INNER JOIN taxonomies ON taxonomies.id = taxon_concepts.taxonomy_id
          WHERE taxon_concepts.id IS NOT NULL AND geo_entities.id IS NOT NULL
            AND
               #{ if taxonomy_name == Taxonomy::CITES_EU
                    "( UPPER(BTRIM(#{TMP_TABLE}.designation)) like '%CITES%' OR UPPER(BTRIM(#{TMP_TABLE}.designation)) like '%EU%')"
                  else
                    "UPPER(BTRIM(#{TMP_TABLE}.designation)) like '%CMS%'"
                  end}
            AND taxonomies.id = #{taxonomy.id}

            EXCEPT

            SELECT taxon_concept_id, geo_entity_id FROM distributions

          ) AS subquery
          SQL
          #TODO do sth about those unknown distributions!
          ActiveRecord::Base.connection.execute(sql)
      end
    end
    puts "There are now #{Distribution.count} taxon concept distributions in the database"
  end

end

