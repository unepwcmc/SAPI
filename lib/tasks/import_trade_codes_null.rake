namespace :import do
  desc "Import trade codes for null values"

  task :trade_codes_null => [:environment] do
  sql = <<-SQL
  INSERT INTO trade_codes(id, code, type, name_en, created_at, updated_at) VALUES
  	(9991, ' ', 'Unit', ' ', NOW(), NOW()),
  	(9992, ' ', 'Source', ' ', NOW(), NOW()),
  	(9993, ' ', 'Purpose', ' ', NOW(), NOW());
  INSERT INTO geo_entities(id, geo_entity_type_id, name_en, long_name, iso_code2, created_at, updated_at) VALUES
    (9991, 1, ' ', ' ', ' ', NOW(), NOW())
  	SQL

  ActiveRecord::Base.connection.execute(sql)

  end
end
