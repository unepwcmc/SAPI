require 'zip'
require 'tempfile'

# Importer::Base's reader for a .zip holding exactly one CSV/TSV file. Not a parser of its
# own: it extracts that entry to a tempfile and hands everything else to
# Importer::Parsers::Csv, implementing the same validate_file!/verify_headers!/each_row
# contract, so delimiter, encoding, BOM, line-number and strip behavior stay identical to
# a plain .csv import.
#
# Extracted to disk, not streamed from the zip entry: Csv reads by path in three separate
# passes (validate_file!, verify_headers!, each_row), and a zip entry stream can't be
# rewound. The tempfile lives until #close - Importer::Base#import! calls it in an
# `ensure`; a standalone user must call it themselves.
#
# A .zip with anything other than one real file in it is rejected rather than guessed at.
# Directory entries and macOS's `__MACOSX/` / `._*` resource-fork droppings are ignored,
# since they ride along in any archive made with Finder.
#
# max_uncompressed_bytes (DEFAULT_MAX_UNCOMPRESSED_BYTES unless a subclass declares its
# own) guards against a zip bomb. rubyzip also raises if an entry inflates past its own
# declared size, so a forged header can't dodge the cap.
class Importer::Parsers::ZippedCsv
  SUPPORTED_EXTENSIONS = %w[.zip].freeze
  DEFAULT_MAX_UNCOMPRESSED_BYTES = 512.megabytes

  def self.validate_config!(importer_class:, max_uncompressed_bytes:)
    return if max_uncompressed_bytes.is_a?(Integer) && max_uncompressed_bytes.positive?

    raise ArgumentError,
      "#{importer_class}: max_uncompressed_bytes must be a positive Integer, got #{max_uncompressed_bytes.inspect}"
  end

  # `.zip` alone can't say csv vs tsv without opening the archive, and this is called
  # from file_path alone (Importer::Base#file_format) - so :csv, the common case.
  # The instance #format below is exact.
  def self.format(_file_path) = :csv

  def initialize(file_path:, max_uncompressed_bytes: DEFAULT_MAX_UNCOMPRESSED_BYTES, **csv_options)
    @file_path = file_path
    @max_uncompressed_bytes = max_uncompressed_bytes
    @csv_options = csv_options
  end

  def format = csv_parser.format

  def validate_file!
    csv_parser.validate_file!
  end

  def verify_headers!
    csv_parser.verify_headers!
  end

  def each_row(&block)
    csv_parser.each_row(&block)
  end

  def close
    @tempfile&.close!
    @tempfile = nil
    @csv_parser = nil
  end

  private

  def csv_parser
    @csv_parser ||= Importer::Parsers::Csv.new(file_path: extract!, **@csv_options)
  end

  def extract!
    Zip::File.open(@file_path) do |zip|
      entry = single_csv_entry(zip)

      if entry.size > @max_uncompressed_bytes
        raise import_error("entry #{entry.name} is larger than #{@max_uncompressed_bytes} bytes uncompressed")
      end

      @tempfile = Tempfile.new([ 'importer', File.extname(entry.name).downcase ])
      @tempfile.binmode
      entry.get_input_stream { |input| IO.copy_stream(input, @tempfile) }
      @tempfile.close
    end

    @tempfile.path
  rescue Zip::Error => e
    close
    raise import_error("not a readable zip archive (#{e.message})")
  end

  def single_csv_entry(zip)
    files = zip.entries.select { |entry| entry.file? && !ignorable?(entry.name) }

    raise import_error('zip must contain exactly one file, but it is empty') if files.empty?
    raise import_error("zip must contain exactly one file, found #{files.size}: #{files.map(&:name).join(', ')}") if files.size > 1

    entry = files.first

    unless Importer::Parsers::Csv::SUPPORTED_EXTENSIONS.include?(File.extname(entry.name).downcase)
      raise import_error("entry #{entry.name} must have one of these extensions: #{Importer::Parsers::Csv::SUPPORTED_EXTENSIONS.join(', ')}")
    end

    entry
  end

  def ignorable?(name)
    name.start_with?('__MACOSX/') || File.basename(name).start_with?('._')
  end

  def import_error(message) = Importer::Base::ImportError.new("#{@file_path}: #{message}")
end
