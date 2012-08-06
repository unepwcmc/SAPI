require 'csv'
# connecting to SQL Server 2008
# TinyTds::Client.new(:username => 'sapi', :password => 'conserveworld', :host => 'wcmc-gis-01.unep-wcmc.org', :port => 1539, :database => 'Animals')

MAPPING = {
    'species_import' => {
      'Kingdom' => 'Kingdom varchar',
      'PhyName' => 'Phylum varchar',
      'ClaName' => 'Class varchar',
      'OrdName' => 'TaxonOrder varchar',
      'FamName' => 'Family varchar',
      'GenName' => 'Genus varchar',
      'SpcName' => 'Species varchar',
      'SpcInfraRank' => 'SpcInfraRank varchar',
      'SpcInfraEpithet' => 'SpcInfra varchar',
      'SpcRecID' => 'SpcRecId integer',
      'SpcStatus' => 'SpcStatus varchar'
  },
    'cites_listings_import' => {
      'SpcRecID' => 'spc_rec_id integer',
      'LegListing' => 'appendix varchar',
      'LegDateListed' => 'listing_date date',
      'CountryRecID' => 'country_legacy_id varchar',
      'CtyRecID' => 'country_legacy_id varchar',
      'LegNotes' => 'notes varchar'
  },
    'distribution_import' => {
      'SpcRecID' => 'species_id integer',
      'CtyRecID' => 'country_id integer',
      'CtyShort' => 'country_name varchar'
  },
    'common_name_import' => {
      'ComName' => 'common_name varchar',
      'LanDesc' => 'language_name varchar',
      'SpcRecID' => 'species_id integer'
    },
    'synonym_import' => {
      'Kingdom' => 'Kingdom varchar',
      'PhyName' => 'Phylum varchar',
      'ClaName' => 'Class varchar',
      'OrdName' => 'TaxonOrder varchar',
      'FamName' => 'Family varchar',
      'GenName' => 'Genus varchar',
      'SpcName' => 'Species varchar',
      'SpcInfraRank' => 'SpcInfraRank varchar',
      'SpcInfraEpithet' => 'SpcInfra varchar',
      'SpcStatus' => 'SpcStatus varchar',
      'SpcRecID' => 'SpcRecID integer',
      'AcceptedSpcRecID' => 'accepted_species_id integer'
    },
    'cites_regions_import' => {
    'name' => 'name varchar'
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
  }
}

def result_to_sql_values(result)
  result.to_a.map{|a| a.values.inspect.sub('[', '(').sub(/]$/, ')')}.join(',').gsub("'", "''").gsub('"', "'").gsub('nil', 'NULL')
end

def create_table table_name
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
  tmp_columns = MAPPING[table_name][:tmp_columns]
  client = TinyTds::Client.new(:username => 'sapi', :password => 'conserveworld', :host => 'wcmc-gis-01.unep-wcmc.org', :port => 1539, :database => 'Animals')
  client.execute('SET ANSI_NULLS ON')
  client.execute('SET ANSI_WARNINGS ON')
  result = client.execute(query)
  cmd = <<-PSQL
    INSERT INTO #{table_name} (#{tmp_columns.join(',')})
    VALUES
    #{result_to_sql_values(result)}
  PSQL
  db_conf = YAML.load(File.open(Rails.root + "config/database.yml"))[Rails.env]
  system("export PGPASSWORD=#{db_conf["password"]} && echo \"#{cmd.split("\n").join(' ')}\" | psql -h #{db_conf["host"] || "localhost"} -U#{db_conf["username"]} #{db_conf["database"]}")
  puts "Data copied to tmp table"
end
