require 'csv'

class CsvToDbMap
  include Singleton

  MAPPING = {
    'species_import' => {
      'Kingdom' => 'Kingdom varchar',
      'PhyName' => 'Phylum varchar',
      'ClaName' => 'Class varchar',
      'OrdName' => 'TaxonOrder varchar',
      'FamName' => 'Family varchar',
      'GenName' => 'Genus varchar',
      'SpcName' => 'Species varchar',
      'SpcAuthor' => 'SpeciesAuthor varchar',
      'SpcInfraRank' => 'SpcInfraRank varchar',
      'SpcInfraEpithet' => 'SpcInfra varchar',
      'SpcInfraRankAuthor' => 'InfraRankAuthor varchar',
      'SpcRecID' => 'SpcRecId integer',
      'SpcStatus' => 'SpcStatus varchar',
    },
    'cites_listings_import' => {
      'Kingdom' => 'legacy_type varchar',
      'SpcRecID' => 'spc_rec_id integer',
      'LegListing' => 'appendix varchar',
      'LegDateListed' => 'listing_date date',
      'CountryRecID' => 'country_legacy_id varchar',
      'CtyRecID' => 'country_legacy_id varchar',
      'LegNotes' => 'notes varchar'
    },
    'distribution_import' => {
      'Kingdom' => 'legacy_type varchar',
      'SpcRecID' => 'species_id integer',
      'CtyRecID' => 'country_id integer',
      'CtyShort' => 'country_name varchar'
    },
    'common_name_import' => {
      'Kingdom' => 'legacy_type varchar',
      'SpcRecID' => 'species_id integer',
      'ComName' => 'common_name varchar',
      'LanDesc' => 'language_name varchar'
    },
    'synonym_import' => {
      'Kingdom' => 'Kingdom varchar',
      'PhyName' => 'Phylum varchar',
      'ClaName' => 'Class varchar',
      'OrdName' => 'TaxonOrder varchar',
      'FamName' => 'Family varchar',
      'GenName' => 'Genus varchar',
      'SpcName' => 'Species varchar',
      'SpcAuthor' => 'SpeciesAuthor varchar',
      'SpcInfraRank' => 'SpcInfraRank varchar',
      'SpcInfraEpithet' => 'SpcInfra varchar',
      'SpcInfraRankAuthor' => 'InfraRankAuthor varchar',
      'SpcStatus' => 'SpcStatus varchar',
      'SynonymSpcRecID' => 'SpcRecID integer',
      'AcceptedSpcRecID' => 'accepted_species_id integer'
    },
    #TODO legacy type for regions?
    'cites_regions_import' => {
      'name' => 'name varchar'
    },
    #TODO legacy type for countries?
    'countries_import' => {
      'old_id' => 'legacy_id integer',
      'iso2' => 'iso2 varchar',
      'iso3' => 'iso3 varchar',
      'name' => 'name varchar',
      'long_name' => 'long_name varchar',
      'Region' => 'region_number varchar'
    },
    'references_import' => {
      'legacy_type' => 'legacy_type varchar',
      'legacy_id' => 'legacy_id integer',
      'author' => 'author varchar',
      'title' => 'title varchar',
      'year' => 'year varchar'
    },
    'reference_links_import' => {
      'Kingdom' => 'legacy_type varchar',
      'DslRecID' => 'legacy_id integer',
      'DslSpcRecID' => 'SpcRecID integer',
      'DslDscRecID' => 'DscRecID integer',
      'DslCode' => 'DslCode varchar',
      'DslCodeRecID' => 'DslCodeRecID integer'
    },
    'standard_references_import' => {
      "Author" => 'author varchar',
      "Year" => 'year integer',
      "Title" => 'title varchar',
      "Kingdom" => 'Kingdom varchar',
      "Phylum" => 'Phylum varchar',
      "Class" => 'Class varchar',
      "Order" => 'TaxonOrder varchar',
      "Family" => 'Family varchar',
      "Genus" => 'Genus varchar',
      "Species" => 'Species varchar'
    }
  }

  def csv_to_db(table, field)
    MAPPING[table][field]
  end
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

def csv_headers(path_to_file)
  res = nil
  CSV.foreach(path_to_file) do |row|
    res = row.map{ |h| h && h.chomp.sub(/^\W/,'') }.compact
    break
  end
  res
end

def db_columns_from_csv_headers(path_to_file, table_name, include_data_type = true)
    m = CsvToDbMap.instance
    #work out the db columns to create
    csv_columns = csv_headers(path_to_file)
    db_columns = csv_columns.map{ |col| m.csv_to_db(table_name, col) }
    db_columns = db_columns.map{ |col| col.sub(/\s\w+$/,'')} unless include_data_type
    puts csv_columns.inspect
    puts db_columns.inspect
    db_columns
end

def create_table_from_csv_headers(path_to_file, table_name)
    db_columns = db_columns_from_csv_headers(path_to_file, table_name)
    begin
      puts "Creating tmp table"
      ActiveRecord::Base.connection.execute "DROP TABLE IF EXISTS #{table_name} CASCADE"
      ActiveRecord::Base.connection.execute "CREATE TABLE #{table_name} (#{db_columns.join(', ')})"
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
    puts "Table removed"
  rescue Exception => e
    puts "Could not drop table #{table_name}. It might not exist if this is the first time you are running this rake task."
  end
end

def copy_data(path_to_file, table_name)
  puts "Copying data from #{path_to_file} into tmp table #{table_name}"
  db_columns = db_columns_from_csv_headers(path_to_file, table_name, false)
  cmd = <<-PSQL
SET DateStyle = \"ISO,DMY\";
\\COPY #{table_name} (#{db_columns.join(', ')})
FROM '#{Rails.root + path_to_file}'
WITH DELIMITER ','
CSV HEADER
PSQL

  db_conf = YAML.load(File.open(Rails.root + "config/database.yml"))[Rails.env]
  system("export PGPASSWORD=#{db_conf["password"]} && echo \"#{cmd.split("\n").join(' ')}\" | psql -h #{db_conf["host"] || "localhost"} -p #{db_conf["port"] || 5432} -U#{db_conf["username"]} #{db_conf["database"]}")
  #system("export PGPASSWORD=#{db_conf["password"]} && psql -h #{db_conf["host"] || "localhost"} -U#{db_conf["username"]} -c \"#{psql}\" #{db_conf["database"]}")
  puts "Data copied to tmp table"
end