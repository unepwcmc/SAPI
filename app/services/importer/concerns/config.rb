# Importer::Base's class-level configuration macros (target_model, mode, unique_by,
# etc.), checked later by Importer::Base#assert_configured!. Mixed in via `extend`
# since these are class methods.
#
# `inherited` below is load-bearing: a class-level ivar like @target_model has no
# inheritance mechanism of its own in Ruby - each Class has separate ivar storage.
# Copying every ivar down (rather than listing macros by name) means this never needs
# updating when a new macro is added.
module Importer::Concerns::Config
  def inherited(subclass)
    super
    instance_variables.each { |ivar| subclass.instance_variable_set(ivar, instance_variable_get(ivar)) }
  end

  def target_model(klass = nil)
    @target_model = klass if klass
    @target_model
  end

  def required_headers(mapping = nil)
    @required_headers = mapping if mapping
    @required_headers
  end

  # Attributes written on every row with no source column - their value comes entirely
  # from the subclass's own cast_<attribute> override (called with nil, since there's no
  # raw value). Everything a mapped attribute gets, a derived one gets too - see
  # written_attributes below. cast_<attribute> is required to exist
  # (Importer::RowTransformer#validate!), since the default caster handed nil would
  # return nil and silently write NULL.
  def derived_attributes(list = nil)
    @derived_attributes = Array(list) if list
    @derived_attributes || []
  end

  # Declares that a mapped foreign-key attribute holds a natural key in the source file,
  # not a database id, and should be resolved to one: `resolve_belongs_to :organization_id,
  # by: :slug` means "this column is an Organization's slug - look up its id".
  #
  # `attribute` is the foreign key itself, not the association name - the associated model
  # is read from target_model's own belongs_to reflection for that foreign key, never
  # inferred by stripping `_id`. `by` is the column to match against; both checked at
  # config time (Importer::RowTransformer#validate!). See Importer::RowTransformer for
  # lookup/caching and blank/miss handling.
  def resolve_belongs_to(attribute, by:)
    @belongs_to_lookups = belongs_to_lookups.merge(attribute.to_sym => by.to_sym)
  end

  # The resolvers declared above, as {foreign_key_attribute => key_column}.
  def belongs_to_lookups(mapping = nil)
    @belongs_to_lookups = mapping if mapping
    @belongs_to_lookups || {}
  end

  # Every attribute this importer writes, mapped or derived. Config-time checks read this
  # rather than required_headers directly, so a derived attribute isn't silently exempt.
  def written_attributes
    (required_headers || {}).values + derived_attributes
  end

  def mode(value = nil)
    @mode = value if value
    @mode
  end

  def batch_size(size = nil)
    @batch_size = size if size
    @batch_size || 1_000
  end

  # Required for :raw_upsert_all only - column(s) or index name Postgres uses to detect
  # a duplicate row (same forms Rails' own upsert_all accepts). Must be a real unique
  # index, checked up front in assert_configured! rather than left to fail on first write.
  def unique_by(columns = nil)
    @unique_by = columns if columns
    @unique_by
  end

  # :rollback (default) or :skip - what happens when a single row fails. Only
  # :activerecord supports :skip (README.md); declaring it on a mode that doesn't
  # raises at config time rather than silently having no effect.
  def on_failure(behavior = nil)
    @on_failure = behavior if behavior
    @on_failure || :rollback
  end

  # Strips leading/trailing whitespace from every raw value before any cast sees it, by
  # default. Disable with `strip_raw_value false` when surrounding whitespace is
  # meaningful. Only strips String values, so a native Excel type (Date/Integer) is
  # left untouched.
  #
  # `unless enabled.nil?` (not `if enabled`) is deliberate: `false` is a legitimate
  # value here, unlike most other macros - `if enabled` would silently ignore
  # `strip_raw_value false`.
  def strip_raw_value(enabled = nil)
    @strip_raw_value = enabled unless enabled.nil?
    @strip_raw_value.nil? ? true : @strip_raw_value
  end

  # A fully blank line is silently skipped by default rather than written as an
  # all-NULL row. Skipped rows don't count toward processed_count or #logs. Disable
  # with `drop_blank_rows false` to treat a blank row as real.
  def drop_blank_rows(enabled = nil)
    @drop_blank_rows = enabled unless enabled.nil?
    @drop_blank_rows.nil? ? true : @drop_blank_rows
  end

  # Column separator for .csv only - comma by default, semicolon if declared. A .tsv
  # file always uses tab regardless (see Importer::Parsers::Csv#col_sep). Restricted to
  # comma/semicolon (Importer::Parsers::Csv.validate_config!).
  def csv_delimiter(value = nil)
    @csv_delimiter = value if value
    @csv_delimiter || ','
  end

  # The source file's own encoding, for a .csv/.tsv from somewhere that isn't UTF-8
  # (e.g. Windows-1252). nil (default) means "assume UTF-8" - the current behavior.
  # When set, every row is transcoded to UTF-8 on the way in (see Importer::Parsers::Csv);
  # the caller only ever names the source, never the target. Validated against Ruby's own
  # known encodings at config time (Importer::Parsers::Csv.validate_config!).
  def csv_encoding(value = nil)
    @csv_encoding = value if value
    @csv_encoding
  end

  # Ceiling, in bytes, on the uncompressed size of the CSV/TSV inside a .zip - only for
  # .zip. Default Importer::Parsers::ZippedCsv::DEFAULT_MAX_UNCOMPRESSED_BYTES (512 MB).
  # A disk guard against a zip bomb, since the entry is extracted to a tempfile; it has no
  # bearing on memory, which rows already bound. Must be a positive Integer
  # (Importer::Parsers::ZippedCsv.validate_config!).
  def max_uncompressed_bytes(value = nil)
    @max_uncompressed_bytes = value if value
    @max_uncompressed_bytes || Importer::Parsers::ZippedCsv::DEFAULT_MAX_UNCOMPRESSED_BYTES
  end

  # Gates whether a caller-supplied primary key can be *written* (to insert a new row) -
  # not whether it can be looked up, which is always allowed (see Importer::Loaders::Base and
  # REQUIREMENTS.md's Primary key section). Default false: an unmatched primary key
  # raises rather than risking a collision with a future auto-generated id.
  # `raw_insert_all`/`raw_copy` have no lookup step, so mapping the primary key while
  # this is false raises at config time instead (see
  # Importer::Base#assert_primary_key_write_protected!).
  def allow_primary_key_write(enabled = nil)
    @allow_primary_key_write = enabled unless enabled.nil?
    @allow_primary_key_write.nil? ? false : @allow_primary_key_write
  end

  # Which sheet to read, by name - only for .xlsx. Defaults to the workbook's first
  # sheet. Validated against the workbook's actual sheet names at runtime
  # (Importer::Parsers::ExcelX).
  def sheet_name(value = nil)
    @sheet_name = value if value
    @sheet_name
  end

  # Which row is the real header row, 1-indexed like Excel. Only for .xlsx.
  def header_row(value = nil)
    @header_row = value if value
    @header_row || 1
  end

  # Which row data starts on - defaults to header_row + 1, independently overridable
  # (e.g. a blank spacer row between header and data). Only for .xlsx.
  def data_start_row(value = nil)
    @data_start_row = value if value
    @data_start_row || (header_row + 1)
  end

  # Skips the whole-file structural check (the parser's own validate_file! - a UTF-8 scan
  # for .csv/.tsv, a ZIP-signature check for .xlsx)
  # - never header verification, which always still runs. Default false. Meant for
  # several importer subclasses processing the identical file_path in one request/job,
  # where an earlier pass already paid for the check. Declaring this without a
  # guaranteed prior validated pass is a footgun: it only defers a bad-file failure, it
  # doesn't remove it, and the error surfaced is less clear (a raw parser error instead
  # of Importer::Base::ImportError).
  def skip_file_validation(enabled = nil)
    @skip_file_validation = enabled unless enabled.nil?
    @skip_file_validation.nil? ? false : @skip_file_validation
  end

  # Columns needing per-run rich-text (bold/italic) fidelity, by exact header text -
  # same convention as raw_header_value, not required_headers' header->attribute
  # mapping. Declared upfront since Importer::Parsers::ExcelX's batched extraction needs every
  # target column before the SAX stream starts. Only for .xlsx.
  def rich_text_headers(headers = nil)
    @rich_text_headers = headers if headers
    @rich_text_headers || []
  end
end
