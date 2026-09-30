# Importer::Base's CSV-specific file reading: encoding validation, header matching, and
# streaming each row. Importer::Parsers::ExcelX is the sibling parser for worksheets,
# implementing the same each_row/verify_headers! contract.
#
# .tsv is parsed here too, via the same CSV gem with `col_sep: "\t"` - a config
# difference, not a different format.
#
# #each_row yields a plain Hash (stripped header -> raw value), not a CSV::Row, so
# downstream code doesn't care which file format produced it - Parsers::ExcelX#each_row
# produces the same shape. Always has every column in the file, not just required_headers
# ones. Row filtering (blank rows, exclude_row?) is not this class's job - it yields
# every row unconditionally; Importer::Base's own loop decides what to keep.
#
# Standalone - constructible and usable with no Importer::Base subclass, no
# target_model, no file at all beyond a real CSV/TSV path.
#
# ImportError is referenced fully qualified (Importer::Base::ImportError) - a bare
# constant here resolves via this class's own lexical nesting, not Importer::Base's.
#
# Named Csv, not CSV: Zeitwerk camelizes csv.rb to Csv, so spelling the class CSV would
# require a global `inflect.acronym 'CSV'` in every app vendoring this engine - a host-app
# change outside this directory and outside the checksum's reach, whose absence surfaces
# as an unexplained NameError at boot. Matches Importer::Loaders::ActiverecordImport,
# named the same way for the same reason. The lowercase name also keeps a bare `CSV` in
# this file unambiguously the stdlib's.
class Importer::Parsers::Csv
  SUPPORTED_EXTENSIONS = %w[.csv .tsv].freeze
  SUPPORTED_DELIMITERS = [ ',', ';' ].freeze

  def self.validate_config!(importer_class:, delimiter:, encoding:)
    unless SUPPORTED_DELIMITERS.include?(delimiter)
      raise ArgumentError,
        "#{importer_class}: csv_delimiter must be one of #{SUPPORTED_DELIMITERS.map(&:inspect).join(' or ')}, " \
        "got #{delimiter.inspect}"
    end

    validate_encoding!(importer_class:, encoding:)
  end

  # nil (the default, "assume UTF-8") is always valid, and so is UTF-8 itself declared
  # explicitly (under any alias - Encoding.find normalizes them) - Ruby doesn't register
  # a UTF-8-to-UTF-8 transcoder at all (Encoding::Converter.new('UTF-8', 'UTF-8') raises
  # ConverterNotFoundError even though nothing needs converting), so that case is
  # short-circuited rather than treated as invalid. Otherwise, tries building the actual
  # converter this class will use (source -> UTF-8) - the same check String#encode/
  # CSV.open would do lazily on the first row, just run at config time so an unknown/
  # misspelled encoding name fails immediately, not partway through a run.
  #
  # Its own method, not inlined into validate_config! - a rescue scoped to the whole
  # method would otherwise also catch the delimiter check's own ArgumentError above and
  # misreport it as an encoding problem (verified directly - a real bug this shape avoids).
  def self.validate_encoding!(importer_class:, encoding:)
    return if encoding.nil?
    return if Encoding.find(encoding) == Encoding::UTF_8

    Encoding::Converter.new(encoding, 'UTF-8')
  rescue ArgumentError, Encoding::ConverterNotFoundError
    raise ArgumentError, "#{importer_class}: csv_encoding #{encoding.inspect} is not a known encoding Ruby can convert to UTF-8"
  end

  # `**` absorbs the Excel-only kwargs (sheet_name:, header_row:, etc.) - Importer::Base
  # builds one shared kwargs Hash for whichever parser class file_path's extension
  # actually resolves to, rather than branching on format itself.
  def initialize(file_path:, required_header_names:, delimiter:, encoding:, strip_raw_value:, **)
    @file_path = file_path
    @required_header_names = required_header_names
    @delimiter = delimiter
    @encoding = encoding
    @strip_raw_value = strip_raw_value
  end

  # A class method as well as an instance one: the answer depends only on the extension,
  # so Importer::Base#file_format can resolve it from file_path alone, before (or without)
  # ever constructing a parser.
  def self.format(file_path)
    File.extname(file_path).downcase == '.tsv' ? :tsv : :csv
  end

  def format = self.class.format(@file_path)

  # Runs as its own pass before any row is cast or written, so a bad file fails cheaply
  # rather than partway through an expensive import. File.foreach streams the file
  # (bounded memory), and Ruby's IO decoder is boundary-aware, so a multi-byte character
  # split across read buffers isn't mistaken for invalid input.
  #
  # Two different checks depending on the declared encoding, not one: plain 'bom|utf-8'
  # only tags a line as UTF-8, it doesn't raise on a bad byte, so validity needs its own
  # explicit check. A declared (non-UTF-8) encoding is a real transcode - Ruby itself
  # raises (EncodingError) the moment a byte doesn't fit the declared source encoding, so
  # reading the file through once already is the check.
  def validate_file!
    effective_utf8? ? validate_default_utf8! : validate_declared_encoding!
  end

  # Headers matched with whitespace stripped from both sides - stray spaces in a source
  # file's header row shouldn't be treated as a missing column.
  #
  # Also rejects a required header appearing more than once: CSV::Row#[] silently returns
  # only the first matching column when headers are duplicated. Non-required duplicate
  # headers aren't caught here (row_hash below lets the second one silently win).
  #
  # &:shift is CSV#shift - does not read the whole file, just one buffered chunk (~32KB)
  # to parse the first row, then closes.
  def verify_headers!
    actual_headers = CSV.open(@file_path, encoding: encoding_option, col_sep: col_sep, &:shift) || []
    normalized_headers = actual_headers.map { |header| header.to_s.strip }

    missing = @required_header_names.reject { |header| normalized_headers.include?(header.to_s.strip) }

    raise Importer::Base::ImportError, "Missing required headers: #{missing.join(', ')}" if missing.any?

    duplicated = @required_header_names.select { |header| normalized_headers.count(header.to_s.strip) > 1 }

    raise Importer::Base::ImportError, "Duplicate header(s) in file: #{duplicated.join(', ')}" if duplicated.any?
  end

  # `line_number` tracks the real physical line, not just the record count: a quoted
  # field with a literal newline (legal CSV, RFC 4180) spans 2+ physical lines in one
  # CSV::Row, so a plain per-row counter drifts. Recovered by counting the embedded
  # newlines already present in each field's parsed value, no second read needed.
  def each_row(&block)
    line_number = 1

    CSV.foreach(@file_path, headers: true, encoding: encoding_option, col_sep: col_sep) do |csv_row|
      line_number += 1

      block.call(row_hash(csv_row), line_number)

      line_number += embedded_newline_count(csv_row)
    end
  end

  private

  # .tsv always means tab, not configurable - the extension is the only signal. A
  # declared delimiter only applies to a .csv file; irrelevant, not conflicting, for
  # .tsv since file_path is per-instance.
  def col_sep
    format == :tsv ? "\t" : @delimiter
  end

  def effective_utf8?
    @encoding.nil? || Encoding.find(@encoding) == Encoding::UTF_8
  end

  # 'bom|utf-8' whenever the effective source encoding is UTF-8 - the no-op default, but
  # also a declared encoding of UTF-8 itself (under any of its aliases) - so a BOM is
  # always sniffed and stripped rather than only when no encoding is declared.
  # `"source:UTF-8"` alone has no BOM awareness at all - verified directly that it bakes
  # the BOM's bytes into the first header as a literal U+FEFF character instead of
  # stripping it, breaking required-header matching for whichever column is first.
  def encoding_option
    effective_utf8? ? 'bom|utf-8' : "#{@encoding}:UTF-8"
  end

  def validate_default_utf8!
    line_number = 0

    File.foreach(@file_path, encoding: encoding_option) do |line|
      line_number += 1

      next if line.valid_encoding?

      raise Importer::Base::ImportError, "Invalid UTF-8 encoding at line #{line_number} of #{@file_path}"
    end
  end

  def validate_declared_encoding!
    line_number = 0

    File.foreach(@file_path, encoding: encoding_option) { line_number += 1 }
  rescue EncodingError => e
    raise Importer::Base::ImportError,
      "Invalid #{@encoding} encoding at line #{line_number + 1} of #{@file_path}: #{e.message}"
  end

  # `\r\n|\r|\n`, not `.count("\n")` - CSV auto-detects all three row separators
  # (row_sep: :auto), including bare-CR (classic Mac), which has no `\n` at all and
  # would undercount to 0.
  def embedded_newline_count(csv_row)
    csv_row.fields.sum { |field| field.to_s.scan(/\r\n|\r|\n/).size }
  end

  # Every column in the file, keyed by stripped header text. A column with no header at
  # all (more data fields than header columns) is dropped via `.compact`.
  def row_hash(csv_row)
    csv_row.headers.compact.each_with_object({}) do |header, hash|
      hash[header.to_s.strip] = apply_strip(csv_row[header])
    end
  end

  def apply_strip(value)
    @strip_raw_value && value.is_a?(String) ? value.strip : value
  end
end
