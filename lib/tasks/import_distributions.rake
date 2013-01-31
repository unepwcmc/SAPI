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

      sql = <<-SQL
        INSERT INTO distributions(taxon_concept_id, geo_entity_id, created_at, updated_at)
        SELECT DISTINCT taxon_concepts.id, geo_entities.id, current_date, current_date
          FROM #{TMP_TABLE}
          LEFT JOIN geo_entities ON geo_entities.legacy_id = #{TMP_TABLE}.country_legacy_id AND geo_entities.legacy_type = '#{GeoEntityType::COUNTRY}'
          LEFT JOIN taxon_concepts ON taxon_concepts.legacy_id = #{TMP_TABLE}.legacy_id AND taxon_concepts.legacy_type = 'Animalia'
          LEFT JOIN ranks ON UPPER(ranks.name) = UPPER(BTRIM(#{TMP_TABLE}.rank)) AND taxon_concepts.rank_id = ranks.id
          WHERE taxon_concepts.id IS NOT NULL AND geo_entities.id IS NOT NULL AND geo_entities.is_current = 't'
          AND BTRIM(#{TMP_TABLE}.designation) ilike '%CITES%'
      SQL
      #TODO do sth about those unknown distributions!
      ActiveRecord::Base.connection.execute(sql)
    end
    puts "There are now #{Distribution.count} taxon concept distributions in the database"
  end

end

