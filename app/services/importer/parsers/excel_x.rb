require 'roo'

# Importer::Base's Excel (.xlsx)-specific file reading: sheet/ZIP validation, merged-cell
# detection, header matching, and streaming each row - implements the same each_row/
# verify_headers! contract as Importer::Parsers::Csv. See REQUIREMENTS.md/FINDINGS.md
# for the full behavior and reasoning.
#
# Rich-text/background-color extraction lives separately in
# Importer::Parsers::ExcelX::RichText, entirely opt-in - only constructed when
# rich_text_headers is declared. #each_row below is the only place the two meet.
#
# Standalone - constructible and usable with no Importer::Base subclass, no
# target_model, no file at all beyond a real .xlsx path.
class Importer::Parsers::ExcelX
  SUPPORTED_EXTENSIONS = %w[.xlsx].freeze

  # First 4 bytes of any .xlsx are the ZIP local-file-header signature (.xlsx is a zipped
  # OOXML bundle under the hood). `.b` forces ASCII-8BIT to compare raw bytes, not text.
  ZIP_SIGNATURE = "PK\x03\x04".b.freeze

  def self.validate_config!(importer_class:, header_row:, data_start_row:)
    unless header_row.is_a?(Integer) && header_row >= 1
      raise ArgumentError, "#{importer_class}: header_row must be a positive integer, got #{header_row.inspect}"
    end

    unless data_start_row.is_a?(Integer) && data_start_row >= 1
      raise ArgumentError,
        "#{importer_class}: data_start_row must be a positive integer, got #{data_start_row.inspect}"
    end

    return if data_start_row > header_row

    raise ArgumentError,
      "#{importer_class}: data_start_row (#{data_start_row}) must be after header_row (#{header_row})"
  end

  # Streaming SAX handler collecting which rows a <mergeCells> element touches, anchor row
  # included - a horizontal merge (e.g. "A1:B1") blanks a cell in its own anchor row too,
  # so no row in a merge range is safe to treat as unaffected.
  #
  # SAX, not a full DOM parse, to keep memory bounded on large sheets (see FINDINGS.md).
  #
  # Expands to one Set entry per *row*, never per cell - per-cell expansion is unbounded by
  # a wide merge (e.g. spanning all ~16,384 columns Excel allows).
  class MergedCellsHandler < Nokogiri::XML::SAX::Document
    include Importer::Parsers::ExcelX::XmlNamespaceAgnostic

    attr_reader :rows

    def initialize
      super
      @rows = Set.new
    end

    # Read the actual `ref` attribute value - don't infer anything from the element
    # merely existing.
    def start_element(name, attrs = [])
      return unless name == 'mergeCell'

      ref = attrs.to_h['ref']
      return unless ref

      start_ref, end_ref = ref.split(':')
      return unless end_ref

      start_row, = Roo::Utils.extract_coordinate(start_ref)
      end_row, = Roo::Utils.extract_coordinate(end_ref)

      (start_row..end_row).each { |row| @rows << row }
    end
  end

  # `**` absorbs the CSV-only kwargs (delimiter:, encoding:) - Importer::Base builds one
  # shared kwargs Hash for whichever parser class file_path's extension actually
  # resolves to, rather than branching on format itself.
  def initialize(file_path:, required_header_names:, sheet_name:, header_row:, data_start_row:, batch_size:, strip_raw_value:, rich_text_headers:, **)
    @file_path = file_path
    @required_header_names = required_header_names
    @sheet_name = sheet_name
    @header_row = header_row
    @data_start_row = data_start_row
    @batch_size = batch_size
    @strip_raw_value = strip_raw_value
    @rich_text_headers = rich_text_headers
  end

  # A class method too, so Importer::Base#file_format can answer from file_path alone
  # without a constructed parser - see Importer::Parsers::Csv.format.
  def self.format(_file_path) = :xlsx

  def format = self.class.format(@file_path)

  # Runs before Roo::Spreadsheet.open, which otherwise raises an unclear rubyzip error
  # deep inside itself for a file that isn't really a ZIP archive despite the .xlsx name.
  def validate_file!
    return if File.binread(@file_path, 4) == ZIP_SIGNATURE

    raise Importer::Base::ImportError,
      "#{@file_path}: not a valid .xlsx file (first 4 bytes don't match the ZIP signature)"
  end

  def verify_headers!
    assert_valid_excel_sheet!
    assert_no_merged_excel_header_row!

    actual_headers = excel_header_values.map { |header| header.to_s.strip }

    missing = @required_header_names.reject { |header| actual_headers.include?(header.to_s.strip) }

    raise Importer::Base::ImportError, "Missing required headers: #{missing.join(', ')}" if missing.any?

    duplicated = @required_header_names.select { |header| actual_headers.count(header.to_s.strip) > 1 }

    raise Importer::Base::ImportError, "Duplicate header(s) in file: #{duplicated.join(', ')}" if duplicated.any?
  end

  # Rows are handed out in batch_size-sized slices so the rich-text cache
  # (RichText#advance_through!) can be primed for a whole batch before any row in it is
  # yielded onward.
  #
  # `ensure`, not a plain trailing call: a bad cast, a merged data row, or a DB-level
  # failure raised from inside the caller's own block would otherwise skip closing the
  # rich-text file handle.
  #
  # The ivar directly, not the `rich_text` accessor: that accessor is lazy, so calling it
  # here would *build* the whole extractor (two SAX passes plus a File.open) just to close
  # it again, for a sheet whose rows never triggered it - a header-only sheet, or one that
  # raised before the first batch flushed.
  def each_row(&)
    headers = excel_header_values
    batch = []

    each_excel_row_number_and_values(from_row: @data_start_row) do |row_number, values|
      batch << [ row_number, values ]

      if batch.size >= @batch_size
        flush_batch(headers, batch, &)
        batch = []
      end
    end

    flush_batch(headers, batch, &) if batch.any?
  ensure
    (@rich_text if defined?(@rich_text))&.close!
  end

  # Lets a cast_<attribute> override read a rich_text_headers column's full formatting
  # data for the row being cast. Returns a Hash:
  #   { runs: [{ text:, bold:, italic:, strikethrough:, underline:, size:, color:,
  #              font:, vertical_align:, outline:, shadow:, condense:, extend:,
  #              font_family:, charset:, font_scheme: }, ...] or nil,
  #     background_color: nil
  #                        / { pattern_type:, fg_color:, bg_color: }
  #                        / { pattern_type: :gradient } }
  # `runs` is nil for a genuinely blank cell; `background_color` can still be set even
  # then, since a cell can be colored with no text. A cell with no rich-text run of
  # its own falls back to its own cell style's font for that one run (see
  # RichText::RichTextExtractor#apply_cell_font_fallback). `color`/`fg_color`/
  # `bg_color` share the same shape: whichever of rgb/theme/indexed/auto (plus tint)
  # OOXML recorded, not resolved to a final RGB value (see RichText.extract_color_attrs).
  #
  # Raises for a header never declared via rich_text_headers, rather than returning
  # nil - nil here would be ambiguous between "not declared" and "declared, but this
  # row/cell has no rich content".
  #
  # A bare nil (not the Hash above) also means a declared header missing from this
  # workbook's header row, or a row with no <c> element for this column at all.
  def rich_text_header_value(header, line_number)
    header = header.to_s.strip

    unless normalized_rich_text_headers.include?(header)
      raise ArgumentError, "#{header.inspect} is not declared in rich_text_headers"
    end

    column = rich_text_target_columns[header]
    return nil unless column

    rich_text&.value_for(column, line_number)
  end

  private

  # Memoized per instance - Roo::Spreadsheet.open does real file I/O and should only run
  # once per import run.
  #
  # `disable_html_wrapper: true` - without it, roo returns HTML-wrapped text for any
  # shared string with more than one run, breaking this class's contract that
  # `cast_<attribute>`'s `raw_value` is always plain text (see FINDINGS.md). Has no effect
  # on rich-text extraction, which reads the sheet/shared-strings XML directly rather
  # than roo's cell-value API.
  def excel_workbook
    @excel_workbook ||= Roo::Spreadsheet.open(@file_path, disable_html_wrapper: true)
  end

  def excel_sheet_name
    @sheet_name || excel_workbook.sheets.first
  end

  def assert_valid_excel_sheet!
    return if excel_workbook.sheets.include?(excel_sheet_name)

    raise Importer::Base::ImportError,
      "#{@file_path}: no sheet named '#{excel_sheet_name}' (available: #{excel_workbook.sheets.join(', ')})"
  end

  # The on-disk path to the current sheet's raw XML, as roo itself resolves it.
  #
  # Indexed via `sheet_files[sheets.index(name)]`, not `sheet_for(name).sheet_files` - the
  # latter delegates to a workbook-wide object and returns the same path regardless of
  # which sheet is selected, silently pointing merge detection at sheet 1 always (see
  # FINDINGS.md).
  def excel_sheet_xml_path
    excel_workbook.sheet_files[excel_workbook.sheets.index(excel_sheet_name)]
  end

  # roo's own `.row(n)`/`.last_row` eagerly load the whole sheet into memory on first
  # access (see FINDINGS.md for the measured cost). Reached here instead via the sheet's
  # internal SheetDoc (no public reader, so `instance_variable_get`), used only for
  # `#cell_from_xml` (private, via `send`) to reuse roo's own native-type resolution
  # without its eager row loading. Row/cell discovery below is this class's own, not
  # SheetDoc's streaming helpers - those don't handle two cases this class has regression
  # coverage for (see each_excel_row_number_and_values and excel_cell_values).
  def excel_sheet_doc
    @excel_sheet_doc ||= excel_workbook.sheet_for(excel_sheet_name).instance_variable_get(:@sheet)
  end

  # Every value from a raw <row> element, indexed by absolute column position (column A =
  # index 0). A genuine gap between real cells is filled with nil; a trailing gap is left
  # unpadded since Array#[] past the end already returns nil, which every caller here
  # only ever reads by index.
  #
  # A `<c>`'s `r` attribute is optional per OOXML, like `<row>`'s own - absent means "one
  # more than the previous cell's column". Built via Roo::Excelx::Coordinate directly
  # rather than roo's own each_cell/extract_coordinate, which doesn't tolerate a missing
  # `r` at all.
  def excel_cell_values(row_number, row_element)
    values = []
    last_column = 0

    row_element.children.each do |cell_element|
      next unless cell_element.element? && cell_element.name == 'c'

      column = cell_element['r'] ? Roo::Utils.extract_coordinate(cell_element['r']).column : last_column + 1
      coordinate = Roo::Excelx::Coordinate.new(row_number, column)

      (column - 1 - last_column).times { values << nil }
      # 2nd arg is the cell's hyperlink, nil for none - must be nil, not {}: {} is truthy,
      # which silently breaks every cell's value (see FINDINGS.md).
      values << excel_sheet_doc.send(:cell_from_xml, cell_element, nil, coordinate).value
      last_column = column
    end

    values
  end

  # Streams (row_number, values) for every row from `from_row` onward, one row's XML at a
  # time, via Nokogiri::XML::Reader against excel_sheet_xml_path directly - not roo's own
  # row-iteration wrapper, which has the same namespace-prefix gap noted below.
  #
  # Matches elements by local name (node.local_name) so a namespace-prefixed sheet
  # (<x:row>/<x:c>) still works, then strips namespaces from each row's own reparsed
  # fragment before reading further.
  #
  # A `<row>`'s own `r` attribute is optional per OOXML - absent means "one more than the
  # previous row's index" (next_expected_row). A `<row>` element can also be missing
  # entirely; any gap between expected and actual row numbers is filled with synthesized
  # `(row_number, [])` entries, which flow through the same blank-row handling any other
  # blank row already gets (see Importer::Base#import!).
  #
  # `File.open` block form, not a bare call: Nokogiri::XML::Reader never closes the IO
  # it's given, so each caller here (including an early `break` from excel_header_values)
  # would otherwise leak a file descriptor.
  def each_excel_row_number_and_values(from_row:)
    next_expected_row = 1

    File.open(excel_sheet_xml_path, 'rb') do |file|
      reader = Nokogiri::XML::Reader(file, nil, nil, Nokogiri::XML::ParseOptions::NOBLANKS)

      reader.each do |node|
        next unless node.node_type == Nokogiri::XML::Reader::TYPE_ELEMENT
        next unless node.local_name == 'row'

        row_element = Nokogiri::XML(node.outer_xml).tap(&:remove_namespaces!).root
        row_number = (row_element['r'] || next_expected_row.to_s).to_i

        (next_expected_row...row_number).each do |missing_row_number|
          yield(missing_row_number, []) if missing_row_number >= from_row
        end

        next_expected_row = row_number + 1
        next if row_number < from_row

        yield(row_number, excel_cell_values(row_number, row_element))
      end
    end
  end

  # The header row's own values, memoized so verify_headers!/each_row/
  # rich_text_target_columns all resolve it from the same single streaming pass. `break`
  # here stops the streaming loop as soon as the header row is reached, so this never
  # reads past it.
  def excel_header_values
    return @excel_header_values if defined?(@excel_header_values)

    values = []
    each_excel_row_number_and_values(from_row: @header_row) do |_row_number, row_values|
      values = row_values
      break
    end

    @excel_header_values = values
  end

  # Computed once per run via a single SAX pass - every row's merge check below is then a
  # cheap Set lookup, not a re-parse.
  def excel_merged_rows
    return @excel_merged_rows if defined?(@excel_merged_rows)

    handler = MergedCellsHandler.new
    Nokogiri::XML::SAX::Parser.new(handler).parse_file(excel_sheet_xml_path)
    @excel_merged_rows = handler.rows
  end

  # A merged cell in the header row leaves every non-anchor column's header text blank -
  # raised here for a clear error instead of a confusing "missing required header" one.
  def assert_no_merged_excel_header_row!
    return unless excel_merged_rows.include?(@header_row)

    raise Importer::Base::ImportError,
      "#{@file_path}: row #{@header_row} (the header row) contains a merged " \
      'cell - every non-anchor column in a merge reads back blank, which this class ' \
      'treats as an error rather than a silently missing header'
  end

  # Same treat-a-merge-as-an-error default as the header row, for consistency.
  def assert_no_merged_excel_data_row!(row_number)
    return unless excel_merged_rows.include?(row_number)

    raise Importer::Base::ImportError,
      "#{@file_path}: row #{row_number} contains a merged cell - not currently supported"
  end

  # One batch's worth of already-streamed (row_number, values) pairs, primed against the
  # rich-text cache. Batches are accumulated as rows stream in rather than pre-sliced,
  # since there's no `last_row` to slice a Range by.
  def flush_batch(headers, batch, &block)
    row_numbers = batch.map(&:first)
    rich_text&.advance_through!(row_numbers.last)

    batch.each do |row_number, values|
      assert_no_merged_excel_data_row!(row_number)

      block.call(excel_row_hash(headers, values), row_number)
    end

    rich_text&.discard_batch!(row_numbers)
  end

  # Every column in the sheet, not just the ones mapped in required_headers - same shape
  # as Importer::Parsers::Csv's own row Hash. A genuinely blank header (no merge - that
  # already raised in verify_headers!) is dropped since there's no name to key it by.
  def excel_row_hash(headers, row_values)
    headers.each_with_index.with_object({}) do |(header, index), hash|
      header = header.to_s.strip
      next if header.blank?

      hash[header] = apply_strip(row_values[index])
    end
  end

  def apply_strip(value)
    @strip_raw_value && value.is_a?(String) ? value.strip : value
  end

  # rich_text_headers normalized exactly once, the same way, everywhere it's compared
  # against a lookup - a symbol or untrimmed declaration (e.g. `[:Notes]`) must
  # resolve the same column both during extraction and here.
  def normalized_rich_text_headers
    @normalized_rich_text_headers ||= @rich_text_headers.map { |header| header.to_s.strip }
  end

  # Resolves each declared rich_text_headers entry to its 1-based column index, by
  # position in the header row (same convention as excel_row_hash above). A declared
  # header not present in this workbook is left out of the resulting Hash;
  # rich_text_header_value returns nil for it.
  #
  # `index + 1` alone is correct here since excel_header_values is already
  # absolute-column-indexed (index 0 = column A, regardless of the sheet's used
  # range) - matching RichText::RichTextExtractor's absolute `r="B1"`-style cell
  # references.
  def rich_text_target_columns
    return @rich_text_target_columns if defined?(@rich_text_target_columns)
    return @rich_text_target_columns = {} if @rich_text_headers.blank?

    columns_by_header =
      excel_header_values.each_with_index.with_object({}) do |(header, index), hash|
        next if header.blank?

        hash[header.to_s.strip] = index + 1
      end

    @rich_text_target_columns =
      normalized_rich_text_headers.each_with_object({}) do |header, hash|
        column = columns_by_header[header]
        hash[header] = column if column
      end
  end

  # nil (not a fresh, empty extractor) when no rich_text_headers are declared - so an
  # importer that never uses the feature pays no cost: no file handle, no SAX parser,
  # no shared-string/styles read.
  def rich_text
    return @rich_text if defined?(@rich_text)
    return @rich_text = nil if rich_text_target_columns.empty?

    @rich_text =
      Importer::Parsers::ExcelX::RichText.new(
        sheet_xml_path: excel_sheet_xml_path, target_columns: rich_text_target_columns.values.to_set
      )
  end
end
