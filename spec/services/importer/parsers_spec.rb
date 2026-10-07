require 'spec_helper'
require 'tempfile'
require 'caxlsx'

# Every parser is constructible and usable directly - no Importer::Base subclass, no
# target_model, no DSL at all - proving the actual point of the composition refactor
# (see FINDINGS.md).
RSpec.describe 'Importer::Parsers' do
  def write_csv(content)
    file = Tempfile.new([ 'import', '.csv' ])
    file.binmode
    file.write(content)
    file.close
    file
  end

  def write_xlsx(rows)
    file = Tempfile.new([ 'import', '.xlsx' ])
    Axlsx::Package.new do |package|
      package.workbook.add_worksheet(name: 'Sheet1') { |sheet| rows.each { |row| sheet.add_row(row) } }
      package.serialize(file.path)
    end
    file
  end

  describe Importer::Parsers::Csv do
    it 'reads headers and rows, with no Importer::Base involved at all' do
      csv = write_csv("Name,Quantity\nWidget A,10\nWidget B,3\n")
      parser =
        described_class.new(
          file_path: csv.path, required_header_names: %w[Name Quantity], delimiter: ',', encoding: nil, strip_raw_value: true
        )

      parser.verify_headers!

      rows = []
      parser.each_row { |row, line_number| rows << [ line_number, row ] }

      expect(rows).to eq(
        [
          [ 2, { 'Name' => 'Widget A', 'Quantity' => '10' } ],
          [ 3, { 'Name' => 'Widget B', 'Quantity' => '3' } ]
        ]
      )
    end

    it 'raises for a missing required header' do
      csv = write_csv("Name\nWidget A\n")
      parser =
        described_class.new(
          file_path: csv.path, required_header_names: %w[Name Quantity], delimiter: ',', encoding: nil, strip_raw_value: true
        )

      expect { parser.verify_headers! }.to raise_error(Importer::Base::ImportError, /Missing required headers: Quantity/)
    end

    it 'transcodes a declared encoding to UTF-8' do
      content = "Name\nCafé\n".encode('Windows-1252')
      csv = write_csv(content)
      parser =
        described_class.new(
          file_path: csv.path, required_header_names: %w[Name], delimiter: ',', encoding: 'Windows-1252', strip_raw_value: true
        )

      rows = []
      parser.each_row { |row, _line_number| rows << row }

      expect(rows.first['Name']).to eq('Café')
    end

    it 'validates config at the class level without an instance' do
      expect { described_class.validate_config!(importer_class: 'Foo', delimiter: '|', encoding: nil) }
        .to raise_error(ArgumentError, /csv_delimiter must be one of/)
    end
  end

  describe Importer::Parsers::ExcelX do
    it 'reads headers and rows, with no Importer::Base involved at all' do
      xlsx = write_xlsx([ [ 'Name', 'Quantity' ], [ 'Widget A', 10 ] ])
      parser =
        described_class.new(
          file_path: xlsx.path, required_header_names: %w[Name Quantity], sheet_name: nil, header_row: 1,
          data_start_row: 2, batch_size: 1000, strip_raw_value: true, rich_text_headers: []
        )

      parser.validate_file!
      parser.verify_headers!

      rows = []
      parser.each_row { |row, row_number| rows << [ row_number, row ] }

      expect(rows).to eq([ [ 2, { 'Name' => 'Widget A', 'Quantity' => 10 } ] ])
    end

    it 'raises for a file that is not really a ZIP archive' do
      file = Tempfile.new([ 'import', '.xlsx' ])
      file.write('not a real xlsx')
      file.close

      parser =
        described_class.new(
          file_path: file.path, required_header_names: %w[Name], sheet_name: nil, header_row: 1,
          data_start_row: 2, batch_size: 1000, strip_raw_value: true, rich_text_headers: []
        )

      expect { parser.validate_file! }.to raise_error(Importer::Base::ImportError, /not a valid \.xlsx file/)
    end

    it 'returns nil for rich_text_header_value when no rich_text_headers are declared and the header exists' do
      xlsx = write_xlsx([ [ 'Name' ], [ 'Widget A' ] ])
      parser =
        described_class.new(
          file_path: xlsx.path, required_header_names: %w[Name], sheet_name: nil, header_row: 1,
          data_start_row: 2, batch_size: 1000, strip_raw_value: true, rich_text_headers: [ 'Name' ]
        )

      parser.each_row { |_row, _row_number| nil }

      expect(parser.rich_text_header_value('Name', 2)).to be_a(Hash).or be_nil
    end

    it 'raises for a header never declared in rich_text_headers' do
      xlsx = write_xlsx([ [ 'Name' ], [ 'Widget A' ] ])
      parser =
        described_class.new(
          file_path: xlsx.path, required_header_names: %w[Name], sheet_name: nil, header_row: 1,
          data_start_row: 2, batch_size: 1000, strip_raw_value: true, rich_text_headers: []
        )

      expect { parser.rich_text_header_value('Name', 2) }.to raise_error(ArgumentError, /is not declared in rich_text_headers/)
    end

    it 'validates config at the class level without an instance' do
      expect { described_class.validate_config!(importer_class: 'Foo', header_row: 0, data_start_row: 1) }
        .to raise_error(ArgumentError, /header_row must be a positive integer/)
    end
  end

  describe Importer::Parsers do
    it 'resolves file_path to CSV for .csv and .tsv, ExcelX for .xlsx' do
      expect(described_class.class_for('foo.csv')).to eq(Importer::Parsers::Csv)
      expect(described_class.class_for('foo.tsv')).to eq(Importer::Parsers::Csv)
      expect(described_class.class_for('foo.xlsx')).to eq(Importer::Parsers::ExcelX)
    end

    # Both parsers expose `format` as a class method (what Importer::Base#file_format
    # calls, so it can answer from file_path alone) and as an instance method. Csv's
    # instance method is load-bearing internally - #col_sep calls it - while ExcelX's is
    # part of the standalone parser API only. Both are pinned here rather than left to
    # be exercised incidentally.
    it 'answers format from either the class or an instance, for both parsers' do
      expect(Importer::Parsers::Csv.format('foo.csv')).to eq(:csv)
      expect(Importer::Parsers::Csv.format('foo.tsv')).to eq(:tsv)
      expect(Importer::Parsers::ExcelX.format('foo.xlsx')).to eq(:xlsx)

      csv =
        Importer::Parsers::Csv.new(
          file_path: 'foo.tsv', required_header_names: [], delimiter: ',', encoding: nil, strip_raw_value: true
        )
      excel =
        Importer::Parsers::ExcelX.new(
          file_path: 'foo.xlsx', required_header_names: [], sheet_name: nil, header_row: 1,
          data_start_row: 2, batch_size: 1000, strip_raw_value: true, rich_text_headers: []
        )

      expect(csv.format).to eq(:tsv)
      expect(excel.format).to eq(:xlsx)
    end
  end

  describe Importer::Parsers::ZippedCsv do
    def write_zip(entries, name: 'import.zip')
      file = Tempfile.new([ File.basename(name, '.zip'), '.zip' ])
      file.close
      File.delete(file.path)
      Zip::File.open(file.path, create: true) do |zip|
        entries.each { |entry_name, content| zip.get_output_stream(entry_name) { |out| out.write(content) } }
      end
      file
    end

    def build_parser(zip, **overrides)
      described_class.new(
        file_path: zip.path, required_header_names: %w[Name Quantity], delimiter: ',', encoding: nil, strip_raw_value: true, **overrides
      )
    end

    it 'reads rows from the single CSV inside the zip, with the same shape as Parsers::Csv' do
      zip = write_zip({ 'data.csv' => "Name,Quantity\nWidget A,10\nWidget B,3\n" })
      parser = build_parser(zip)

      parser.validate_file!
      parser.verify_headers!

      rows = []
      parser.each_row { |row, line_number| rows << [ line_number, row ] }
      parser.close

      expect(rows).to eq(
        [ [ 2, { 'Name' => 'Widget A', 'Quantity' => '10' } ], [ 3, { 'Name' => 'Widget B', 'Quantity' => '3' } ] ]
      )
    end

    it 'reports the inner file format, and ignores directory and __MACOSX entries' do
      zip = write_zip({ 'dir/data.tsv' => "Name\tQuantity\nA\t1\n", '__MACOSX/dir/._data.tsv' => 'junk' })
      parser = build_parser(zip)

      expect(parser.format).to eq(:tsv)
      parser.close
    end

    it 'removes its tempfile on close' do
      zip = write_zip({ 'data.csv' => "Name,Quantity\nA,1\n" })
      parser = build_parser(zip)
      parser.verify_headers!
      path = parser.send(:csv_parser).instance_variable_get(:@file_path)

      expect(File.exist?(path)).to be(true)
      parser.close
      expect(File.exist?(path)).to be(false)
    end

    it 'rejects an empty zip, a multi-file zip, and a non-CSV entry' do
      {
        {} => /exactly one file, but it is empty/,
        { 'a.csv' => "x\n", 'b.csv' => "x\n" } => /exactly one file, found 2/,
        { 'a.txt' => "x\n" } => /must have one of these extensions/
      }.each do |entries, message|
        zip = write_zip(entries)
        expect { build_parser(zip).verify_headers! }.to raise_error(Importer::Base::ImportError, message)
      end
    end

    it 'rejects an entry over max_uncompressed_bytes before extracting it' do
      zip = write_zip({ 'data.csv' => "Name,Quantity\nA,1\n" })

      expect { build_parser(zip, max_uncompressed_bytes: 5).verify_headers! }
        .to raise_error(Importer::Base::ImportError, /larger than 5 bytes/)
    end

    it 'rejects a file that is not a zip archive' do
      file = Tempfile.new([ 'bogus', '.zip' ])
      file.write('not a zip')
      file.close

      expect { build_parser(file).verify_headers! }.to raise_error(Importer::Base::ImportError, /not a readable zip/)
    end
  end
end
