namespace :import do

  desc 'Import distributions from csv file [usage: rake import:distributions[path/to/file,path/to/another]'
  task :distributions, 10.times.map { |i| "file_#{i}".to_sym } => [:environment] do |t, args|
    TMP_TABLE = 'distribution_import'
    puts "There are #{TaxonConceptGeoEntity.count} taxon concept distributions in the database."
    files = files_from_args(t, args)
    files.each do |file|
      drop_table(TMP_TABLE)
      create_table_from_csv_headers(file, TMP_TABLE)
      copy_data(file, TMP_TABLE)

      sql = <<-SQL
        INSERT INTO taxon_concept_geo_entities(taxon_concept_id, geo_entity_id, created_at, updated_at)
        SELECT DISTINCT species.id, geo_entities.id, current_date, current_date
          FROM #{TMP_TABLE}
          LEFT JOIN geo_entities ON geo_entities.legacy_id = country_id AND geo_entities.legacy_type = '#{GeoEntityType::COUNTRY}'
          LEFT JOIN taxon_concepts as species ON species.legacy_id = species_id
          WHERE Species.id IS NOT NULL AND geo_entities.id IS NOT NULL
      SQL
      #TODO do sth about those unknown distributions!
      ActiveRecord::Base.connection.execute(sql)
    end
    puts "There are now #{TaxonConceptGeoEntity.count} taxon concept distributions in the database"
  end

end

