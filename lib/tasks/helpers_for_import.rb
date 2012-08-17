require 'csv'
# connecting to SQL Server 2008
# TinyTds::Client.new(:username => 'sapi', :password => 'conserveworld', :host => 'wcmc-gis-01.unep-wcmc.org', :port => 1539, :database => 'Animals')

MAPPING = {
    'cites_regions_import' => {
      :create_tmp => "name varchar",
      :tmp_columns => ["name"]
  },
    'countries_import' => {
      :create_tmp => "legacy_id integer, iso2 varchar, iso3 varchar, name varchar, long_name varchar, region_number varchar",
      :tmp_columns => ['legacy_id', 'iso2', 'iso3', 'name', 'long_name', 'region_number']
  },
    'animals_import' => {
      :create_tmp => "Kingdom varchar, Phylum varchar, Class varchar, TaxonOrder varchar, Family varchar, Genus varchar, Species varchar, SpcInfra varchar, SpcRecId integer, SpcStatus varchar",
      :tmp_columns => ['Kingdom', 'Phylum', 'Class', 'TaxonOrder', 'Family', 'Genus', 'Species', 'SpcInfra', 'SpcRecId', 'SpcStatus']
  },
    'plants_import' => {
      :create_tmp => "Kingdom varchar, TaxonOrder varchar, Family varchar, Genus varchar, Species varchar, SpcInfra varchar, SpcRecId integer, SpcStatus varchar",
      :tmp_columns => ['Kingdom', 'TaxonOrder', 'Family', 'Genus', 'Species', 'SpcInfra', 'SpcRecId', 'SpcStatus']
  },
    'cites_listings_import' => {
      :create_tmp => "LegRecID integer, spc_rec_id integer, appendix varchar, listing_date date, country_legacy_id varchar, notes varchar",
      :tmp_columns => ['LegRecID', 'spc_rec_id', 'appendix', 'listing_date', 'country_legacy_id', 'notes']
  },
    'distribution_import' => {
      :create_tmp => "DctRecID integer, species_id integer, country_id integer, country_name varchar",
      :tmp_columns => ['DctRecID', "species_id", "country_id", "country_name"]
  },
    'common_name_import' => {
      :create_tmp => 'ComRecID integer, common_name varchar, language_name varchar, species_id integer',
      :tmp_columns => ['ComRecID', "common_name", "language_name", "species_id"]
  },
    'animals_synonym_import' => {
      :create_tmp => "Kingdom varchar, Phylum varchar, Class varchar, TaxonOrder varchar, Family varchar, Genus varchar, Species varchar, SpcInfra varchar, SpcRecID integer, SpcStatus varchar, accepted_species_id integer",
      :tmp_columns => ["Kingdom", "Phylum", "Class", "TaxonOrder", "Family", "Genus", "Species", "SpcInfra", "SpcRecID", "SpcStatus", "accepted_species_id"]
  },
    'plants_synonym_import' => {
      :create_tmp => "Kingdom varchar, TaxonOrder varchar, Family varchar, Genus varchar, Species varchar, SpcInfra varchar, SpcRecID integer, SpcStatus varchar, accepted_species_id integer",
      :tmp_columns => ["Kingdom", "TaxonOrder", "Family", "Genus", "Species", "SpcInfra", "SpcRecID", "SpcStatus", "accepted_species_id"]
    },
    'references_import' => {
      :create_tmp => "DscRecID integer, DscTitle varchar, DscAuthors varchar, DscPubYear varchar",
      :tmp_columns => ['DscRecID', 'DscTitle', 'DscAuthors', 'DscPubYear']
    },
    'reference_links_import' => {
      :create_tmp => "DslRecID integer, DslSpcRecID integer, DslDscRecID integer, DslCode varchar, DslCodeRecID integer",
      :tmp_columns => ['DslRecID', 'DslSpcRecID', 'DslDscRecID', 'DslCode', 'DslCodeRecID']
    },
    'standard_references_import' => {
      :create_tmp => 'Author varchar, Year integer, Title text, Kingdom varchar, Phylum varchar, Class varchar, TaxonOrder varchar, Family varchar, Genus varchar, Species varchar',
      :tmp_columns => ['Author', 'Year', 'Title', 'Kingdom', 'Phylum', 'Class', 'TaxonOrder', 'Family', 'Genus', 'Species']
    }
}

def result_to_sql_values(result)
  result.to_a.map{|a| a.values.inspect.sub('[', '(').sub(/]$/, ')')}.join(',').gsub('\"', '').gsub("'", "''").gsub('"', "'").gsub('nil', 'NULL')
end

def create_import_table table_name
  create_tmp = MAPPING[table_name][:create_tmp]
  begin
    puts "Creating tmp table"
    ActiveRecord::Base.connection.execute "CREATE TABLE #{table_name} (#{create_tmp})"
    puts "Table created"
  rescue Exception => e
    puts e.inspect
    puts "Tmp already exists removing data from tmp table before starting the import"
    ActiveRecord::Base.connection.execute "DELETE FROM #{table_name};"
    puts "Data removed"
  end
end

def drop_table(table_name)
  begin
    ActiveRecord::Base.connection.execute "DROP TABLE IF EXISTS #{table_name};"
    puts "Table #{table_name} removed"
  rescue Exception => e
    puts "Could not drop table #{table_name}. It might not exist if this is the first time you are running this rake task."
  end
end

def copy_data(table_name, query)
  puts "Copying data from SQL Server into tmp table #{table_name}"
  client = TinyTds::Client.new(:username => 'sapi', :password => 'conserveworld', :host => 'wcmc-gis-01.unep-wcmc.org', :port => 1539, :database => 'Animals', :timeout => 10000)
  client.execute('SET ANSI_NULLS ON')
  client.execute('SET ANSI_WARNINGS ON')

  result = client.execute(query)

  tmp_columns = MAPPING[table_name][:tmp_columns]
  cmd = <<-SQL
    SET DateStyle = \"ISO,DMY\";
    INSERT INTO #{table_name} (#{tmp_columns.join(',')})
    VALUES
    #{result_to_sql_values(result)}
  SQL
  ActiveRecord::Base.connection.execute(cmd)

  puts "Data copied to tmp table"
  client.close
end

#recid -- field to be used for ordering for batch load  (e.g. DscRecID)
def copy_data_in_batches(table_name, query, recid)
  puts "Copying data from SQL Server into tmp table #{table_name} (in batches)"
  client = TinyTds::Client.new(:username => 'sapi', :password => 'conserveworld', :host => 'wcmc-gis-01.unep-wcmc.org', :port => 1539, :database => 'Animals', :timeout => 10000)
  client.execute('SET ANSI_NULLS ON')
  client.execute('SET ANSI_WARNINGS ON')

  #get the total count of matching records
  query_cnt = query.sub(/SELECT(.+?)FROM ([^\s;]+)/im,"SELECT COUNT(*) AS cnt FROM \\2")
  table = $2
  result = client.execute(query_cnt)
  cnt = result.first['cnt']
  puts "#{cnt} records to copy"

  offset = 0
  limit = 5000

  #process in batches of 5000
  while offset < cnt
    puts "offset: #{offset}"

    query_limit = <<-SQL

    SELECT *
    FROM (
      SELECT TOP #{limit} #{recid} FROM (
        SELECT TOP #{offset + limit} #{recid}
        FROM #{table}
        ORDER BY #{recid} ASC
      ) AS t1
      ORDER BY #{recid} DESC
    ) AS t2
    INNER JOIN (
      #{query.sub(/[;\s]+$/,'')}
    ) AS t ON t2.#{recid} = t.#{recid}
    ORDER BY t2.#{recid} ASC
    SQL

    offset += limit

    result.do
    result = client.execute(query_limit)
    tmp_columns = MAPPING[table_name][:tmp_columns]
    cmd = <<-SQL
      SET DateStyle = \"ISO,DMY\";
      INSERT INTO #{table_name} (#{tmp_columns.join(',')})
      VALUES
      #{result_to_sql_values(result)}
    SQL
    ActiveRecord::Base.connection.execute(cmd)
  end
  client.close
end

def copy_data_from_file(table_name, path_to_file)
  puts "Copying data from #{path_to_file} into tmp table #{table_name}"
  tmp_columns = MAPPING[table_name][:tmp_columns]
  cmd = <<-PSQL
      SET DateStyle = \"ISO,DMY\";
\\COPY #{table_name} (#{tmp_columns.join(', ')})
FROM '#{Rails.root + path_to_file}'
WITH DElIMITER ','
CSV HEADER
  PSQL

  db_conf = YAML.load(File.open(Rails.root + "config/database.yml"))[Rails.env]
  puts "export PGPASSWORD=#{db_conf["password"]} && echo \"#{cmd.split("\n").join(' ')}\" | psql -h #{db_conf["host"] || "localhost"} -p #{db_conf["port"] || 5432} -U#{db_conf["username"]} #{db_conf["database"]}"
  system("export PGPASSWORD=#{db_conf["password"]} && echo \"#{cmd.split("\n").join(' ')}\" | psql -h #{db_conf["host"] || "localhost"} -p #{db_conf["port"] || 5432} -U#{db_conf["username"]} #{db_conf["database"]}")
  puts "Data copied to tmp table"
end

def files_from_args(t, args)
  files = t.arg_names.map{ |a| args[a] }.compact
  files = ['lib/assets/files/animals.csv'] if files.empty?
  files.reject { |file| !file_ok?(file) }
end

def file_ok?(path_to_file)
  if !File.file?(Rails.root.join(path_to_file)) #if the file is not defined, explain and leave.
    puts "Please specify a valid csv file from which to import data"
    puts "Usage: rake import:XXX[path/to/file,path/to/another]"
    return false
  end
  true
end
