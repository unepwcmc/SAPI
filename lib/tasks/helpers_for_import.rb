require 'csv'

class CsvToDbMap
  include Singleton

  MAPPING = {
    'species_import' => {
      'Scientific name' => 'name varchar',
      'Rank' => 'rank varchar',
      'RecID' => 'legacy_id integer',
      'ParentRank' => 'parent_rank varchar',
      'ParentID' => 'parent_id integer',
      'Status' => 'status varchar',
      'Species Author' => 'author varchar',
      'Notes' => 'notes varchar',
      'Designation' => 'taxonomy varchar'
    },
    'species_import_legacy' => {
      'Scientific name' => 'name varchar',
      'Rank' => 'rank varchar',
      'RecID' => 'legacy_id integer',
      'ParentRank' => 'parent_rank varchar',
      'ParentRecID' => 'parent_legacy_id integer',
      'Status' => 'status varchar',
      'Species Author' => 'author varchar',
      'Notes' => 'notes varchar',
      'Designation' => 'taxonomy varchar'
    },
    'species_kew_id_import' => {
      'Scientific name' => 'name varchar',
      'Rank' => 'rank varchar',
      'RecID' => 'kew_id integer',
      'ParentRank' => 'parent_rank varchar',
      'ParentRecID' => 'parent_kew_id integer',
      'Status' => 'status varchar',
      'Species Author' => 'author varchar',
      'Notes' => 'notes varchar',
      'Designation' => 'taxonomy varchar'
    },
    'synonym_import' => {
      'Scientific name' => 'name varchar',
      'Rank' => 'rank varchar',
      'RecID' => 'legacy_id integer',
      'ParentRank' => 'parent_rank varchar',
      'ParentID' => 'parent_id integer',
      'Status' => 'status varchar',
      'Species Author' => 'author varchar',
      'Notes' => 'notes varchar',
      'Designation' => 'taxonomy varchar',
      'AcceptedRank' => 'accepted_rank varchar',
      'AcceptedID' => 'accepted_id integer'
    },
    'synonym_import_legacy' => {
      'Scientific name' => 'name varchar',
      'Rank' => 'rank varchar',
      'RecID' => 'legacy_id integer',
      'ParentRank' => 'parent_rank varchar',
      'Parent recID' => 'parent_legacy_id integer',
      'Status' => 'status varchar',
      'Species Author' => 'author varchar',
      'Notes' => 'notes varchar',
      'Designation' => 'taxonomy varchar',
      'AcceptedRank' => 'accepted_rank varchar',
      'AcceptedRecID' => 'accepted_legacy_id integer'
    },
    'synonym_kew_id_import' => {
      'Scientific name' => 'name varchar',
      'Rank' => 'rank varchar',
      'RecID' => 'kew_id integer',
      'ParentRank' => 'parent_rank varchar',
      'Parent recID' => 'parent_kew_id integer',
      'Status' => 'status varchar',
      'Species Author' => 'author varchar',
      'Notes' => 'notes varchar',
      'Designation' => 'taxonomy varchar',
      'AcceptedRank' => 'accepted_rank varchar',
      'AcceptedRecID' => 'accepted_kew_id integer'
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
      'taxon_concept_id' => 'taxon_concept_id integer',
      'Rank' => 'rank varchar',
      'GEO_entity' => 'geo_entity_type varchar',
      'ISO Code 2' => 'iso2 varchar',
      'Reference IDs' => 'reference_id integer',
      'Designation' => 'designation varchar',
      'Reference' => 'citation text'
    },
    'distribution_tags_import' => {
      'Species RecID' => 'legacy_id integer',
      'taxon_concept_id' => 'taxon_concept_id integer',
      'Rank' => 'rank varchar',
      'GEO_entity' => 'geo_entity_type varchar',
      'ISO Code 2' => 'iso_code2 varchar',
      'Tags' => 'tags varchar',
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
    'cites_regions_import' => {
      'name' => 'name varchar',
      'name_es' => 'name_es varchar',
      'name_fr' => 'name_fr varchar'
    },
    # TODO: legacy type for countries?
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
    'hash_annotations_import' => {
      'Hash No' => 'symbol varchar',
      'Event No' => 'event_legacy_id integer',
      'For Display' => 'ignore varchar',
      'Text' => 'full_note_en varchar'
    },
    'hash_annotations_translations_import' => {
      'Event No' => 'event_legacy_id integer',
      'Event' => 'event varchar',
      'Hash No' => 'symbol varchar',
      'For Display' => 'ignore varchar',
      'Annotations_English' => 'full_note_en varchar',
      'Annotations_Spanish' => 'full_note_es varchar',
      'Annotations_French' => 'full_note_fr varchar'
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
    'eu_opinions_import' => {
      'taxon_concept_id' => 'taxon_concept_id integer',
      'start_regulation_name' => 'start_event_name varchar',
      'country_name' => 'country_name varchar',
      'start_date' => 'start_date date',
      'opinion_name' => 'opinion_name varchar',
      'term_code' => 'term_code varchar',
      'source_code' => 'source_code varchar',
      'is_current' => 'is_current boolean',
      'notes' => 'notes varchar',
      'internal_notes' => 'internal_notes varchar',
      'nomenclature_note_en' => 'nomenclature_note_en varchar',
      'nomenclature_note_es' => 'nomenclature_note_es varchar',
      'nomenclature_note_fr' => 'nomenclature_note_fr varchar'
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
      'RANK' => 'RANK varchar',
      'TAXON_FAMILY' => 'TAXON_FAMILY varchar',
      'TERM_CODE' => 'TERM_CODE varchar'
    },
    'eu_annex_regulations_end_dates_import' => {
      'Name' => 'name varchar',
      'Effective from' => 'effective_at date',
      'End Date' => 'end_date date'
    },
    'cites_cops_start_dates_import' => {
      'designation' => 'designation varchar',
      'name' => 'name varchar',
      'start_date' => 'start_date date'
    },
    'trade_species_mapping_import' => {
      'cites_name' => 'cites_name varchar',
      'cites_taxon_code' => 'cites_taxon_code varchar',
      'speciesplusid' => 'species_plus_id int',
      'speciesplusname' => 'species_plus_name varchar',
      'rank' => 'rank varchar'
    },
    'shipments_import' => {
      'SHIPMENT_NUMBER' => 'shipment_number int',
      'ISO_COUNTRY_CODE' => 'iso_country_code varchar',
      'REPORTER_TYPE' => 'reporter_type varchar',
      'SHIPMENT_YEAR' => 'shipment_year int',
      'APPENDIX' => 'appendix varchar',
      'CITES_TAXON_CODE' => 'cites_taxon_code varchar',
      'TERM_CODE_1' => 'term_code_1 varchar',
      'TERM_CODE_2' => 'term_code_2 varchar',
      'UNIT_CODE_1' => 'unit_code_1 varchar',
      'UNIT_CODE_2' => 'unit_code_2 varchar',
      'QUANTITY_1' => 'quantity_1 numeric',
      'QUANTITY_2' => 'quantity_2 numeric',
      'EXPORT_COUNTRY_CODE' => 'export_country_code varchar',
      'IMPORT_COUNTRY_CODE' => 'import_country_code varchar',
      'ORIGIN_COUNTRY_CODE' => 'origin_country_code varchar',
      'SOURCE_CODE' => 'source_code varchar',
      'PURPOSE_CODE' => 'purpose_code varchar',
      'PERMIT_NUMBER_COUNT' => 'permit_number_count int',
      'RECORD_LOAD_STATUS' => 'record_load_status varchar'
    },
    'permits_import' => {
      'SHIPMENT_NUMBER' => 'shipment_number int',
      'PERMIT_ENTRY_NUMBER' => 'permit_entry_number int',
      'PERMIT_NUMBER' => 'permit_number varchar',
      'PERMIT_YEAR' => 'permit_year int',
      'PERMIT_REPORTER_TYPE' => 'permit_reporter_type varchar',
      'ENTITY_CODE' => 'entity_code varchar'
    },
    'hybrids_import' => {
      'Legacy_CITES_TAXON_CODE' => 'legacy_cites_taxon_code varchar',
      'Full Hybrid Name' => 'full_hybrid_name varchar',
      'Hybrid Rank' => 'hybrid_rank varchar',
      'SpeciesPlusID' => 'species_plus_id integer',
      'Parent' => 'parent varchar',
      'ParentRank' => 'parent_rank varchar',
      'Status' => 'status varchar'
    },
    'trade_names_import' => {
      'cites_trade_name' => 'cites_trade_name varchar',
      'legacy_cites_ID' => 'legacy_cites_taxon_code varchar',
      'valid_name_species_plus_id' => 'valid_name_speciesplus_id integer',
      'valid_name' => 'valid_name varchar',
      'trade_name_rank' => 'trade_name_rank varchar',
      'name_status' => 'name_status varchar'
    },
    'synonyms_to_trade_mapping_import' => {
      'cites_taxon_code' => 'cites_taxon_code varchar',
      'species_plus_id' => 'species_plus_id integer',
      'accepted_id' => 'accepted_id integer'
    },
    'ranks_translations_import' => {
      'name' => 'name varchar',
      'display_name_es' => 'display_name_es varchar',
      'display_name_fr' => 'display_name_fr varchar'
    },
    'change_types_translations_import' => {
      'name' => 'name varchar',
      'display_name_es' => 'display_name_es varchar',
      'display_name_fr' => 'display_name_fr varchar'
    },
    'author_year_import' => {
      'Scientific name' => 'name varchar',
      'Rank' => 'rank varchar',
      'RecID' => 'legacy_id integer',
      'ParentRank' => 'parent_rank varchar',
      'ParentRecID' => 'parent_id integer',
      'Status' => 'status varchar',
      'Species author' => 'author varchar',
      'notes' => 'notes varchar'
    }
  }

  def csv_to_db(table, field)
    MAPPING[table][field]
  end
end

class CsvImportHelper
  def files_from_args(t, args)
    files = t.arg_names.map { |a| args[a] }.compact
    files = [ 'lib/files/animals.csv' ] if files.empty?

    files.reject { |file| !file_ok?(file) }
  end

  def file_ok?(path_to_file)
    if !Rails.root.join(path_to_file).file? # if the file is not defined, explain and leave.
      Rails.logger.debug 'Please specify a valid csv file from which to import data'
      Rails.logger.debug 'Usage: rake import:XXX[path/to/file,path/to/another]'
      return false
    end

    true
  end

  def csv_headers(path_to_file)
    res = nil

    CSV.foreach(path_to_file) do |row|
      res = row.map { |h| h && h.chomp.sub(/^\W/, '') }.compact
      break
    end

    res
  end

  def db_columns_from_csv_headers(path_to_file, table_name, include_data_type = true)
    m = CsvToDbMap.instance

    # work out the db columns to create
    csv_columns = csv_headers(path_to_file)
    db_columns = csv_columns.map { |col| m.csv_to_db(table_name, col) || '' }
    db_columns = db_columns.map { |col| col&.sub(/\s\w+$/, '') } unless include_data_type

    db_columns.select(&:present?)
  end

  def create_table_from_csv_headers(path_to_file, table_name)
    db_columns = db_columns_from_csv_headers(path_to_file, table_name)

    create_table_from_column_array(table_name, db_columns)

    db_columns
  end

  def create_table_from_column_array(table_name, column_names)
    raise StandardError(
      'Not in a transaction - cannot create temp table'
    ) unless ActiveRecord::Base.connection.open_transactions > 0

    begin
      # Dropping the table is redundant as temp tables have higher precedence
      # in search_path than permanent ones.
      # Rails.logger.debug { "Dropping table #{table_name}, if it exists" }
      # ApplicationRecord.connection.execute "DROP TABLE IF EXISTS #{table_name} CASCADE"
      connection = ApplicationRecord.connection

      table_expr =
        if column_names.present?
          if column_names.is_a? Array
            quoted_table_name = connection.quote_table_name(table_name)

            if column_names[0]&.match? /\b(?:varchar|integer|boolean|float)$/i
              "#{quoted_table_name} (#{column_names.join(', ')})"
            else
              column_names_quoted = column_names.map do |name|
                connection.quote_column_name name
              end.join(', ')

              "#{quoted_table_name} (#{column_names_quoted})"
            end
          else
            # also accept raw sql here: 'id INTEGER, code VARCHAR'
            column_names
          end
        else
          connection.quote_table_name(table_name)
        end

      Rails.logger.debug { "Creating temp table #{table_expr}" }

      connection.execute "CREATE TEMP TABLE #{table_expr} ON COMMIT DROP"

      Rails.logger.debug 'Table created'
    rescue Exception => e
      Rails.logger.debug e.inspect

      raise e
    end
  end

  def drop_table(table_name)
    connection = ApplicationRecord.connection
    quoted_table_name = connection.quote_column_name(table_name)

    begin
      Rails.logger.debug { "Dropping #{quoted_table_name}, if it exists" }
      ApplicationRecord.connection.execute "DROP TABLE IF EXISTS #{quoted_table_name};"
    rescue Exception
      Rails.logger.debug do
        "Could not drop table #{quoted_table_name}. " +
          'It might not exist if this is the first time you are running this rake task.'
      end
      Rails.logger.debug e.inspect

      raise e
    end
  end

  def copy_data(path_to_file, table_name)
    db_columns = db_columns_from_csv_headers(path_to_file, table_name)

    copy_data_into_table(path_to_file, table_name, db_columns)
  end

  def copy_data_into_table(
    path_to_file,
    table_name,
    column_mapping,
    csv_options = {}
  )
    # For the rest of the transaction, parse dates as ISO or DMY, not MDY (US)
    ApplicationRecord.connection.execute 'SET LOCAL DateStyle = "ISO,DMY"'

    encoder_class = {
      varchar: PG::BinaryEncoder::String,
      text: PG::BinaryEncoder::String,
      integer: PG::BinaryEncoder::Int4,
      float: PG::BinaryEncoder::Float4,
      boolean: PG::BinaryEncoder::Boolean,
      date: PG::BinaryEncoder::Date
    }

    column_names =
      if column_mapping.is_a? Array
        column_mapping
      elsif column_mapping.is_a? Hash
        column_mapping.values
      end.map do |v|
        v.split(/\s+/)[0]
      end

    column_types =
      if column_mapping.is_a? Array
        column_mapping
      elsif column_mapping.is_a? Hash
        column_mapping.values
      end.map do |v|
        v.split(/\s+/)[1] || 'varchar'
      end.map(&:downcase)

    full_path = Rails.root + path_to_file

    Rails.logger.debug do
      "Copying data from #{full_path} into tmp table #{table_name} (#{column_names.zip column_types})"
    end

    encoder_type_map = PG::TypeMapByColumn.new(
      column_types&.map do |t|
        (encoder_class[t.to_sym] || encoder_class[:varchar]).new
      end
    )

    row_count = 0
    m = CsvToDbMap.instance

    begin
      PgCopy.copy_to_db(
        table_name,
        column_names: column_names,
        pg_copy_encoder: PG::BinaryEncoder::CopyRow.new(type_map: encoder_type_map)
      ) do |writer|
        CSV.foreach(
          full_path,
          headers: true,
          skip_blanks: true,
          **csv_options
        ) do |csv_row|
          row_count += 1

          row_as_hash =
            csv_row.map do |cell|
              [
                m.csv_to_db(
                  table_name, cell[0]
                )&.split(/\s+/)&.first || cell[0],
                cell[1]
              ]
            end.to_h


          row_values =
            column_names.map do |column_name|
              row_as_hash[column_name]
            end

          writer.call(row_values)
        end
      end
    rescue StandardError => e
      Rails.logger.debug { "Failed at line #{row_count}" }
      Rails.logger.debug e.inspect

      raise e
    end

    Rails.logger.debug { "Finished copying #{row_count} rows to #{table_name}" }
  end

  def assert_no_rows(query, why = 'failing rows')
    failing_row_count = ApplicationRecord.connection.execute(
      "SELECT COUNT(1) FROM (#{query}) t"
    )[0]['count']

    return [] unless failing_row_count > 0

    error_message = "Assertion failed - got #{failing_row_count} #{why}\n\n#{query}"

    Rails.logger.debug error_message

    raise StandardError.new(error_message)

    failing_rows = ApplicationRecord.connection.execute(query)

    failing_rows
  end


  def rollback_if_dry_run
    raise ActiveRecord::Rollback.new do
      'Rolling back: dry run'
    end if ActiveModel::Type::Boolean.new.cast(
      ENV.fetch('DRY_RUN', nil)
    )
  end
end
