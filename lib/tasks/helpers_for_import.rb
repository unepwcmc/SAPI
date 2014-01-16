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
      'ISO Code 2' => 'iso2 varchar',
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
      'Cascade' => 'is_cascaded boolean'
    },
    'events_import' => {
      'Legacy_ID' => 'legacy_id int',
      'Designation' => 'designation varchar',
      'LnmShortDesc' => 'name varchar',
      'Date valid from' => 'effective_at date',
      'Event Type' => 'type varchar',
      'Basis for Suspension' => 'subtype varchar',
      'LnmLongDesc' => 'description text',
      'LnmURL' => 'url text'
    },
    'languages_import' => {
      'ISO-3' => 'iso_code3 varchar',
      'LangShort' => 'name_en varchar',
      'ISO-1' => 'iso_code1 varchar'
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
    },
    'cites_suspensions_import' => {
      'IsCurrent' => 'is_current boolean',
      'Kingdom' => 'kingdom varchar',
      'RecID' => 'legacy_id integer',
      'Rank' => 'rank varchar',
      'ISO code' => 'country_iso2 varchar',
      'StartNotificationID' => 'start_notification_legacy_id integer',
      'EndNotificationID' => 'end_notification_legacy_id integer',
      'Notes' => 'notes varchar',
      'ExcludedTaxa' => 'exclusions text'
    },
    'distribution_tags_import' => {
      'Species RecID' => 'legacy_id integer',
      'Rank' => 'rank varchar',
      'GEO_entity_type' => 'geo_entity_type varchar',
      'ISO Code 2' => 'iso_code2 varchar',
      'Tags' => 'tags varchar',
      'Designation' => 'designation varchar'
    },
    'hash_annotations_import' => {
      'Hash No' => 'symbol varchar',
      'Event No' => 'event_legacy_id integer',
      'For Display' => 'ignore varchar',
      'Text' => 'full_note_en varchar'
    },
    'eu_listings_import' => {
      'LAW_NUM' => 'event_legacy_id integer',
      'RANK_NAME' => 'rank varchar',
      'REC_ID' => 'legacy_id integer',
      'LISTING' => 'annex varchar',
      'EFFECTIVE_FROM' => 'listing_date date',
      'PARTY_ISO2' => 'country_iso2 varchar',
      'IS_CURRENT' => 'is_current boolean',
      'POPULATIONS_ISO2' => 'populations_iso2 varchar',
      'EXCLUDEDpopulations_ISO' => 'excluded_populations_iso2 varchar',
      'IS_INCLUSION' => 'is_inclusion boolean',
      'INCLUDED_IN' => 'included_in_rec_id integer',
      'RANK' => 'rank_for_inclusions varchar',
      'EXCLUDED_REC_IDS' => 'excluded_taxa varchar',
      'FULL_NOTE_EN' => 'full_note_en varchar',
      'HASH_NOTE' => 'hash_note varchar'
    },
    'cms_listings_import' => {
      'rank' => 'rank varchar',
      'rec_id' => 'legacy_id integer',
      'listing' => 'appendix varchar',
      'effective_from' => 'listing_date varchar',
      'is_current' => 'is_current boolean',
      'populations_iso2' => 'populations_iso2 varchar',
      'EXCLUDEDpopulations_iso' => 'excluded_populations_iso2 varchar',
      'is_inclusion' => 'is_inclusion boolean',
      'included_in_RecID' => 'included_in_rec_id integer',
      'RankforInclusions' => 'rank_for_inclusions varchar',
      'excluded_rec_ids' => 'excluded_taxa varchar',
      'LegNotes' => 'full_note_en varchar',
      'CMS instrument' => 'designation varchar',
      'Internal Notes' => 'notes varchar'
    },
    'eu_decisions_import' => {
      'IsCurrent?' => 'is_current boolean',
      'Taxonomy' => 'taxonomy varchar',
      'LawID' => 'event_legacy_id integer',
      'SpcRecID' => 'legacy_id integer',
      'DecLevel' => 'rank varchar',
      'Kingdom' => 'kingdom varchar',
      'ISO_country' => 'country_iso2 varchar',
      'DecOpinion' => 'opinion varchar',
      'DecDate' => 'start_date date',
      'Source' => 'source varchar',
      'Term' => 'term varchar',
      'DecNotes' => 'notes varchar',
      'Internal_Notes' => 'internal_notes varchar'
    },
    'terms_and_purpose_pairs_import' => {
      'TERM_CODE' => 'TERM_CODE varchar',
      'PURPOSE_CODE' => 'PURPOSE_CODE varchar'
    },
    'terms_and_unit_pairs_import' => {
      'TERM_CODE' => 'TERM_CODE varchar',
      'UNIT_CODE' => 'UNIT_CODE varchar'
    },
    'taxon_concepts_and_terms_pairs_import' => {
      'TAXON_FAMILY' => 'TAXON_FAMILY varchar',
      'TERM_CODE' => 'TERM_CODE varchar'
    },
    'eu_annex_regulations_end_dates_import' => {
      'Name' => 'name varchar',
      'Effective from' => 'effective_at date',
      'End Date' => 'end_date date'
    }
  }

  def csv_to_db(table, field)
    MAPPING[table][field]
  end
end

def files_from_args(t, args)
  files = t.arg_names.map{ |a| args[a] }.compact
  files = ['lib/files/animals.csv'] if files.empty?
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
  require 'psql_command'
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
  PsqlCommand.new(cmd).execute
  puts "Data copied to tmp table"
end
