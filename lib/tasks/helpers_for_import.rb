require 'csv'

class CsvToDbMap
  include Singleton

  MAPPING = {
    'species_import' => {
      'Scientific name' => 'name varchar',
      'Rank' => 'rank varchar',
      'RecID' => 'legacy_id integer',
      'ParentRank' => 'parent_rank varchar',
      'ParentRecID' => 'parent_legacy_id integer',
      'Status' => 'status varchar',
      'Species Author' => 'author varchar',
      'notes' => 'notes varchar',
      'Designation' => 'taxonomy varchar'
    },
    'synonym_import' => {
      'Scientific name' => 'name varchar',
      'Rank' => 'rank varchar',
      'RecID' => 'legacy_id integer',
      'ParentRank' => 'parent_rank varchar',
      'Parent recID' => 'parent_legacy_id integer',
      'Status' => 'status varchar',
      'Species Author' => 'author varchar',
      'notes' => 'notes varchar',
      'ReferenceIDs' => 'reference_ids varchar',
      'Designation' => 'taxonomy varchar',
      'AcceptedRank' => 'accepted_rank varchar',
      'AcceptedRecID' => 'accepted_legacy_id integer'
    },
    'cites_listings_import' => {
      'rank_name' => 'rank varchar',
      'rec_id' => 'legacy_id integer',
      'listing' => 'appendix varchar',
      'effective_from' => 'listing_date date',
      'party_iso2' => 'country_iso2 varchar',
      'is_current' => 'is_current boolean',
      'populations_iso2' => 'populations_iso2 varchar',
      'EXCLUDEDpopulations_iso' => 'excluded_populations_iso2 varchar',
      'is_inclusion' => 'is_inclusion boolean',
      'included_in_RecID' => 'included_in_rec_id integer',
      'RankforInclusions' => 'rank_for_inclusions varchar',
      'excluded_rec_ids' => 'excluded_taxa varchar',
      'short_note_en' => 'short_note_en varchar',
      'short_note_es' => 'short_note_es varchar',
      'short_note_fr' => 'short_note_fr varchar',
      'full_note_en' => 'full_note_en varchar',
      'SpeciesIndexAnnotation' => 'index_annotation integer',
      'HistoryAnnotation' => 'history_annotation integer',
      'hash_note' => 'hash_note varchar',
      'Notes' => 'notes varchar'
    },
    'distribution_import' => {
      'Species RecID' => 'legacy_id integer',
      'Rank' => 'rank varchar',
      'GEO_entity' => 'geo_entity_type varchar',
      'ISO Code 2' => 'country_iso2 varchar',
      'Reference IDs' => 'reference_id integer',
      'Designation' => 'designation varchar'
    },
    'common_name_import' => {
      'ComName' => 'name varchar',
      'LangShort' => 'language varchar',
      'RecId' => 'legacy_id integer',
      'Rank' => 'rank varchar',
      'Designation' => 'designation varchar',
      'ReferenceID' => 'reference_id varchar'
    },
    #TODO legacy type for regions?
    'cites_regions_import' => {
      'name' => 'name varchar'
    },
    #TODO legacy type for countries?
    'countries_import' => {
      'ISO2' => 'iso2 varchar',
      'short_name' => 'name varchar',
      'Geo_entity' => 'geo_entity_type varchar',
      'Under' => 'parent_iso_code2 varchar',
      'Current_name' => 'current_name varchar',
      'long_name' => 'long_name varchar',
      'CITES Region' => 'cites_region varchar'
    },
    'references_import' => {
      'Full_citation' => 'citation_to_use text',
      'DscRecID' => 'legacy_ids text',
      'Authors' => 'author text',
      'Year' => 'pub_year text',
      'Title' => 'title text',
      'Source' => 'source text',
      'Publisher' => 'publisher text',
      'PubPlace' => 'pub_place text',
      'Volume' => 'volume text',
      'Number' => 'number text',
      'Pagination' => 'pagination text'
    },
    'reference_distribution_links_import' => {
      'SpcRecID' => 'taxon_legacy_id int',
      'Rank' => 'rank text',
      'GEO_entity' => 'geo_entity_type text',
      'ISO Code 2' => 'iso_code2 text',
      'RefIDs' => 'ref_legacy_id integer'
    },
    'reference_accepted_links_import' => {
      'SpcRecID' => 'taxon_legacy_id int',
      'Scientific name' => 'scientific_name text',
      'Rank' => 'rank text',
      'Status' => 'status text',
      'RefRecIDs' => 'ref_legacy_ids text'
    },
    'reference_synonym_links_import' => {
      'SpcRecID' => 'taxon_legacy_id int',
      'Scientific name' => 'scientific_name text',
      'Rank' => 'rank text',
      'Status' => 'status text',
      'RefRecIDs' => 'ref_legacy_ids text',
      'Accepted RecID' => 'accepted_taxon_legacy_id int',
      'Accepted rank' => 'accepted_rank text'
    },
    'standard_reference_links_import' => {
      'Scientific name' => 'scientific_name varchar',
      'Rank' => 'rank varchar',
      'RecID' => 'taxon_legacy_id integer',
      'DesignationStandardReferenceID' => 'ref_legacy_id integer',
      'Excludes' => 'exclusions varchar',
      'Cascade' => 'cascade boolean'
    },
    'laws_import' => {
      'LnmShortDesc' => 'name varchar',
      'Date valid' => 'effective_at date',
      'LnmLongDesc' => 'description text',
      'LnmURL' => 'url text'
    },
    'quotas_import' => {
      'Kingdom' => 'kingdom varchar',
      'RecId' => 'legacy_id integer',
      'Rank' => 'rank varchar',
      'ISO code' => 'country_iso2 varchar',
      'Quota' => 'quota float',
      'Unit' => 'unit varchar',
      'StartDate' => 'start_date date',
      'EndDate' => 'end_date date',
      'Year' => 'year integer',
      'Notes' => 'notes varchar',
      'Terms' => 'terms varchar',
      'Sources' => 'sources varchar',
      'QuoAdded' => 'created_at date',
      'QuoDate' => 'publication_date date',
      'IsCurrent' => 'is_current boolean',
      'PublicDisplay' => 'public_display boolean',
      'Link' => 'url varchar'
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
ENCODING 'utf-8'
CSV HEADER
PSQL

  db_conf = YAML.load(File.open(Rails.root + "config/database.yml"))[Rails.env]
  system("export PGPASSWORD=#{db_conf["password"]} && echo \"#{cmd.split("\n").join(' ')}\" | psql -h #{db_conf["host"] || "localhost"} -p #{db_conf["port"] || 5432} -U#{db_conf["username"]} #{db_conf["database"]}")
  #system("export PGPASSWORD=#{db_conf["password"]} && psql -h #{db_conf["host"] || "localhost"} -U#{db_conf["username"]} -c \"#{psql}\" #{db_conf["database"]}")
  puts "Data copied to tmp table"
end
