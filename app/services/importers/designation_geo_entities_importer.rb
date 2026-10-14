# A Parties file -> designation_geo_entities: which geo entities are Parties
# to which convention. Codebase ticket SAT #330. Any format Importer::Base
# reads (.csv, .tsv, .xlsx, or a .zip holding one .csv/.tsv); the first one
# was Countries_CITES_CMS.csv.
#
# The file is wide - one row per geo entity, one t/f column per designation -
# but Importer::Base writes one record per row, so a run covers one
# designation, and `import_all!` runs one per designation the file has a
# column for. The column is named after the designation, lowercased (`cites`,
# `cms`), so a designation added later is picked up without a code change, and
# one the file says nothing about (EU, today) is left exactly as it is.
#
# For the designation it covers, the file is the whole truth: a Party is
# upserted, and every row it does not list as a Party is removed - a `f`, and
# a geo entity missing from the file alike.
#
# Every row names its geo entity by id, the only key every row has (iso_code2
# is blank for regions and trade entities). The id alone is not trusted: the
# rest of the row has to describe the same entity, or the file was exported
# from another database, or edited out of line, and the run stops.
class Importers::DesignationGeoEntitiesImporter < Importer::Base
  target_model DesignationGeoEntity
  mode :raw_upsert_all
  unique_by %i[designation_id geo_entity_id]

  required_headers({ 'id' => :geo_entity_id })
  derived_attributes %i[designation_id]

  # Before #import! hands over to Importer::Base, the headers have been
  # checked through headers_in - by import_all!, or by #import! itself - and
  # headers_in validates the file. So the check is never skipped, only not
  # repeated. Header verification still runs.
  skip_file_validation true

  # Checked against the geo entity the id names. `name` is its type
  # (geo_entity_types.name), as in the export the file started from - not
  # geo_entities.legacy_type.
  IDENTITY_HEADERS = %w[id iso_code2 name_en name].freeze

  # The export writes t/f; a spreadsheet may have rewritten them. Anything
  # else, blank included, is a mistake rather than a "no".
  MEMBER_VALUES = %w[t true y yes 1].freeze
  NON_MEMBER_VALUES = %w[f false n no 0].freeze

  # Runs every designation the file has a column for, in one transaction, so
  # a problem found in a later one leaves the earlier ones untouched too.
  # Returns the importers in the order they ran, plus the designations left
  # alone, for the caller to report.
  def self.import_all!(file_path:)
    unless SUPPORTED_FILE_EXTENSIONS.include?(File.extname(file_path).downcase)
      raise Importer::Base::ImportError,
        "#{file_path}: file must have one of these extensions: #{SUPPORTED_FILE_EXTENSIONS.join(', ')}"
    end

    headers = headers_in(file_path)
    designations = Designation.order(:id).to_a
    covered, untouched = designations.partition { |designation| headers.include?(column_for(designation)) }

    if covered.empty?
      raise Importer::Base::ImportError,
        "#{file_path}: no column for any designation (expected one of: " \
        "#{designations.map { |designation| column_for(designation) }.join(', ')})"
    end

    assert_unrepeated!(file_path, covered.map { |designation| column_for(designation) })

    importers = covered.map { |designation| new(file_path:, designation:, headers_checked: true) }

    DesignationGeoEntity.transaction do
      importers.each(&:import!)
    end

    { importers:, untouched: }
  end

  def self.column_for(designation)
    designation.name.downcase
  end

  # Every header in the file, read through the same parser import! will use,
  # so the format is whatever Importer::Base supports. The one place the file
  # is validated (UTF-8, or a real .xlsx) - see skip_file_validation above.
  # The identity columns are checked by the parser's own verify_headers!:
  # present, and not repeated.
  #
  # The parsers expose rows, not the header row, so the headers are the first
  # row's keys - which means a file with no rows at all is refused, rather
  # than read as "no Parties" and allowed to empty every designation it names.
  def self.headers_in(file_path)
    parser = parser_for(file_path, IDENTITY_HEADERS)
    parser.validate_file!
    parser.verify_headers!
    # Blank rows are skipped, as import! drops them: a file of nothing but
    # blank lines has no rows either.
    parser.each_row do |row, _line_number|
      return row.keys unless row.values.all? { |value| Importer::RowTransformer.considered_blank?(value) }
    end

    raise Importer::Base::ImportError, "#{file_path}: no rows"
  ensure
    parser.close if parser.respond_to?(:close)
  end

  # The designation columns, checked for repeats the same way. It matters here
  # more than usual: a row is read as a Hash, so a second `cms` column would
  # silently replace the first - the export this file started from labelled
  # both its columns `cites` once already. The header row only; the file was
  # validated by headers_in.
  def self.assert_unrepeated!(file_path, columns)
    parser = parser_for(file_path, IDENTITY_HEADERS + columns)
    parser.verify_headers!
  ensure
    parser.close if parser.respond_to?(:close)
  end

  def self.parser_for(file_path, required_header_names)
    Importer::Parsers.class_for(file_path).new(
      file_path:, required_header_names:, delimiter: csv_delimiter, encoding: csv_encoding,
      sheet_name:, header_row:, data_start_row:, batch_size:,
      strip_raw_value:, rich_text_headers:, max_uncompressed_bytes:
    )
  end
  private_class_method :parser_for

  attr_reader :designation, :removed_count

  # `headers_checked` is for import_all!, which has checked the headers for
  # every designation it runs already. Left out, #import! checks them itself.
  def initialize(file_path:, designation:, headers_checked: false)
    super(file_path:)
    @designation = designation
    @headers_checked = headers_checked
    @listed_ids = Set.new
    @seen_ids = Set.new
    @removed_count = 0
  end

  # The removal has to share the upsert's transaction: on its own, a failure
  # between the two would leave this designation with its new Parties added
  # and its former ones still in place.
  def import!
    check_headers! unless @headers_checked

    DesignationGeoEntity.transaction(requires_new: true) do
      super
      remove_unlisted!
    end

    # GeoEntitySearch caches geo entities with their designations, and
    # upsert_all and delete_all skip the model's after_commit that would clear
    # it. Cleared once the outermost transaction has committed - import_all!'s,
    # when run from there - so a request in between cannot cache the old Party
    # lists again; straight away when there is no transaction. Never on
    # rollback, when nothing changed.
    ActiveRecord.after_all_transactions_commit { GeoEntitySearch.increment_cache_iterator }

    self
  end

  private

  # What import_all! checks, for this designation alone: assert_unrepeated!
  # refuses a missing column as well as a repeated one.
  def check_headers!
    self.class.headers_in(file_path)
    self.class.assert_unrepeated!(file_path, [ self.class.column_for(designation) ])
    @headers_checked = true
  end

  # Every row is checked, not only the Parties: a file out of line with this
  # database is wrong wherever the misalignment happens to fall.
  def exclude_row?(row)
    geo_entity = verified_geo_entity(row)

    return true unless member?(row)

    @listed_ids << geo_entity.id
    false
  end

  def cast_designation_id(_raw_value)
    designation.id
  end

  def remove_unlisted!
    @removed_count =
      DesignationGeoEntity
        .where(designation_id: designation.id)
        .where.not(geo_entity_id: @listed_ids.to_a)
        .delete_all
  end

  def verified_geo_entity(row)
    id = Integer(row['id'].to_s.strip, 10, exception: false)

    reject!('id', "not a geo entity id: #{row['id'].inspect}") unless id
    reject!('id', "geo entity #{id} appears more than once") unless @seen_ids.add?(id)

    geo_entity = geo_entities[id]

    reject!('id', "no geo entity with id #{id}") unless geo_entity

    stated = [ row['iso_code2'].to_s.strip.presence, row['name_en'].to_s.strip, row['name'].to_s.strip ]
    actual = [ geo_entity.iso_code2.presence, geo_entity.name_en, geo_entity.geo_entity_type.name ]

    unless stated == actual
      reject!(
        'id',
        "geo entity #{id} is #{describe(*actual)}, but the file says #{describe(*stated)}"
      )
    end

    geo_entity
  end

  def member?(row)
    value = row[self.class.column_for(designation)].to_s.strip.downcase

    return true if MEMBER_VALUES.include?(value)
    return false if NON_MEMBER_VALUES.include?(value)

    reject!(self.class.column_for(designation), "not a yes/no value: #{value.inspect}")
  end

  def describe(iso_code2, name_en, type)
    "#{name_en} (#{iso_code2 || 'no ISO code'}, #{type})"
  end

  # Logged as well as raised, as Importer::Base does for its own row errors,
  # so #logs says what stopped the run.
  def reject!(column, message)
    log_error(row: @current_line_number, column:, message:)
    raise Importer::Base::ImportError, "line #{@current_line_number}: #{message}"
  end

  # Small enough to hold whole, and every row needs one.
  def geo_entities
    @geo_entities ||= GeoEntity.includes(:geo_entity_type).index_by(&:id)
  end
end
