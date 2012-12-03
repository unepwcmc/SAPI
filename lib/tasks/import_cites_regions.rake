namespace :import do

  desc "Import CITES Regions records from csv file (usage: rake import:cites_regions[path/to/file,path/to/another])"
  task :cites_regions, 10.times.map { |i| "file_#{i}".to_sym } => [:environment] do |t, args|
    tmp_table = 'cites_regions_import'
    regions_type = GeoEntityType.find_by_name(GeoEntityType::CITES_REGION)
    puts "There are #{GeoEntity.count(conditions: {geo_entity_type_id: regions_type.id})} CITES Regions in the database."
    files = files_from_args(t, args)
    files.each do |file|
      drop_table(tmp_table)
      create_table_from_csv_headers(file, tmp_table)
      copy_data(file, tmp_table)
      sql = <<-SQL
        INSERT INTO geo_entities(name, geo_entity_type_id, created_at, updated_at)
        SELECT DISTINCT BTRIM(TMP.name), #{regions_type.id}, current_date, current_date
        FROM #{tmp_table} AS TMP
        WHERE NOT EXISTS (
          SELECT * FROM geo_entities
          WHERE INITCAP(BTRIM(name)) = INITCAP(BTRIM(TMP.name)) AND geo_entity_type_id = #{regions_type.id}
        );
      SQL
      ActiveRecord::Base.connection.execute(sql)
    end
    puts "There are now #{GeoEntity.count(conditions: {geo_entity_type_id: regions_type.id})} CITES Regions in the database"
  end

end
