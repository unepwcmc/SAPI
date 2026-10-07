require 'csv'
require 'bigdecimal'

# Base class for bulk-seeding a single ActiveRecord model from a source file (CSV, TSV,
# zipped CSV, or Excel). See README.md for the full picture (modes, config macros, file format
# rules), REQUIREMENTS.md for the detailed per-mode behavior, and FINDINGS.md for the
# reasoning and evidence behind the non-obvious decisions - not repeated here. Subclass
# and declare `target_model`, `mode`, and `required_headers`; see
# Importers::PostInsertImporter / Importers::PostUpsertImporter (app/services/importers/)
# for a minimal example of each mode.
#
# ---------------------------------------------------------------------------------------
# Where one row goes. This class orchestrates; it does no parsing, casting or writing
# itself, so following a single row means moving between four objects. Read this first -
# it is the map the old single-class version didn't need:
#
#   import!                              base.rb  - builds the three collaborators, opens
#                                                   the transaction, owns the row loop
#     |
#     +-- parser.each_row                parsers/csv.rb or parsers/excel_x.rb
#     |     yields EVERY row, unconditionally. Decides nothing - no blank check, no
#     |     exclude_row?. Picked by file_path's extension (parsers.rb).
#     |
#     +-- (back in import!'s own loop)   base.rb
#     |     sets @current_row/@current_line_number, then drop_blank_rows, then
#     |     exclude_row? - in that order, so a hook reading raw_header_value sees its
#     |     own row (FINDINGS.md).
#     |
#     +-- build_attributes               row_transformer.rb
#     |     header -> attribute -> cast. Dispatches cast_<attribute> back to the
#     |     subclass through `host` (which is this instance) - that backreference is why
#     |     a subclass's own cast_ method still works from a separate object.
#     |
#     +-- flush_batch                    base.rb -> loaders/*.rb
#           before_batch hook, then loader.write_batch(batch) -> {written:, skipped:},
#           then after_batch. Which loader is picked by `mode` (loaders.rb).
#
#   after the transaction commits: loader.reset_pk_sequence!, then log_summary -> logger.rb
#
# The trade this shape makes, stated plainly: each file is smaller and independently
# testable, but following one row end to end now crosses four of them. See FINDINGS.md's
# 2.0.0 section for why that was judged worth it, and for the four remaining edges back
# to this class.
# ---------------------------------------------------------------------------------------
class Importer::Base
  class ImportError < StandardError; end

  # See README.md's Modes section. Every subclass must declare one via `mode`, even
  # while not all four are implemented yet, so adding a mode later is purely additive.
  SUPPORTED_MODES = %i[raw_insert_all raw_upsert_all activerecord activerecord_import].freeze

  # The only values `on_failure` (concerns/config.rb) accepts at all, regardless of
  # mode - see assert_on_failure_supported! below for the further per-mode restriction.
  SUPPORTED_ON_FAILURE_VALUES = %i[rollback skip].freeze

  include Importer::Concerns::Hooks

  SUPPORTED_FILE_EXTENSIONS = (
    Importer::Parsers::Csv::SUPPORTED_EXTENSIONS + Importer::Parsers::ExcelX::SUPPORTED_EXTENSIONS +
    Importer::Parsers::ZippedCsv::SUPPORTED_EXTENSIONS
  ).freeze

  # The config macros (target_model, mode, unique_by, etc.) are class methods, so this
  # is `extend`, not `include` - see Importer::Concerns::Config.
  extend Importer::Concerns::Config

  attr_reader :file_path

  def initialize(file_path:)
    @file_path = file_path
    @logger = Importer::Logger.new
    @processed_count = 0
    @written_count = 0
    @skipped_count = 0
    @excluded_count = 0
    @current_row = nil
    @current_line_number = nil
  end

  def logs = @logger.entries

  def import!
    assert_configured!
    assert_supported_file_extension!
    parser.validate_file! unless self.class.skip_file_validation
    parser.verify_headers!

    batch = []

    # target_model's own connection, not ActiveRecord::Base's - they differ whenever
    # target_model uses connects_to for a non-default connection, and only
    # target_model's connection is guaranteed to be the one this run actually writes to.
    self.class.target_model.transaction(requires_new: true) do
      parser.each_row do |row, line_number|
        # Set before exclude_row? runs, so an override calling raw_value_for/
        # raw_header_value/rich_text_header_value sees the row it was called for.
        @current_row = row
        @current_line_number = line_number

        # Uses considered_blank?, not value.blank? - `false.blank?` is true, which
        # would silently drop a row whose only non-blank cell is a `false` boolean.
        next if self.class.drop_blank_rows && row.values.all? { |value| Importer::RowTransformer.considered_blank?(value) }

        if exclude_row?(row)
          @excluded_count += 1
          next
        end

        @processed_count += 1
        batch << { line_number: line_number, attrs: build_attributes(row, line_number), row: row }

        if batch.size >= self.class.batch_size
          flush_batch(batch)
          batch = []
        end
      end

      flush_batch(batch)
    end

    # Rescued, not left to propagate: this runs after the transaction above has already
    # committed, so a failure here shouldn't make import! report an already-durable run
    # as failed (see FINDINGS.md for the accepted risk this leaves in place).
    begin
      loader.reset_pk_sequence!
    rescue StandardError => e
      log_warning(message: "primary key sequence resync failed after a successful import: #{e.message}")
    end

    log_summary

    self
  ensure
    parser&.close if parser.respond_to?(:close)
  end

  private

  # A deliberate test/debug seam, not a design smell - the handful of specs that need
  # to reach loader/parser-owned state (e.g. activerecord_import_upsert_option,
  # excel_sheet_xml_path) go through this rather than instance_variable_get.
  attr_reader :loader, :parser, :row_transformer

  def log_error(...) = @logger.error(...)
  def log_warning(...) = @logger.warning(...)
  def log_summary = @logger.summary(processed: @processed_count, written: @written_count, skipped: @skipped_count, excluded: @excluded_count)

  # Resolved from file_path's own extension, not from @parser, so this answers correctly
  # even before assert_configured! has built one - otherwise calling it early failed with
  # a bare `NoMethodError: private method 'format' called for nil` (nil picking up
  # Kernel#format), naming neither this method nor the importer.
  #
  # Once the parser exists it is asked instead, because only it can see inside a .zip to
  # tell a zipped .csv from a zipped .tsv - the path alone can't.
  def file_format = @parser ? @parser.format : Importer::Parsers.class_for(file_path).format(file_path)
  def excel_file? = file_format == :xlsx

  # Lets a cast_<attribute> override read a rich_text_headers column's full formatting
  # data for the row being cast - see Importer::Parsers::ExcelX#rich_text_header_value
  # for the full return shape. nil outright for a non-.xlsx import, never delegated -
  # Importer::Parsers::Csv doesn't implement this method at all.
  def rich_text_header_value(header)
    return nil unless excel_file?

    parser.rich_text_header_value(header, @current_line_number)
  end

  # Lets a cast_<attribute> override read another declared column's raw value by
  # attribute name. Resolves attribute -> header, then delegates to raw_header_value;
  # raises on a typo/unmapped attribute (raw_header_value deliberately does not).
  def raw_value_for(attribute)
    header = self.class.required_headers.key(attribute)

    raise ArgumentError, "#{attribute.inspect} is not in required_headers" unless header

    raw_header_value(header)
  end

  # Lets a cast_<attribute> override read any column's raw value by exact header text,
  # not just one mapped in required_headers. A header not actually in the file returns
  # nil (plain Hash#[]) rather than raising - unlike raw_value_for, there's no fixed
  # header list to validate a typo against.
  def raw_header_value(header)
    @current_row[header.to_s.strip]
  end

  # after_batch is the only place :primary_key_value can be read from, so with the no-op
  # stub still in place the loader can skip resolving it entirely (see
  # Importer::Loaders::Base#initialize). `.owner`, not respond_to?: every subclass
  # responds to after_batch via that stub, so comparing the owning module is what
  # distinguishes "overridden" from "inherited" - and it stays correct for an override
  # defined on an intermediate parent class rather than the leaf subclass.
  def after_batch_overridden?
    self.class.instance_method(:after_batch).owner != Importer::Concerns::Hooks
  end

  def assert_supported_file_extension!
    return if SUPPORTED_FILE_EXTENSIONS.include?(File.extname(file_path).downcase)

    raise ImportError,
      "#{file_path}: file must have one of these extensions: #{SUPPORTED_FILE_EXTENSIONS.join(', ')}"
  end

  def build_attributes(row, line_number)
    row_transformer.build_attributes(row, line_number, primary_key_attribute: loader.primary_key_attribute)
  end

  # `return if batch.empty?` guards before_batch/write_batch/after_batch together - a
  # phantom empty trailing batch (row count divides evenly by batch_size) shouldn't
  # reach any of them.
  def flush_batch(batch)
    return if batch.empty?

    before_batch(batch)
    result = loader.write_batch(batch)
    @written_count += result[:written]
    @skipped_count += result[:skipped]
    after_batch(batch)
  end

  def assert_configured!
    raise ArgumentError, "#{self.class} must declare `target_model`" unless self.class.target_model
    raise ArgumentError, "#{self.class} must declare `required_headers`" if self.class.required_headers.blank?
    raise ArgumentError, "#{self.class} must declare `mode`" unless self.class.mode

    unless SUPPORTED_MODES.include?(self.class.mode)
      raise ArgumentError,
        "#{self.class}: unsupported mode `#{self.class.mode}` (supported: #{SUPPORTED_MODES.join(', ')})"
    end

    loader_class = Importer::Loaders.class_for(self.class.mode)

    assert_attributes_are_writable!(loader_class)

    # Constructing the row transformer is what validates derived_attributes/
    # resolve_belongs_to declarations - see Importer::RowTransformer#validate!.
    @row_transformer =
      Importer::RowTransformer.new(
        importer_class: self.class, target_model: self.class.target_model, required_headers: self.class.required_headers,
        derived_attributes: self.class.derived_attributes, belongs_to_lookups: self.class.belongs_to_lookups, host: self, logger: @logger
      )
    @row_transformer.validate!

    raise ArgumentError, "#{self.class} must declare `unique_by`" if self.class.mode == :raw_upsert_all && self.class.unique_by.blank?

    assert_on_failure_supported!(loader_class)

    # Both parser families' config macros are validated unconditionally, regardless of
    # which one file_path's own extension will actually select - matching this
    # format's pre-refactor behavior (a .xlsx subclass with a bad csv_delimiter still
    # raises at config time, and vice versa).
    Importer::Parsers::Csv.validate_config!(importer_class: self.class, delimiter: self.class.csv_delimiter, encoding: self.class.csv_encoding)
    Importer::Parsers::ExcelX.validate_config!(importer_class: self.class, header_row: self.class.header_row, data_start_row: self.class.data_start_row)

    Importer::Parsers::ZippedCsv.validate_config!(importer_class: self.class, max_uncompressed_bytes: self.class.max_uncompressed_bytes)

    # Constructing the loader is what resolves+validates unique_by (and, for
    # activerecord_import, its own two extra checks) - see FINDINGS.md.
    @loader =
      loader_class.new(
        importer_class: self.class, target_model: self.class.target_model, on_failure: self.class.on_failure,
        allow_primary_key_write: self.class.allow_primary_key_write, unique_by: self.class.unique_by,
        written_attributes: self.class.written_attributes, host: self, logger: @logger,
        resolve_primary_keys: after_batch_overridden?
      )

    assert_primary_key_write_protected!

    @parser =
      Importer::Parsers.class_for(file_path).new(
        file_path: file_path, required_header_names: self.class.required_headers.keys, delimiter: self.class.csv_delimiter,
        encoding: self.class.csv_encoding, sheet_name: self.class.sheet_name, header_row: self.class.header_row,
        data_start_row: self.class.data_start_row, batch_size: self.class.batch_size, strip_raw_value: self.class.strip_raw_value,
        rich_text_headers: self.class.rich_text_headers,
        max_uncompressed_bytes: self.class.max_uncompressed_bytes
      )
  end

  # Raw modes (and activerecord_import) write real SQL columns only - neither ever
  # instantiates a model per row, so a virtual writer method has nothing to run against.
  # Only :activerecord does, so it's the only mode a hand-written `def slug=` works for.
  #
  # `attribute_names.include?`, not `method_defined?`: Rails only defines a column's
  # actual writer method lazily, on first instantiation, so attribute_names (schema-
  # driven) is used instead.
  def assert_attributes_are_writable!(loader_class)
    target_model = self.class.target_model

    self.class.written_attributes.each do |attribute|
      valid =
        if loader_class.supports_virtual_attributes?
          target_model.attribute_names.include?(attribute.to_s) || target_model.method_defined?("#{attribute}=")
        else
          target_model.column_names.include?(attribute.to_s)
        end

      next if valid

      reason = loader_class.supports_virtual_attributes? ? 'no such attribute or writer method' : "#{self.class.mode} mode writes real columns only"

      raise ArgumentError, "#{self.class}: '#{attribute}' is not writable on #{target_model} (#{reason})"
    end
  end

  # Without the first check below, an unrecognized on_failure value (a typo) was silently
  # accepted for a model-backed mode and behaved exactly like :rollback at runtime -
  # inconsistent with the documented :rollback | :skip contract, and never an error a
  # subclass would see at config time (see FINDINGS.md).
  def assert_on_failure_supported!(loader_class)
    unless SUPPORTED_ON_FAILURE_VALUES.include?(self.class.on_failure)
      raise ArgumentError,
        "#{self.class}: on_failure must be one of #{SUPPORTED_ON_FAILURE_VALUES.map(&:inspect).join(' or ')}, " \
        "got #{self.class.on_failure.inspect}"
    end

    return if self.class.on_failure == :rollback
    return if loader_class.supports_on_failure_skip?

    raise ArgumentError,
      "#{self.class}: on_failure :skip is not supported by #{self.class.mode} mode (see README.md's Modes section)"
  end

  # allow_primary_key_write gates *writing* a caller-supplied primary key value, not
  # mapping/looking it up - blocks here only when there's no lookup step to fall back on
  # (no lookup mechanism at all, or one not keyed on the primary key). When unique_by does
  # resolve to the primary key on a mode with a lookup step, protection is enforced
  # per-row at runtime instead (see Importer::Loaders::Base).
  #
  # written_attributes, not required_headers.values: a primary key from a derived
  # attribute's cast_ method is just as caller-supplied as one read from a column.
  def assert_primary_key_write_protected!
    return if self.class.allow_primary_key_write

    pk = self.class.target_model.primary_key&.to_sym
    return unless pk
    return unless self.class.written_attributes.map(&:to_sym).include?(pk)
    return if loader.class.primary_key_lookup_mode? && loader.unique_by_config.columns == [ pk ]

    raise ArgumentError,
      "#{self.class}: '#{pk}' is the primary key on #{self.class.target_model} - writing it (mapping it " \
      'in required_headers, or declaring it in derived_attributes) without allow_primary_key_write true ' \
      'is only safe when unique_by resolves to the primary key itself, on a mode with a lookup step ' \
      "(not #{self.class.mode}'s case here). Declare `allow_primary_key_write true` to opt in to " \
      'writing it directly instead.'
  end
end
