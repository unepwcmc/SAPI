namespace :import do

  desc "Import CITES Regions records from csv file (usage: rake import:cites_regions[path/to/file,path/to/another])"
  task :cites_regions, 10.times.map { |i| "file_#{i}".to_sym } => [:environment] do |t, args|
    tmp_table = 'cites_regions_import'
    regions_type = GeoEntityType.find_by_name(GeoEntityType::CITES_REGION)
    puts "There are #{GeoEntity.count(conditions: { geo_entity_type_id: regions_type.id })} CITES Regions in the database."
    files = files_from_args(t, args)
    files.each do |file|
      drop_table(tmp_table)
      create_table_from_csv_headers(file, tmp_table)
      copy_data(file, tmp_table)
      sql = <<-SQL
        INSERT INTO geo_entities(name_en, geo_entity_type_id, created_at, updated_at)
        SELECT DISTINCT BTRIM(TMP.name), #{regions_type.id}, current_date, current_date
        FROM #{tmp_table} AS TMP
        WHERE NOT EXISTS (
          SELECT * FROM geo_entities
          WHERE UPPER(BTRIM(name)) = UPPER(BTRIM(TMP.name)) AND geo_entity_type_id = #{regions_type.id}
        );
      SQL
      ActiveRecord::Base.connection.execute(sql)
    end
    puts "There are now #{GeoEntity.count(conditions: { geo_entity_type_id: regions_type.id })} CITES Regions in the database"
  end

  task :cites_regions_translations => :environment do
    TMP_TABLE = "cites_regions_import"
    file = "lib/files/cites_regions_utf8.csv"
    drop_table(TMP_TABLE)
    create_table_from_csv_headers(file, TMP_TABLE)
    copy_data(file, TMP_TABLE)
    regions_type = GeoEntityType.find_by_name(GeoEntityType::CITES_REGION)
    sql = <<-SQL
      UPDATE geo_entities
      SET name_fr = t.name_fr, name_es = t.name_es
      FROM #{TMP_TABLE} t, geo_entity_types
      WHERE UPPER(BTRIM(t.name)) = UPPER(BTRIM(geo_entities.name_en))
      AND geo_entities.geo_entity_type_id = #{regions_type.id}
    SQL
    ActiveRecord::Base.connection.execute(sql)
  end

end
