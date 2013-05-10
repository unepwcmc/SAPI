module CsvCopy
  def self.copy_data(path_to_file, table_name, db_columns)
    puts "Copying data from #{path_to_file} into tmp table #{table_name}"
    cmd = <<-PSQL
  SET DateStyle = \"ISO,DMY\";
  \\COPY #{table_name} (#{db_columns.join(', ')})
  FROM '#{Rails.root + path_to_file}'
  WITH DELIMITER ','
  ENCODING 'utf-8'
  CSV HEADER
  PSQL

    db_conf = YAML.load(File.open(Rails.root + "config/database.yml"))[Rails.env]
    system("export PGPASSWORD=#{db_conf["password"]} && "+
      "echo \"#{cmd.split("\n").join(' ')}\" | psql -h #{db_conf["host"] || "localhost"} -p #{db_conf["port"] || 5432} -U#{db_conf["username"]} #{db_conf["database"]}")
    puts "Data copied to tmp table"
  end
end
