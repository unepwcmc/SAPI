require 'roo'

# Importer::Parsers::ExcelX's rich-text and per-cell background-color extraction -
# entirely opt-in (only constructed when rich_text_headers is declared - see
# Importer::Parsers::ExcelX#rich_text). A second, independent SAX reader over the same
# sheet XML Importer::Parsers::ExcelX itself streams, keyed by row number, primed per
# batch via #advance_through!/#discard_batch! (called from
# Importer::Parsers::ExcelX#each_row).
#
# See REQUIREMENTS.md and FINDINGS.md for full behavior and reasoning.
class Importer::Parsers::ExcelX::RichText
  # A <color> element identifies color one of four mutually exclusive ways: `rgb` hex,
  # a `theme` or `indexed` palette index, or `auto`. `tint` optionally lightens/
  # darkens whichever is used. theme/indexed are not resolved to an actual RGB value
  # here (would require parsing theme1.xml / the legacy indexed palette) - the raw
  # attribute(s) are returned as-is. Shared by RunCapture and StylesHandler. `auto` is
  # an XML Schema boolean; both "1" and "true" are valid spellings.
  AUTO_COLOR_VALUES = %w[1 true].freeze

  def self.extract_color_attrs(attrs)
    color = {}
    color[:rgb] = attrs['rgb'] if attrs['rgb']
    color[:theme] = attrs['theme'].to_i if attrs['theme']
    color[:indexed] = attrs['indexed'].to_i if attrs['indexed']
    color[:tint] = attrs['tint'].to_f if attrs['tint']
    color[:auto] = true if AUTO_COLOR_VALUES.include?(attrs['auto'])
    color.presence
  end

  # XML Schema boolean lexical space is {"true", "false", "1", "0"} - both forms valid.
  FALSE_VALUES = %w[0 false].freeze

  # val="none" (<u>, <scheme>) and val="baseline" (<vertAlign>) are valid OOXML
  # spellings of "no formatting" - must not be treated as truthy values.
  NO_UNDERLINE_VALUES = %w[none].freeze
  NO_VERTICAL_ALIGN_VALUES = %w[baseline].freeze
  NO_FONT_SCHEME_VALUES = %w[none].freeze

  # Formatting-property dispatch shared by RunCapture (a run's <rPr>) and
  # StylesHandler (a standalone <font> in styles.xml) - font name is spelled <rFont>
  # in the former, <name> in the latter; otherwise identical.
  def self.apply_formatting_property(target, name, attrs)
    case name
    when 'b' then target[:bold] = FALSE_VALUES.exclude?(attrs['val'])
    when 'i' then target[:italic] = FALSE_VALUES.exclude?(attrs['val'])
    when 'strike' then target[:strikethrough] = FALSE_VALUES.exclude?(attrs['val'])
    when 'outline' then target[:outline] = FALSE_VALUES.exclude?(attrs['val'])
    when 'shadow' then target[:shadow] = FALSE_VALUES.exclude?(attrs['val'])
    when 'condense' then target[:condense] = FALSE_VALUES.exclude?(attrs['val'])
    when 'extend' then target[:extend] = FALSE_VALUES.exclude?(attrs['val'])
    # Absent val means "single" underline per OOXML default, not "no underline" -
    # same as bare <b/> meaning bold.
    when 'u'
      target[:underline] = (attrs['val'] || 'single').to_sym unless NO_UNDERLINE_VALUES.include?(attrs['val'])
    when 'sz' then target[:size] = attrs['val']&.to_f
    when 'rFont', 'name' then target[:font] = attrs['val']
    when 'family' then target[:font_family] = attrs['val']&.to_i
    when 'charset' then target[:charset] = attrs['val']&.to_i
    when 'scheme'
      target[:font_scheme] = attrs['val']&.to_sym unless NO_FONT_SCHEME_VALUES.include?(attrs['val'])
    when 'vertAlign'
      target[:vertical_align] = attrs['val']&.to_sym unless NO_VERTICAL_ALIGN_VALUES.include?(attrs['val'])
    when 'color' then target[:color] = extract_color_attrs(attrs)
    end
  end

  # The <r>/<rPr>/... run-capturing state machine shared by RichTextExtractor (runs in
  # a cell's own <is>) and SharedStringsHandler (runs in a sharedStrings.xml <si>) -
  # OOXML uses the same run structure in both places.
  #
  # Extracts every run-level formatting property caxlsx's RichTextRun::INLINE_STYLES
  # supports, including family/charset/scheme: `scheme` (major/minor/none) determines
  # which actual font renders when a run has no explicit rFont and instead uses a
  # theme font; family/charset are font-matching hints only but are extracted too.
  #
  # Deliberately excludes background/fill color - that's a per-cell property (see
  # StylesHandler below), not per-run.
  #
  # Ignores <rPh> (a phonetic/furigana hint for a range of the base text) entirely -
  # its <t> child has the same element name as a real run's text, so without tracking
  # "currently inside rPh" it would be captured as a bogus extra run.
  class RunCapture
    BLANK_RUN = {
      text: nil, bold: false, italic: false, strikethrough: false, underline: nil, size: nil,
      color: nil, font: nil, vertical_align: nil, outline: false, shadow: false,
      condense: false, extend: false, font_family: nil, charset: nil, font_scheme: nil
    }.freeze

    attr_reader :runs

    def initialize
      @runs = []
      @current_run = nil
      @in_run_props = false
      @in_phonetic_run = false
      @text_buffer = nil
      # Whether a genuine <r> was seen (vs a bare, unwrapped <t>) - lets
      # RichTextExtractor tell "rich text" apart from "plain text with no run
      # formatting" for the cell-level-style fallback (see
      # apply_cell_font_fallback below).
      @had_run = false
    end

    def had_run?
      @had_run
    end

    def start_element(name, attrs)
      case name
      when 'r'
        unless @in_phonetic_run
          @current_run = BLANK_RUN.merge(text: +'')
          @had_run = true
        end
      when 'rPr' then @in_run_props = true
      when 'rPh' then @in_phonetic_run = true
      when 't' then @text_buffer = +'' unless @in_phonetic_run
      else
        Importer::Parsers::ExcelX::RichText.apply_formatting_property(@current_run, name, attrs) if @in_run_props && @current_run
      end
    end

    def characters(string)
      @text_buffer << string if @text_buffer
    end

    # A <t> with no enclosing <r> is still recorded as a single unstyled run, so
    # callers always get an array of runs back. <rPh>'s own <t> is excluded (see
    # class comment); checked here too since </t> closes before </rPh> does.
    def end_element(name)
      case name
      when 'rPr' then @in_run_props = false
      when 'rPh' then @in_phonetic_run = false
      when 't'
        unless @in_phonetic_run
          if @current_run
            @current_run[:text] << @text_buffer
          else
            @runs << BLANK_RUN.merge(text: @text_buffer)
          end
        end
        @text_buffer = nil
      when 'r'
        @runs << @current_run if @current_run
        @current_run = nil
      end
    end

    # nil for no text at all (matches raw_header_value's nil-for-missing convention),
    # not an empty array.
    def finish!
      result = @runs
      @runs = []
      result.empty? ? nil : result
    end
  end

  # A streaming, pausable SAX handler for one sheet's rich-text data, limited to the
  # columns declared via `rich_text_headers` (see Importer::Parsers::ExcelX
  # #rich_text_target_columns).
  #
  # Uses Nokogiri::XML::SAX::PushParser, not the plain SAX parser
  # Importer::Parsers::ExcelX::MergedCellsHandler uses: a plain parser runs to
  # completion in one call with no way to pause mid-file. PushParser lets the caller
  # feed fixed-size chunks and stop once the current batch's rows are read (see
  # #advance_through! below), then resume for the next batch.
  #
  # `last_closed_row` (not `@current_row`, set as soon as a row opens) is only set
  # once a row's </row> is reached, so a chunk boundary mid-row is never mistaken for
  # "fully read".
  class RichTextExtractor < Nokogiri::XML::SAX::Document
    include Importer::Parsers::ExcelX::XmlNamespaceAgnostic

    # rPh must be listed here too (not just in RunCapture's own dispatch): unlike
    # SharedStringsHandler below, this class only forwards elements in this allowlist.
    RUN_ELEMENTS =
      %w[r rPr b i strike u sz rFont vertAlign color rPh t outline shadow condense extend family charset scheme].freeze

    attr_reader :cells, :last_closed_row

    # target_columns: 1-based column indexes to track. shared_strings: the workbook's
    # SharedStringsHandler (also exposes #had_run? per entry, needed for the cell-font
    # fallback below). cell_styles: resolves a cell's own style index to its
    # background fill and default font (see StylesHandler below).
    def initialize(target_columns, shared_strings, cell_styles)
      super()
      @target_columns = target_columns
      @shared_strings = shared_strings
      @cell_styles = cell_styles
      @cells = {}
      @current_row = nil
      @last_closed_row = 0
      @current_col = nil
      @current_cell_type = nil
      @current_style_index = nil
      @run_capture = nil
      @shared_index_buffer = nil
      @shared_string_pending = nil
      # <row>'s own `r` attribute is optional per CT_Row; absent means "one more than
      # the previous row's index" - tracked here as a running counter (nil.to_i is 0
      # in Ruby, which would otherwise silently collapse every such row to row 0).
      @next_implicit_row = 1
      # <c>'s own `r` is optional too (CT_Cell) - same fallback, reset to 1 at each
      # <row>'s own start.
      @next_implicit_column = 1
    end

    def start_element(name, attrs = [])
      attrs = attrs.to_h

      case name
      when 'row'
        @current_row = attrs['r'] ? attrs['r'].to_i : @next_implicit_row
        @next_implicit_row = @current_row + 1
        @next_implicit_column = 1
        # Every row in range gets an entry, even one with no target-column cell, so
        # "this row number is a key in @cells" reliably means "fully read".
        @cells[@current_row] = {}
      when 'c'
        column = attrs['r'] ? extract_column(attrs['r']) : @next_implicit_column
        @next_implicit_column = column + 1 if column
        if column && @target_columns.include?(column)
          @current_col = column
          @current_cell_type = attrs['t']
          # No `s` attribute means style index 0 (OOXML's own default), not a
          # fallback invented here.
          @current_style_index = (attrs['s'] || '0').to_i
          @run_capture = RunCapture.new
        end
      when 'v'
        if @current_col && @current_cell_type == 's'
          # Only a shared-string cell's <v> holds an index into the shared-string table.
          @shared_index_buffer = +''
        elsif @current_col
          # Every other cell type's <v> (plain number, t="str" formula result,
          # boolean, error, date) holds its literal value directly - none of these can
          # be rich text. Routed through @run_capture as a bare <t> so it comes back as
          # the single unstyled run a plain cell already gets, rather than the
          # `runs: nil` a genuinely empty cell gets.
          @run_capture.start_element('t', {})
        end
      else
        @run_capture&.start_element(name, attrs) if RUN_ELEMENTS.include?(name)
      end
    end

    def characters(string)
      @shared_index_buffer << string if @shared_index_buffer
      @run_capture&.characters(string)
    end

    def end_element(name)
      case name
      when 'row'
        @last_closed_row = @current_row
      when 'c'
        finish_current_cell! if @current_col
      when 'v'
        if @shared_index_buffer
          @shared_string_pending = @shared_index_buffer.to_i
          @shared_index_buffer = nil
        elsif @current_col
          @run_capture.end_element('t')
        end
      else
        @run_capture&.end_element(name) if RUN_ELEMENTS.include?(name)
      end
    end

    private

    def extract_column(ref)
      return nil unless ref

      Roo::Utils.extract_coordinate(ref).last
    end

    def finish_current_cell!
      runs = @run_capture.finish!
      had_run = @run_capture.had_run?

      # An inline <is> cell's runs already came through @run_capture; a shared t="s"
      # cell has no inline runs of its own, so this overrides rather than merges.
      if @shared_string_pending
        resolved_runs = @shared_strings.entries[@shared_string_pending]
        if resolved_runs
          runs = resolved_runs
          had_run = @shared_strings.had_run?(@shared_string_pending)
        end
      end

      runs = apply_cell_font_fallback(runs, had_run)

      @cells[@current_row][@current_col] = {
        runs: runs,
        background_color: @cell_styles&.background_color_for(@current_style_index)
      }
      @current_col = nil
      @current_cell_type = nil
      @current_style_index = nil
      @run_capture = nil
      @shared_string_pending = nil
    end

    # A cell with no rich-text runs of its own (`had_run` false) still visibly renders
    # per its own cell *style* (e.g. bold via "Format Cells", not a run) - falls back
    # to the cell's own font (StylesHandler#font_for), keeping only the run's real
    # text.
    #
    # Not extended to a cell that does have its own runs: real-world runs are
    # self-contained (every property is written explicitly, not left to inherit), so a
    # per-property merge isn't needed.
    def apply_cell_font_fallback(runs, had_run)
      return runs if had_run || runs.nil?

      cell_font = @cell_styles&.font_for(@current_style_index)
      return runs unless cell_font

      [ { text: runs.first[:text] }.merge(cell_font) ]
    end
  end

  # A one-time, whole-file SAX pass over sharedStrings.xml - bounded by the count of
  # unique strings, not row count, so reading it all up front is cheap. Absent
  # entirely for a workbook using only inline strings, in which case an empty result
  # is correct.
  class SharedStringsHandler < Nokogiri::XML::SAX::Document
    include Importer::Parsers::ExcelX::XmlNamespaceAgnostic

    attr_reader :entries

    def initialize
      super
      @entries = []
      @had_run = []
      @run_capture = nil
    end

    def start_element(name, attrs = [])
      attrs = attrs.to_h

      case name
      when 'si' then @run_capture = RunCapture.new
      else @run_capture&.start_element(name, attrs)
      end
    end

    def characters(string)
      @run_capture&.characters(string)
    end

    def end_element(name)
      case name
      when 'si'
        @entries << @run_capture.finish!
        @had_run << @run_capture.had_run?
        @run_capture = nil
      else
        @run_capture&.end_element(name)
      end
    end

    # Whether shared-string entry `index` came from a genuine <r> (rich text) rather
    # than a bare <t> - see RunCapture#had_run?.
    def had_run?(index)
      @had_run[index]
    end
  end

  # A one-time, whole-file SAX pass over styles.xml, resolving a cell's own style
  # index (its `s` attribute) to that cell's background fill and default font.
  #
  # A cell's `s` is a positional index into `<cellXfs>` only, never `<cellStyleXfs>`
  # (a similarly-shaped but unrelated section for *named* cell styles like "Normal").
  # That `<xf>`'s `fillId`/`fontId` are themselves positional indexes into `<fills>`/
  # `<fonts>`.
  #
  # A `<fill>` resolves to nil only when genuinely empty (patternType="none" or
  # absent). Any other `<patternFill>` resolves to `{ pattern_type:, fg_color:,
  # bg_color: }` - both colors, since a non-solid pattern's appearance is a genuine
  # two-color mix. A `<gradientFill>` resolves to `{ pattern_type: :gradient }` only -
  # its stops/angle/path aren't extracted.
  #
  # `font_for` resolves the cell-level-style fallback (see
  # RichTextExtractor#apply_cell_font_fallback). A `<font>` definition uses `<name>`
  # for font name, not `<rFont>`.
  class StylesHandler < Nokogiri::XML::SAX::Document
    include Importer::Parsers::ExcelX::XmlNamespaceAgnostic

    BLANK_FONT = RunCapture::BLANK_RUN.except(:text).freeze

    def initialize
      super
      @fills = []
      @cell_xf_fill_ids = []
      @fonts = []
      @cell_xf_font_ids = []
      @in_fills = false
      @in_fonts = false
      @in_cell_xfs = false
      @current_fill_pattern_type = nil
      @current_fill_fg_color = nil
      @current_fill_bg_color = nil
      @current_fill_is_gradient = false
      @current_font = nil
    end

    def start_element(name, attrs = [])
      attrs = attrs.to_h

      case name
      when 'fills' then @in_fills = true
      when 'fonts' then @in_fonts = true
      when 'cellXfs' then @in_cell_xfs = true
      when 'fill' then reset_current_fill! if @in_fills
      when 'font' then @current_font = BLANK_FONT.dup if @in_fonts
      # <gradientFill> and <patternFill> are mutually exclusive alternatives inside
      # one <fill>.
      when 'gradientFill' then @current_fill_is_gradient = true if @in_fills
      when 'patternFill' then @current_fill_pattern_type = attrs['patternType'] if @in_fills
      when 'fgColor' then @current_fill_fg_color = Importer::Parsers::ExcelX::RichText.extract_color_attrs(attrs) if @in_fills
      when 'bgColor' then @current_fill_bg_color = Importer::Parsers::ExcelX::RichText.extract_color_attrs(attrs) if @in_fills
      when 'xf'
        # A cell's `s` only ever indexes <cellXfs>'s own <xf> children by position,
        # never <cellStyleXfs> (see class comment above).
        if @in_cell_xfs
          @cell_xf_fill_ids << attrs['fillId'].to_i
          @cell_xf_font_ids << attrs['fontId'].to_i
        end
      else
        if @in_fonts && @current_font
          Importer::Parsers::ExcelX::RichText.apply_formatting_property(@current_font, name, attrs)
        end
      end
    end

    def characters(string); end

    def end_element(name)
      case name
      when 'fills' then @in_fills = false
      when 'fonts' then @in_fonts = false
      when 'cellXfs' then @in_cell_xfs = false
      when 'fill'
        @fills << resolved_fill if @in_fills
      when 'font'
        if @in_fonts
          @fonts << @current_font
          @current_font = nil
        end
      end
    end

    def background_color_for(style_index)
      fill_id = @cell_xf_fill_ids[style_index]
      return nil unless fill_id

      @fills[fill_id]
    end

    def font_for(style_index)
      font_id = @cell_xf_font_ids[style_index]
      return nil unless font_id

      @fonts[font_id]
    end

    private

    # nil (patternType absent or "none") is the only case meaning "no fill".
    NO_FILL_PATTERN_TYPES = [ nil, 'none' ].freeze

    def resolved_fill
      return { pattern_type: :gradient } if @current_fill_is_gradient
      return nil if NO_FILL_PATTERN_TYPES.include?(@current_fill_pattern_type)

      { pattern_type: @current_fill_pattern_type.to_sym, fg_color: @current_fill_fg_color, bg_color: @current_fill_bg_color }
    end

    def reset_current_fill!
      @current_fill_pattern_type = nil
      @current_fill_fg_color = nil
      @current_fill_bg_color = nil
      @current_fill_is_gradient = false
    end
  end

  RICH_TEXT_CHUNK_SIZE = 64 * 1024

  # target_columns: 1-based column indexes to track (Importer::Parsers::ExcelX
  # #rich_text_target_columns's own resolved values).
  def initialize(sheet_xml_path:, target_columns:)
    @sheet_xml_path = sheet_xml_path
    @handler = RichTextExtractor.new(target_columns, shared_strings, cell_styles)
    @parser = Nokogiri::XML::SAX::PushParser.new(@handler)
    @file = File.open(sheet_xml_path, 'rb')
  end

  # Feeds the rich-text SAX stream forward in fixed-size chunks until row_number's own
  # </row> has closed, then stops. Safe to call repeatedly per batch - if a previous
  # read already passed row_number, this no-ops. Called from
  # Importer::Parsers::ExcelX#each_row once per batch, before yielding that batch's rows.
  def advance_through!(row_number)
    until @handler.last_closed_row >= row_number
      chunk = @file.read(RICH_TEXT_CHUNK_SIZE)

      if chunk
        @parser << chunk
      else
        @parser.finish
        break
      end
    end
  end

  # Drops just-consumed rows from the cache once their batch is done with them -
  # bounded memory is why rich-text extraction is batched at all. Called from
  # Importer::Parsers::ExcelX#each_row once per batch, after yielding.
  def discard_batch!(row_numbers)
    row_numbers.each { |row_number| @handler.cells.delete(row_number) }
  end

  def close!
    @file&.close
  end

  def value_for(column, line_number)
    @handler.cells.dig(line_number, column)
  end

  private

  # roo extracts sharedStrings.xml as "roo_sharedStrings.xml", a sibling of
  # "roo_sheetN" in the same tmpdir roo unzips everything into (roo/excelx.rb).
  def shared_strings_xml_path
    File.join(File.dirname(@sheet_xml_path), 'roo_sharedStrings.xml')
  end

  # A workbook with no sharedStrings.xml resolves to a never-fed, empty handler.
  def shared_strings
    handler = SharedStringsHandler.new
    path = shared_strings_xml_path
    Nokogiri::XML::SAX::Parser.new(handler).parse_file(path) if File.exist?(path)
    handler
  end

  # Same sibling-of-roo_sheetN tmpdir convention as shared_strings_xml_path - roo
  # extracts styles.xml as "roo_styles.xml".
  def cell_styles_xml_path
    File.join(File.dirname(@sheet_xml_path), 'roo_styles.xml')
  end

  # styles.xml is not a mandatory part of a valid .xlsx - a workbook missing it still
  # opens fine via Roo::Spreadsheet.open, and roo never creates "roo_styles.xml" in
  # that case, so the parse is skipped rather than raising on a missing file. A
  # never-fed StylesHandler correctly resolves every style index to no background.
  def cell_styles
    handler = StylesHandler.new
    path = cell_styles_xml_path
    Nokogiri::XML::SAX::Parser.new(handler).parse_file(path) if File.exist?(path)
    handler
  end
end
