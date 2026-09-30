require 'spec_helper'
require 'caxlsx'
require 'tempfile'
require 'zip'

RSpec.describe Importer::Base do
  # rubocop:disable RSpec/BeforeAfterAll -- table DDL, not row data; nothing here needs a per-example rollback
  before(:context) do
    ActiveRecord::Base.connection.create_table :importer_excel_spec_widgets, force: true do |t|
      t.string :name
      t.integer :quantity
      t.decimal :price, precision: 12, scale: 2
      t.date :delivered_on
      t.boolean :active
      t.text :notes
    end
  end

  after(:context) do
    ActiveRecord::Base.connection.drop_table :importer_excel_spec_widgets, if_exists: true
  end
  # rubocop:enable RSpec/BeforeAfterAll

  let(:widget_class) do
    Class.new(ApplicationRecord) { self.table_name = 'importer_excel_spec_widgets' }
  end

  before do
    stub_const('ImporterExcelSpecWidget', widget_class)
  end

  def write_xlsx(rows, sheet_name: 'Sheet1', merges: [])
    file = Tempfile.new([ 'import', '.xlsx' ])

    Axlsx::Package.new do |package|
      package.workbook.add_worksheet(name: sheet_name) do |sheet|
        rows.each { |row| sheet.add_row(row) }
        merges.each { |ref| sheet.merge_cells(ref) }
      end
      package.serialize(file.path)
    end

    file
  end

  def importer_class(&block)
    Class.new(described_class) do
      target_model ImporterExcelSpecWidget
      mode :raw_insert_all
      required_headers(
        {
          'Name' => :name,
          'Quantity' => :quantity,
          'Price' => :price,
          'Delivered On' => :delivered_on,
          'Active' => :active
        }
      )

      class_eval(&block) if block
    end
  end

  describe 'basic import' do
    it 'imports rows from a .xlsx file' do
      file =
        write_xlsx(
          [
            [ 'Name', 'Quantity', 'Price', 'Delivered On', 'Active' ],
            [ 'Widget A', 10, 19.99, Date.new(2024, 1, 5), true ],
            [ 'Widget B', 3, 5.50, Date.new(2024, 2, 1), false ]
          ]
        )

      importer_class.new(file_path: file.path).import!

      expect(ImporterExcelSpecWidget.count).to eq(2)
      expect(ImporterExcelSpecWidget.find_by(name: 'Widget A').quantity).to eq(10)
    end

    it 'lets a subclass read file_format (:xlsx) from cast_<attribute>' do
      klass =
        importer_class do
          def cast_name(_raw_value)
            file_format.to_s
          end
        end

      file =
        write_xlsx(
          [
            [ 'Name', 'Quantity', 'Price', 'Delivered On', 'Active' ],
            [ 'Widget A', 10, 19.99, Date.new(2024, 1, 5), true ]
          ]
        )

      klass.new(file_path: file.path).import!

      expect(ImporterExcelSpecWidget.pluck(:name)).to eq([ 'xlsx' ])
    end

    it 'records a summary log entry with the actual row numbers processed' do
      file =
        write_xlsx(
          [
            [ 'Name', 'Quantity', 'Price', 'Delivered On', 'Active' ],
            [ 'Widget A', 10, 19.99, Date.new(2024, 1, 5), true ]
          ]
        )

      importer = importer_class.new(file_path: file.path)
      importer.import!

      expect(importer.logs).to include(a_hash_including(level: 'info', processed: 1, written: 1))
    end

    it 'raises when a required header is missing' do
      file = write_xlsx([ [ 'Name', 'Quantity', 'Price', 'Active' ], [ 'Widget A', 10, 19.99, true ] ])

      importer = importer_class.new(file_path: file.path)

      expect { importer.import! }.to raise_error(described_class::ImportError, /Missing required headers/)
      expect(ImporterExcelSpecWidget.count).to eq(0)
    end

    it 'raises when a required header appears more than once' do
      file =
        write_xlsx(
          [
            [ 'Name', 'Name', 'Quantity', 'Price', 'Delivered On', 'Active' ],
            [ 'Widget A', 'Widget B', 10, 19.99, Date.new(2024, 1, 5), true ]
          ]
        )

      importer = importer_class.new(file_path: file.path)

      expect { importer.import! }.to raise_error(described_class::ImportError, /Duplicate header\(s\) in file: Name/)
    end

    it 'tolerates stray whitespace around header names' do
      file =
        write_xlsx(
          [
            [ 'Name', ' Quantity ', 'Price', 'Delivered On', 'Active' ],
            [ 'Widget A', 10, 19.99, Date.new(2024, 1, 5), true ]
          ]
        )

      importer_class.new(file_path: file.path).import!

      expect(ImporterExcelSpecWidget.find_by(name: 'Widget A').quantity).to eq(10)
    end

    it 'drops a fully blank row by default, the same as CSV' do
      file =
        write_xlsx(
          [
            [ 'Name', 'Quantity', 'Price', 'Delivered On', 'Active' ],
            [ 'Widget A', 10, 19.99, Date.new(2024, 1, 5), true ],
            [ nil, nil, nil, nil, nil ],
            [ 'Widget B', 3, 5.50, Date.new(2024, 2, 1), false ]
          ]
        )

      importer_class.new(file_path: file.path).import!

      expect(ImporterExcelSpecWidget.count).to eq(2)
    end

    it 'excludes a row via a subclass exclude_row? override, based on a column outside required_headers' do
      klass =
        importer_class do
          def exclude_row?(row)
            row['Status'] == 'Draft'
          end
        end

      file =
        write_xlsx(
          [
            [ 'Name', 'Quantity', 'Price', 'Delivered On', 'Active', 'Status' ],
            [ 'Widget A', 10, 19.99, Date.new(2024, 1, 5), true, 'Published' ],
            [ 'Widget B', 3, 5.50, Date.new(2024, 2, 1), false, 'Draft' ]
          ]
        )

      klass.new(file_path: file.path).import!

      expect(ImporterExcelSpecWidget.pluck(:name)).to eq([ 'Widget A' ])
    end

    it 'processes more than one batch when rows exceed batch_size' do
      klass = importer_class { batch_size 1 }

      file =
        write_xlsx(
          [
            [ 'Name', 'Quantity', 'Price', 'Delivered On', 'Active' ],
            [ 'Widget A', 10, 19.99, Date.new(2024, 1, 5), true ],
            [ 'Widget B', 3, 5.50, Date.new(2024, 2, 1), false ],
            [ 'Widget C', 7, 1.23, Date.new(2024, 3, 1), true ]
          ]
        )

      klass.new(file_path: file.path).import!

      expect(ImporterExcelSpecWidget.count).to eq(3)
    end
  end

  describe 'file validity' do
    it 'raises before any parsing when the file is not a valid ZIP archive, even though named .xlsx' do
      file = Tempfile.new([ 'import', '.xlsx' ])
      file.write('not a zip file at all')
      file.close

      importer = importer_class.new(file_path: file.path)

      expect { importer.import! }
        .to raise_error(described_class::ImportError, /not a valid \.xlsx file.*ZIP signature/)
      expect(ImporterExcelSpecWidget.count).to eq(0)
    end

    describe 'skip_file_validation' do
      it 'does not affect a genuinely valid .xlsx file - the import still succeeds normally' do
        klass = importer_class { skip_file_validation true }
        file =
          write_xlsx(
            [
              [ 'Name', 'Quantity', 'Price', 'Delivered On', 'Active' ],
              [ 'Widget A', 10, 19.99, Date.new(2024, 1, 5), true ]
            ]
          )

        klass.new(file_path: file.path).import!

        expect(ImporterExcelSpecWidget.count).to eq(1)
      end

      it 'still raises for a missing required header even when skip_file_validation is true' do
        klass = importer_class { skip_file_validation true }
        file = write_xlsx([ [ 'Quantity', 'Price', 'Delivered On', 'Active' ], [ 10, 19.99, Date.new(2024, 1, 5), true ] ])

        expect { klass.new(file_path: file.path).import! }
          .to raise_error(described_class::ImportError, /Missing required headers: Name/)
      end

      it 'no longer catches a non-ZIP file with this class\'s own clear error - the whole point of the check being skipped' do
        klass = importer_class { skip_file_validation true }
        file = Tempfile.new([ 'import', '.xlsx' ])
        file.write('not a zip file at all')
        file.close

        expect { klass.new(file_path: file.path).import! }
          .to raise_error { |error| expect(error).not_to be_a(described_class::ImportError) }
      end
    end
  end

  describe 'sheet selection' do
    it 'defaults to the workbook\'s first sheet when sheet_name is not declared' do
      file =
        write_xlsx(
          [ [ 'Name', 'Quantity', 'Price', 'Delivered On', 'Active' ], [ 'Widget A', 10, 19.99, Date.new(2024, 1, 5), true ] ],
          sheet_name: 'FirstSheet'
        )

      importer_class.new(file_path: file.path).import!

      expect(ImporterExcelSpecWidget.find_by(name: 'Widget A')).to be_present
    end

    it 'reads the declared sheet_name, not the first sheet' do
      file = Tempfile.new([ 'import', '.xlsx' ])
      Axlsx::Package.new do |package|
        package.workbook.add_worksheet(name: 'Ignore Me') { |sheet| sheet.add_row([ 'irrelevant' ]) }
        package.workbook.add_worksheet(name: 'RealData') do |sheet|
          sheet.add_row [ 'Name', 'Quantity', 'Price', 'Delivered On', 'Active' ]
          sheet.add_row [ 'Widget A', 10, 19.99, Date.new(2024, 1, 5), true ]
        end
        package.serialize(file.path)
      end

      klass = importer_class { sheet_name 'RealData' }
      klass.new(file_path: file.path).import!

      expect(ImporterExcelSpecWidget.find_by(name: 'Widget A')).to be_present
    end

    it 'raises when the declared sheet_name does not exist' do
      file = write_xlsx([ [ 'Name', 'Quantity', 'Price', 'Delivered On', 'Active' ] ], sheet_name: 'ActualSheet')

      klass = importer_class { sheet_name 'NoSuchSheet' }

      expect { klass.new(file_path: file.path).import! }
        .to raise_error(described_class::ImportError, /no sheet named 'NoSuchSheet'.*available: ActualSheet/)
    end

    it 'detects a merged header cell in the declared (non-first) sheet, not just the first sheet' do
      file = Tempfile.new([ 'import', '.xlsx' ])
      Axlsx::Package.new do |package|
        package.workbook.add_worksheet(name: 'Ignore Me') { |sheet| sheet.add_row([ 'irrelevant' ]) }
        package.workbook.add_worksheet(name: 'RealData') do |sheet|
          sheet.add_row [ 'Name', 'Quantity', 'Price', 'Delivered On', 'Active' ]
          sheet.add_row [ 'Widget A', 10, 19.99, Date.new(2024, 1, 5), true ]
          sheet.merge_cells 'A1:B1'
        end
        package.serialize(file.path)
      end

      klass = importer_class { sheet_name 'RealData' }

      expect { klass.new(file_path: file.path).import! }
        .to raise_error(described_class::ImportError, /row 1 \(the header row\) contains a merged cell/)
      expect(ImporterExcelSpecWidget.count).to eq(0)
    end

    it 'does not raise for a merge in an unselected sheet when a different sheet is declared' do
      file = Tempfile.new([ 'import', '.xlsx' ])
      Axlsx::Package.new do |package|
        package.workbook.add_worksheet(name: 'Ignore Me') do |sheet|
          sheet.add_row [ 'irrelevant', 'data' ]
          sheet.merge_cells 'A1:B1'
        end
        package.workbook.add_worksheet(name: 'RealData') do |sheet|
          sheet.add_row [ 'Name', 'Quantity', 'Price', 'Delivered On', 'Active' ]
          sheet.add_row [ 'Widget A', 10, 19.99, Date.new(2024, 1, 5), true ]
        end
        package.serialize(file.path)
      end

      klass = importer_class { sheet_name 'RealData' }

      expect { klass.new(file_path: file.path).import! }.not_to raise_error
      expect(ImporterExcelSpecWidget.find_by(name: 'Widget A')).to be_present
    end
  end

  describe 'header_row / data_start_row' do
    it 'raises at config time when header_row is not a positive integer' do
      klass = importer_class { header_row 0 }

      expect { klass.new(file_path: 'irrelevant.xlsx').import! }
        .to raise_error(ArgumentError, /header_row must be a positive integer/)
    end

    it 'raises at config time when data_start_row is not a positive integer' do
      klass = importer_class { data_start_row(-1) }

      expect { klass.new(file_path: 'irrelevant.xlsx').import! }
        .to raise_error(ArgumentError, /data_start_row must be a positive integer/)
    end

    it 'raises at config time when data_start_row is not after header_row' do
      klass = importer_class { header_row 3; data_start_row 3 }

      expect { klass.new(file_path: 'irrelevant.xlsx').import! }
        .to raise_error(ArgumentError, /data_start_row \(3\) must be after header_row \(3\)/)
    end

    it 'reads a header on a custom header_row, and data starting on a custom data_start_row' do
      file = Tempfile.new([ 'import', '.xlsx' ])
      Axlsx::Package.new do |package|
        package.workbook.add_worksheet(name: 'Sheet1') do |sheet|
          sheet.add_row [ 'Decorative title row' ]
          sheet.add_row [ 'Another decorative row' ]
          sheet.add_row [ 'Name', 'Quantity', 'Price', 'Delivered On', 'Active' ]
          sheet.add_row [ 'spacer row - skipped entirely' ]
          sheet.add_row [ 'Widget A', 10, 19.99, Date.new(2024, 1, 5), true ]
        end
        package.serialize(file.path)
      end

      klass =
        importer_class do
          header_row 3
          data_start_row 5
        end
      klass.new(file_path: file.path).import!

      expect(ImporterExcelSpecWidget.count).to eq(1)
      expect(ImporterExcelSpecWidget.find_by(name: 'Widget A')).to be_present
    end
  end

  describe 'merged cells' do
    it 'raises when the header row contains a merged cell' do
      file =
        write_xlsx(
          [
            [ 'Name', 'Quantity', 'Price', 'Delivered On', 'Active' ],
            [ 'Widget A', 10, 19.99, Date.new(2024, 1, 5), true ]
          ],
          merges: [ 'A1:B1' ]
        )

      importer = importer_class.new(file_path: file.path)

      expect { importer.import! }
        .to raise_error(described_class::ImportError, /row 1 \(the header row\) contains a merged cell/)
      expect(ImporterExcelSpecWidget.count).to eq(0)
    end

    it 'raises when a data row contains a merged cell' do
      file =
        write_xlsx(
          [
            [ 'Name', 'Quantity', 'Price', 'Delivered On', 'Active' ],
            [ 'Widget A', 10, 19.99, Date.new(2024, 1, 5), true ]
          ],
          merges: [ 'A2:B2' ]
        )

      importer = importer_class.new(file_path: file.path)

      expect { importer.import! }.to raise_error(described_class::ImportError, /row 2 contains a merged cell/)
      expect(ImporterExcelSpecWidget.count).to eq(0)
    end

    it 'raises for the header row when it is the anchor of a vertical merge extending into a data row' do
      file =
        write_xlsx(
          [
            [ 'Name', 'Quantity', 'Price', 'Delivered On', 'Active' ],
            [ nil, 10, 19.99, Date.new(2024, 1, 5), true ]
          ],
          merges: [ 'A1:A2' ]
        )

      importer = importer_class.new(file_path: file.path)

      expect { importer.import! }
        .to raise_error(described_class::ImportError, /row 1 \(the header row\) contains a merged cell/)
      expect(ImporterExcelSpecWidget.count).to eq(0)
    end

    it 'detects a large merge range spanning the header row without expanding it cell by cell' do
      file = Tempfile.new([ 'import', '.xlsx' ])
      Axlsx::Package.new do |package|
        package.workbook.add_worksheet(name: 'Sheet1') do |sheet|
          sheet.add_row [ 'Name', 'Quantity', 'Price', 'Delivered On', 'Active' ]
          sheet.add_row [ 'Widget A', 10, 19.99, Date.new(2024, 1, 5), true ]
          # 50 columns x 20,000 rows = 1,000,000 cells - only row-level tracking keeps
          # this fast and bounded; a per-cell expansion would allocate one entry for
          # every one of those million cells just to find that row 1 is affected.
          sheet.merge_cells "A1:AX20000"
        end
        package.serialize(file.path)
      end

      importer = importer_class.new(file_path: file.path)

      start = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      expect { importer.import! }
        .to raise_error(described_class::ImportError, /row 1 \(the header row\) contains a merged cell/)
      expect(Process.clock_gettime(Process::CLOCK_MONOTONIC) - start).to be < 2
    end

    it 'does not raise for a merged cell in a decorative row skipped via header_row/data_start_row' do
      file = Tempfile.new([ 'import', '.xlsx' ])
      Axlsx::Package.new do |package|
        package.workbook.add_worksheet(name: 'Sheet1') do |sheet|
          sheet.add_row [ 'Decorative merged title', nil, nil, nil, nil ]
          sheet.merge_cells 'A1:E1'
          sheet.add_row [ 'Name', 'Quantity', 'Price', 'Delivered On', 'Active' ]
          sheet.add_row [ 'Widget A', 10, 19.99, Date.new(2024, 1, 5), true ]
        end
        package.serialize(file.path)
      end

      klass = importer_class { header_row 2 }

      expect { klass.new(file_path: file.path).import! }.not_to raise_error
      expect(ImporterExcelSpecWidget.count).to eq(1)
    end
  end

  describe 'native cell types' do
    it 'uses an Integer cell directly for an :integer column' do
      file =
        write_xlsx(
          [
            [ 'Name', 'Quantity', 'Price', 'Delivered On', 'Active' ],
            [ 'Widget A', 10, 19.99, Date.new(2024, 1, 5), true ]
          ]
        )

      importer_class.new(file_path: file.path).import!

      expect(ImporterExcelSpecWidget.find_by(name: 'Widget A').quantity).to eq(10)
    end

    it 'uses a Float cell directly for a :decimal column, with no binary-float precision drift' do
      # 100.15 is a classic imprecise binary float (not exactly representable) - this
      # would come back as something like 100.1499999999999... if the native Float were
      # ever converted via its raw binary value instead of Ruby's own decimal-accurate
      # Float#to_s representation (verified empirically - see FINDINGS.md).
      file =
        write_xlsx(
          [
            [ 'Name', 'Quantity', 'Price', 'Delivered On', 'Active' ],
            [ 'Widget A', 10, 100.15, Date.new(2024, 1, 5), true ]
          ]
        )

      importer_class.new(file_path: file.path).import!

      expect(ImporterExcelSpecWidget.find_by(name: 'Widget A').price).to eq(BigDecimal('100.15'))
    end

    it 'raises when a native Float cell has more decimal places than the column scale allows' do
      # Regression: a native Excel Float used to skip straight past this check via the
      # native-type fast path (Numeric matches :decimal unconditionally) - the value
      # would reach ActiveRecord::Type::Decimal#cast unchecked, which rounds silently to
      # the column's scale with no error at all. Verified directly - see FINDINGS.md.
      file =
        write_xlsx(
          [
            [ 'Name', 'Quantity', 'Price', 'Delivered On', 'Active' ],
            [ 'Widget A', 10, 123.4567, Date.new(2024, 1, 5), true ]
          ]
        )

      importer = importer_class.new(file_path: file.path)

      expect { importer.import! }
        .to raise_error(described_class::ImportError, /has more decimal places than this column's scale of 2 allows/)
      expect(ImporterExcelSpecWidget.count).to eq(0)
    end

    it 'uses a Date cell directly for a :date column' do
      file =
        write_xlsx(
          [
            [ 'Name', 'Quantity', 'Price', 'Delivered On', 'Active' ],
            [ 'Widget A', 10, 19.99, Date.new(2024, 1, 5), true ]
          ]
        )

      importer_class.new(file_path: file.path).import!

      expect(ImporterExcelSpecWidget.find_by(name: 'Widget A').delivered_on).to eq(Date.new(2024, 1, 5))
    end

    it 'uses a true boolean cell directly' do
      file =
        write_xlsx(
          [
            [ 'Name', 'Quantity', 'Price', 'Delivered On', 'Active' ],
            [ 'Widget A', 10, 19.99, Date.new(2024, 1, 5), true ]
          ]
        )

      importer_class.new(file_path: file.path).import!

      expect(ImporterExcelSpecWidget.find_by(name: 'Widget A').active).to be(true)
    end

    it 'uses a false boolean cell directly, rather than treating it as blank' do
      file =
        write_xlsx(
          [
            [ 'Name', 'Quantity', 'Price', 'Delivered On', 'Active' ],
            [ 'Widget A', 10, 19.99, Date.new(2024, 1, 5), false ]
          ]
        )

      importer_class.new(file_path: file.path).import!

      expect(ImporterExcelSpecWidget.find_by(name: 'Widget A').active).to be(false)
    end

    it 'does not drop a row as blank when its only non-empty cell is a false boolean value' do
      file =
        write_xlsx(
          [
            [ 'Name', 'Quantity', 'Price', 'Delivered On', 'Active' ],
            [ nil, nil, nil, nil, false ],
            [ nil, nil, nil, nil, nil ]
          ]
        )

      importer = importer_class.new(file_path: file.path)
      importer.import!

      expect(ImporterExcelSpecWidget.count).to eq(1)
      expect(ImporterExcelSpecWidget.first.active).to be(false)
      expect(importer.logs).to include(a_hash_including(level: 'info', processed: 1))
    end

    it 'still strictly casts a String cell in a numeric column, same as CSV' do
      file =
        write_xlsx(
          [
            [ 'Name', 'Quantity', 'Price', 'Delivered On', 'Active' ],
            [ 'Widget A', 'not_a_number', 19.99, Date.new(2024, 1, 5), true ]
          ]
        )

      importer = importer_class.new(file_path: file.path)

      expect { importer.import! }
        .to raise_error(described_class::ImportError, /Line 2, column 'quantity': invalid integer/)
    end

    it 'stringifies and strictly casts a native type that is the wrong one for the target column' do
      file =
        write_xlsx(
          [
            [ 'Name', 'Quantity', 'Price', 'Delivered On', 'Active' ],
            [ 'Widget A', Date.new(2024, 1, 1), 19.99, Date.new(2024, 1, 5), true ]
          ]
        )

      importer = importer_class.new(file_path: file.path)

      expect { importer.import! }
        .to raise_error(described_class::ImportError, /Line 2, column 'quantity': invalid integer/)
    end
  end

  describe 'row and cell structure edge cases' do
    # A <row> is optional per OOXML's own CT_Row - some writers omit an element
    # entirely for a genuinely blank row, rather than writing an empty
    # <row r="N"></row> - a different case from a missing `r` attribute (covered in
    # the rich text section below): here the row is never yielded at all, not
    # yielded-with-no-cells. Reading this streams the file directly rather than
    # through roo's own eager per-row extraction (see FINDINGS.md), so a gap like this
    # has to be detected explicitly rather than roo's own last_row-bounded Range
    # happening to cover it - verified this is treated identically to any other blank
    # row (dropped by drop_blank_rows, not counted toward processed).
    it 'treats a row entirely missing from the XML as blank, the same as any other blank row' do
      file =
        write_xlsx(
          [
            [ 'Name', 'Quantity', 'Price', 'Delivered On', 'Active' ],
            [ 'Widget A', 10, 19.99, Date.new(2024, 1, 5), true ],
            [ 'Widget B', 3, 5.50, Date.new(2024, 2, 1), false ],
            [ 'Widget C', 7, 1.23, Date.new(2024, 3, 1), true ]
          ]
        )

      sheet_xml = nil
      Zip::File.open(file.path) { |zip| sheet_xml = zip.glob('xl/worksheets/sheet1.xml').first.get_input_stream.read }
      patched = sheet_xml.sub(%r{<row r="3"[^>]*>.*?</row>}, '')
      raise 'patch did not match anything' if patched == sheet_xml

      Zip::File.open(file.path) { |zip| zip.get_output_stream('xl/worksheets/sheet1.xml') { |f| f.write(patched) } }

      importer = importer_class.new(file_path: file.path)
      importer.import!

      expect(ImporterExcelSpecWidget.pluck(:name)).to contain_exactly('Widget A', 'Widget C')
      expect(importer.logs).to include(a_hash_including(level: 'info', processed: 2))
    end

    # A trailing gap (the row's own last real cell isn't the sheet's last column) is
    # handled differently from an in-row gap - relying on Array#[] already returning
    # nil past the end of a shorter array, rather than explicit padding (see
    # excel_cell_values's own comment) - so this is worth its own regression, not just
    # inferring it from the in-row case.
    it 'lets a genuinely missing trailing cell come through as blank, not shifted onto another column' do
      file =
        write_xlsx(
          [
            [ 'Name', 'Quantity', 'Price', 'Delivered On', 'Active' ],
            [ 'Widget A', 10, 19.99, Date.new(2024, 1, 5), true ]
          ]
        )

      sheet_xml = nil
      Zip::File.open(file.path) { |zip| sheet_xml = zip.glob('xl/worksheets/sheet1.xml').first.get_input_stream.read }
      patched = sheet_xml.sub(%r{<c r="E2"[^>]*>.*?</c>}, '')
      raise 'patch did not match anything' if patched == sheet_xml

      Zip::File.open(file.path) { |zip| zip.get_output_stream('xl/worksheets/sheet1.xml') { |f| f.write(patched) } }

      importer_class.new(file_path: file.path).import!

      widget = ImporterExcelSpecWidget.find_by(name: 'Widget A')
      expect(widget.quantity).to eq(10)
      expect(widget.delivered_on).to eq(Date.new(2024, 1, 5))
      expect(widget.active).to be_nil
    end

    # The rich-text section below has its own version of this fixture (column mapping
    # for rich_text_target_columns specifically) - this is the same shape, verifying
    # ordinary (non-rich-text) required_headers mapping is equally unaffected by which
    # column the sheet's used range actually starts at.
    it "resolves the correct columns for ordinary data when the sheet's used range does not start at column A" do
      file = Tempfile.new([ 'import', '.xlsx' ])
      Axlsx::Package.new do |package|
        package.workbook.add_worksheet(name: 'Sheet1') { |sheet| sheet.add_row([ 'placeholder' ]) }
        package.serialize(file.path)
      end

      sheet_xml = <<~XML
        <?xml version="1.0" encoding="UTF-8"?><worksheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main"><dimension ref="B1:C2"/><sheetData><row r="1"><c r="B1" t="inlineStr"><is><t>Name</t></is></c><c r="C1" t="inlineStr"><is><t>Notes</t></is></c></row><row r="2"><c r="B2" t="inlineStr"><is><t>Widget A</t></is></c><c r="C2" t="inlineStr"><is><t>hello</t></is></c></row></sheetData></worksheet>
      XML

      Zip::File.open(file.path) { |zip| zip.get_output_stream('xl/worksheets/sheet1.xml') { |f| f.write(sheet_xml) } }

      klass =
        Class.new(described_class) do
          target_model ImporterExcelSpecWidget
          mode :raw_insert_all
          required_headers({ 'Name' => :name, 'Notes' => :notes })
        end

      klass.new(file_path: file.path).import!

      expect(ImporterExcelSpecWidget.find_by(name: 'Widget A').notes).to eq('hello')
    end

    # Regression: found by an external review - each_excel_row_number_and_values opened
    # the sheet XML via a bare File.open and handed it to Nokogiri::XML::Reader, which
    # neither closes it nor exposes any #close of its own - verified directly (outside
    # this spec, against a real fixture) that the underlying File stayed open even after
    # dropping every reference and forcing a GC cycle. Matched by call shape (roo's own
    # extracted "roo_sheetN" path, opened in 'rb' mode with a block), not a pre-known
    # exact path - Importer::Base rebuilds its parser (and roo re-extracts to a fresh
    # tmpdir) every time
    # assert_configured! runs, including import!'s own internal call, so a path captured
    # beforehand would already be stale by the time import! actually opens anything.
    it 'closes the file handle it opens for streaming the sheet XML, rather than leaving it for GC' do
      file =
        write_xlsx(
          [
            [ 'Name', 'Quantity', 'Price', 'Delivered On', 'Active' ],
            [ 'Widget A', 10, 19.99, Date.new(2024, 1, 5), true ]
          ]
        )

      importer = importer_class.new(file_path: file.path)

      opened_files = []
      allow(File).to receive(:open).and_wrap_original do |original, *args, &blk|
        next original.call(*args, &blk) unless args.first.to_s.match?(/roo_sheet\d*\z/) && args[1] == 'rb' && blk

        original.call(*args) do |f|
          opened_files << f
          blk.call(f)
        end
      end

      importer.import!

      # Once for excel_header_values, once more for each_excel_row's own full streaming
      # pass - both must be closed, not just the last one opened.
      expect(opened_files.size).to be >= 2
      expect(opened_files).to all(be_closed)
    end
  end

  describe 'shared strings' do
    # `roo` (this class's own reader) switches a shared string containing more than one
    # run to an HTML-wrapped read (e.g. "<html><b>bold</b>plain</html>") by default -
    # confirmed via `Roo::Excelx::SharedStrings#use_html?`, and found while building the
    # rich-text feature, not something caxlsx (this project's fixture generator, which
    # never emits sharedStrings.xml at all - see FINDINGS.md) can reproduce, so this
    # hand-builds the fixture directly. This has nothing to do with rich_text_headers -
    # it affects a perfectly ordinary String column with no rich-text declaration at
    # all, which is exactly why it contradicted this class's own documented contract
    # that raw_value/cast_<attribute> always see plain, unaffected text.
    it 'reads a multi-run shared string as plain flattened text, not HTML-wrapped, for an ordinary column' do
      file = Tempfile.new([ 'import', '.xlsx' ])
      Axlsx::Package.new do |package|
        package.workbook.add_worksheet(name: 'Sheet1') { |sheet| sheet.add_row([ 'placeholder' ]) }
        package.serialize(file.path)
      end

      sheet_xml = <<~XML
        <?xml version="1.0" encoding="UTF-8"?><worksheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main"><sheetData><row r="1"><c r="A1" t="s"><v>0</v></c><c r="B1" t="s"><v>1</v></c></row><row r="2"><c r="A2" t="s"><v>2</v></c><c r="B2" t="s"><v>3</v></c></row></sheetData></worksheet>
      XML

      shared_strings_xml = <<~XML
        <?xml version="1.0" encoding="UTF-8"?><sst xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main" count="4" uniqueCount="4"><si><t>Name</t></si><si><t>Notes</t></si><si><t>Widget A</t></si><si><r><rPr><b val="1"/></rPr><t>bold</t></r><r><t>plain</t></r></si></sst>
      XML

      Zip::File.open(file.path) do |zip|
        zip.get_output_stream('xl/worksheets/sheet1.xml') { |f| f.write(sheet_xml) }
        zip.get_output_stream('xl/sharedStrings.xml') { |f| f.write(shared_strings_xml) }
      end

      klass =
        Class.new(described_class) do
          target_model ImporterExcelSpecWidget
          mode :raw_insert_all
          required_headers({ 'Name' => :name, 'Notes' => :notes })
        end

      klass.new(file_path: file.path).import!

      expect(ImporterExcelSpecWidget.find_by(name: 'Widget A').notes).to eq('boldplain')
    end
  end

  describe 'rich text' do
    # Records rich_text_header_value('Notes')'s result into the :notes column (as a
    # plain inspect string, so it round-trips through the DB the same way every other
    # assertion in this file reads a written column back) rather than leaving it
    # unmapped - lets these specs assert on the extracted data the same way every other
    # example here asserts on a written column, without needing to reach into the
    # importer's own internals.
    def rich_text_importer_class(&block)
      importer_class do
        required_headers(
          {
            'Name' => :name,
            'Quantity' => :quantity,
            'Price' => :price,
            'Delivered On' => :delivered_on,
            'Active' => :active,
            'Notes' => :notes
          }
        )
        rich_text_headers [ 'Notes' ]

        def cast_notes(_raw_value)
          rich_text_header_value('Notes').to_s
        end

        class_eval(&block) if block
      end
    end

    def write_rich_text_xlsx(rows)
      file = Tempfile.new([ 'import', '.xlsx' ])

      Axlsx::Package.new do |package|
        package.workbook.add_worksheet(name: 'Sheet1') do |sheet|
          sheet.add_row [ 'Name', 'Quantity', 'Price', 'Delivered On', 'Active', 'Notes' ]
          rows.each { |row| sheet.add_row(row) }
        end
        package.serialize(file.path)
      end

      file
    end

    def rich_text_run(text, **)
      run = Axlsx::RichText.new
      run.add_run(text, **)
      run
    end

    # Every run's default shape, so an example only has to spell out the attributes it
    # actually cares about - matches RunCapture::BLANK_RUN exactly. Only correct for a
    # cell that has its own explicit rich-text run(s) (<r>) - use expected_plain_run
    # below for a cell with none, where the cell-level-style font fallback applies.
    def expected_run(text, **overrides)
      {
        text: text, bold: false, italic: false, strikethrough: false, underline: nil,
        size: nil, color: nil, font: nil, vertical_align: nil, outline: false, shadow: false,
        condense: false, extend: false, font_family: nil, charset: nil, font_scheme: nil
      }.merge(overrides)
    end

    # A plain cell (no rich-text run of its own - a bare <t>, a numeric/boolean/date/
    # error value, or a formula's cached string result) still falls back to its own
    # cell style's font (RichTextExtractor#apply_cell_font_fallback) - every fixture in
    # this file is caxlsx-generated, or built from a caxlsx-generated skeleton with
    # only its sheet/sharedStrings XML patched directly, so its default cell style's
    # font (fontId 0) is always caxlsx's own default: Arial, 11pt, family 1 (Roman) -
    # confirmed directly against real generated styles.xml
    # (`<font><name val="Arial"/><sz val="11"/><family val="1"/></font>`, no
    # `charset`/`scheme` on the plain default font).
    def expected_plain_run(text, **overrides)
      expected_run(text, font: 'Arial', size: 11.0, font_family: 1, **overrides)
    end

    def expected_value(runs, background_color: nil)
      { runs: runs, background_color: background_color }.to_s
    end

    it 'lets exclude_row? read the current row via rich_text_header_value, not a previous row' do
      # Regression: @current_row/@current_line_number used to be set only inside
      # build_attributes, which doesn't run until after exclude_row? has already returned -
      # so rich_text_header_value called from exclude_row? would have read whatever row was
      # processed *previously* (or raised on the very first row, where it was still nil),
      # never the row exclude_row? was actually deciding on.
      klass =
        rich_text_importer_class do
          def exclude_row?(_row)
            rich_text_header_value('Notes').to_s.include?('Draft')
          end
        end

      file =
        write_rich_text_xlsx(
          [
            [ 'Widget A', 10, 19.99, Date.new(2024, 1, 5), true, rich_text_run('Draft') ],
            [ 'Widget B', 3, 5.50, Date.new(2024, 2, 1), false, rich_text_run('Published') ]
          ]
        )

      klass.new(file_path: file.path).import!

      expect(ImporterExcelSpecWidget.pluck(:name)).to eq([ 'Widget B' ])
    end

    it 'extracts per-run bold/italic from an inline rich-text cell' do
      notes = Axlsx::RichText.new
      notes.add_run('im', b: true, i: false)
      notes.add_run('portant', b: false, i: true)

      file = write_rich_text_xlsx([ [ 'Widget A', 10, 19.99, Date.new(2024, 1, 5), true, notes ] ])

      rich_text_importer_class.new(file_path: file.path).import!

      expect(ImporterExcelSpecWidget.find_by(name: 'Widget A').notes).to eq(
        expected_value([ expected_run('im', bold: true), expected_run('portant', italic: true) ])
      )
    end

    # caxlsx always normalizes a boolean run property to "1"/"0" (confirmed via
    # RichTextRun#xml_value - see FINDINGS.md) and never emits the "true"/"false" form,
    # even though XML Schema's own boolean lexical space allows both equally - so this
    # hand-writes the sheet XML directly rather than leaving that form unverified.
    it 'treats val="false" as false, not just val="0" (both are valid XML Schema booleans)' do
      file = Tempfile.new([ 'import', '.xlsx' ])
      Axlsx::Package.new do |package|
        package.workbook.add_worksheet(name: 'Sheet1') { |sheet| sheet.add_row([ 'placeholder' ]) }
        package.serialize(file.path)
      end

      sheet_xml = <<~XML
        <?xml version="1.0" encoding="UTF-8"?><worksheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main"><sheetData><row r="1"><c r="A1" t="inlineStr"><is><t>Name</t></is></c><c r="B1" t="inlineStr"><is><t>Notes</t></is></c></row><row r="2"><c r="A2" t="inlineStr"><is><t>Widget A</t></is></c><c r="B2" t="inlineStr"><is><r><rPr><b val="false"/><i val="false"/><strike val="false"/></rPr><t>notbold</t></r></is></c></row></sheetData></worksheet>
      XML

      Zip::File.open(file.path) do |zip|
        zip.get_output_stream('xl/worksheets/sheet1.xml') { |f| f.write(sheet_xml) }
      end

      klass =
        Class.new(described_class) do
          target_model ImporterExcelSpecWidget
          mode :raw_insert_all
          required_headers({ 'Name' => :name, 'Notes' => :notes })
          rich_text_headers [ 'Notes' ]

          def cast_notes(_raw_value)
            rich_text_header_value('Notes').to_s
          end
        end

      klass.new(file_path: file.path).import!

      expect(ImporterExcelSpecWidget.find_by(name: 'Widget A').notes).to eq(
        expected_value([ expected_run('notbold') ])
      )
    end

    it 'extracts strikethrough, underline, size, color, font, and superscript/subscript from a run' do
      notes = Axlsx::RichText.new
      notes.add_run('struck', strike: true)
      notes.add_run('underlined', u: :double)
      notes.add_run('styled', sz: 18, color: 'FFFF0000', font_name: 'Calibri')
      notes.add_run('raised', vertAlign: :superscript)

      file = write_rich_text_xlsx([ [ 'Widget A', 10, 19.99, Date.new(2024, 1, 5), true, notes ] ])

      rich_text_importer_class.new(file_path: file.path).import!

      expect(ImporterExcelSpecWidget.find_by(name: 'Widget A').notes).to eq(
        expected_value(
          [
            expected_run('struck', strikethrough: true),
            expected_run('underlined', underline: :double),
            expected_run('styled', size: 18.0, color: { rgb: 'FFFF0000' }, font: 'Calibri'),
            expected_run('raised', vertical_align: :superscript)
          ]
        )
      )
    end

    it 'treats a plain (non-rich) string cell as a single unstyled run' do
      file = write_rich_text_xlsx([ [ 'Widget A', 10, 19.99, Date.new(2024, 1, 5), true, 'plain notes' ] ])

      rich_text_importer_class.new(file_path: file.path).import!

      expect(ImporterExcelSpecWidget.find_by(name: 'Widget A').notes).to eq(
        expected_value([ expected_plain_run('plain notes') ])
      )
    end

    it 'returns a nil runs Array (not a missing result) for a blank cell in a rich_text_headers column' do
      file = write_rich_text_xlsx([ [ 'Widget A', 10, 19.99, Date.new(2024, 1, 5), true, nil ] ])

      rich_text_importer_class.new(file_path: file.path).import!

      expect(ImporterExcelSpecWidget.find_by(name: 'Widget A').notes).to eq(expected_value(nil))
    end

    it "extracts a cell's background fill color, independent of whether it has any text runs at all" do
      file = Tempfile.new([ 'import', '.xlsx' ])
      Axlsx::Package.new do |package|
        package.workbook.add_worksheet(name: 'Sheet1') do |sheet|
          sheet.add_row [ 'Name', 'Quantity', 'Price', 'Delivered On', 'Active', 'Notes' ]
          yellow = sheet.workbook.styles.add_style(bg_color: 'FFFF00')
          sheet.add_row(
            [ 'Widget A', 10, 19.99, Date.new(2024, 1, 5), true, 'colored notes' ],
            style: [ nil, nil, nil, nil, nil, yellow ]
          )
          sheet.add_row(
            [ 'Widget B', 3, 5.50, Date.new(2024, 2, 1), false, nil ],
            style: [ nil, nil, nil, nil, nil, yellow ]
          )
        end
        package.serialize(file.path)
      end

      rich_text_importer_class.new(file_path: file.path).import!

      yellow_fill = { pattern_type: :solid, fg_color: { rgb: 'FFFFFF00' }, bg_color: { rgb: 'FFFFFF00' } }

      expect(ImporterExcelSpecWidget.find_by(name: 'Widget A').notes).to eq(
        expected_value([ expected_plain_run('colored notes') ], background_color: yellow_fill)
      )
      expect(ImporterExcelSpecWidget.find_by(name: 'Widget B').notes).to eq(
        expected_value(nil, background_color: yellow_fill)
      )
    end

    it 'returns nil when a declared rich_text_headers entry is not present in this workbook at all (typo)' do
      klass = rich_text_importer_class { rich_text_headers [ 'Notes Typo' ] }

      file = Tempfile.new([ 'import', '.xlsx' ])
      Axlsx::Package.new do |package|
        package.workbook.add_worksheet(name: 'Sheet1') do |sheet|
          sheet.add_row [ 'Name', 'Quantity', 'Price', 'Delivered On', 'Active', 'Notes' ]
          sheet.add_row [ 'Widget A', 10, 19.99, Date.new(2024, 1, 5), true, 'plain notes' ]
        end
        package.serialize(file.path)
      end

      klass.class_eval do
        def cast_notes(_raw_value)
          rich_text_header_value('Notes Typo').to_s
        end
      end

      klass.new(file_path: file.path).import!

      expect(ImporterExcelSpecWidget.find_by(name: 'Widget A').notes).to eq(nil.to_s)
    end

    it 'keeps each row correctly matched to its own rich-text data across a batch boundary' do
      klass = rich_text_importer_class { batch_size 1 }

      file =
        write_rich_text_xlsx(
          [
            [ 'Widget A', 10, 19.99, Date.new(2024, 1, 5), true, rich_text_run('one', b: true) ],
            [ 'Widget B', 3, 5.50, Date.new(2024, 2, 1), false, rich_text_run('two', i: true) ],
            [ 'Widget C', 7, 1.23, Date.new(2024, 3, 1), true, rich_text_run('three', b: true, i: true) ]
          ]
        )

      klass.new(file_path: file.path).import!

      expect(ImporterExcelSpecWidget.find_by(name: 'Widget A').notes).to eq(
        expected_value([ expected_run('one', bold: true) ])
      )
      expect(ImporterExcelSpecWidget.find_by(name: 'Widget B').notes).to eq(
        expected_value([ expected_run('two', italic: true) ])
      )
      expect(ImporterExcelSpecWidget.find_by(name: 'Widget C').notes).to eq(
        expected_value([ expected_run('three', bold: true, italic: true) ])
      )
    end

    # The rich-text extractor is lazy, and each_row's `ensure` must not be what forces it:
    # closing via the `rich_text` accessor would build the whole thing (two SAX passes plus
    # a File.open on the sheet XML) purely to close it again, for a sheet whose rows never
    # needed it.
    it 'never builds the rich-text extractor for a sheet with no data rows' do
      klass = rich_text_importer_class

      xlsx = write_rich_text_xlsx([]) # the helper writes the header row itself

      importer = klass.new(file_path: xlsx.path)
      importer.import!

      parser = importer.send(:parser)

      expect(parser.instance_variable_defined?(:@rich_text)).to be(false)
      expect(ImporterExcelSpecWidget.count).to eq(0)
    end

    it 'raises when rich_text_header_value is called for a header not declared in rich_text_headers' do
      klass =
        rich_text_importer_class do
          def cast_notes(_raw_value)
            rich_text_header_value('Not Declared').to_s
          end
        end

      file = write_rich_text_xlsx([ [ 'Widget A', 10, 19.99, Date.new(2024, 1, 5), true, 'plain notes' ] ])

      expect { klass.new(file_path: file.path).import! }
        .to raise_error(described_class::ImportError, /"Not Declared" is not declared in rich_text_headers/)
    end

    it 'returns nil, not a raise, when rich_text_header_value is called on a non-.xlsx import' do
      # Regression: this used to raise ("only available for .xlsx imports") instead -
      # found by an external review to be inconsistent with raw_header_value's own
      # "not found -> nil" convention, and awkward for exactly the case this class is
      # built around: one importer subclass processing either format interchangeably
      # (base.rb's own format dispatch). A CSV/TSV cell is always plain text anyway, with
      # no per-run formatting that could ever exist to extract - the same kind of nil
      # this method already returns for a declared column simply missing from a genuine
      # .xlsx workbook, not a new, third kind of nil a caller has to special-case.
      klass =
        Class.new(described_class) do
          target_model ImporterExcelSpecWidget
          mode :raw_insert_all
          required_headers({ 'Name' => :name, 'Notes' => :notes })
          rich_text_headers [ 'Notes' ]

          def cast_notes(_raw_value)
            rich_text_header_value('Notes').inspect
          end
        end

      file = Tempfile.new([ 'import', '.csv' ])
      file.write("Name,Notes\nWidget A,hello\n")
      file.close

      klass.new(file_path: file.path).import!

      expect(ImporterExcelSpecWidget.find_by(name: 'Widget A').notes).to eq('nil')
    end

    # caxlsx (this project's only available fixture-generation tool) always writes
    # strings inline (t="inlineStr") - never via a shared sharedStrings.xml table, even
    # for repeated/rich-text values (verified empirically, see FINDINGS.md). A real
    # Excel-authored workbook commonly uses shared strings instead, so this hand-builds
    # one directly (patching a caxlsx-generated skeleton's sheet1.xml and adding
    # sharedStrings.xml via rubyzip) rather than leaving that path unverified.
    it 'resolves rich-text runs stored in sharedStrings.xml, not just inline in the sheet' do
      file = Tempfile.new([ 'import', '.xlsx' ])
      Axlsx::Package.new do |package|
        package.workbook.add_worksheet(name: 'Sheet1') { |sheet| sheet.add_row([ 'placeholder' ]) }
        package.serialize(file.path)
      end

      sheet_xml = <<~XML
        <?xml version="1.0" encoding="UTF-8"?><worksheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main"><sheetData><row r="1"><c r="A1" t="s"><v>0</v></c><c r="B1" t="s"><v>1</v></c></row><row r="2"><c r="A2" t="s"><v>2</v></c><c r="B2" t="s"><v>3</v></c></row></sheetData></worksheet>
      XML

      shared_strings_xml = <<~XML
        <?xml version="1.0" encoding="UTF-8"?><sst xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main" count="4" uniqueCount="4"><si><t>Name</t></si><si><t>Notes</t></si><si><t>Widget A</t></si><si><r><rPr><b val="1"/></rPr><t>bold</t></r><r><t> plain</t></r></si></sst>
      XML

      Zip::File.open(file.path) do |zip|
        zip.get_output_stream('xl/worksheets/sheet1.xml') { |f| f.write(sheet_xml) }
        zip.get_output_stream('xl/sharedStrings.xml') { |f| f.write(shared_strings_xml) }
      end

      klass =
        Class.new(described_class) do
          target_model ImporterExcelSpecWidget
          mode :raw_insert_all
          required_headers({ 'Name' => :name, 'Notes' => :notes })
          rich_text_headers [ 'Notes' ]

          def cast_notes(_raw_value)
            rich_text_header_value('Notes').to_s
          end
        end

      klass.new(file_path: file.path).import!

      expect(ImporterExcelSpecWidget.find_by(name: 'Widget A').notes).to eq(
        expected_value([ expected_run('bold', bold: true), expected_run(' plain') ])
      )
    end

    # <si>/<is> share the same OOXML type (CT_Rst - see FINDINGS.md), which allows an
    # <rPh sb=".." eb=".."><t>...</t></rPh> phonetic-hint run (Japanese furigana, most
    # commonly) alongside the real <r> runs - a pronunciation aid for a range of the
    # *base* text, not itself part of it. caxlsx has no API for this, so both paths are
    # hand-built directly, the same technique the shared-strings test above already uses.
    it "excludes a phonetic (rPh) hint from a cell's runs, for both inline and shared strings" do
      file = Tempfile.new([ 'import', '.xlsx' ])
      Axlsx::Package.new do |package|
        package.workbook.add_worksheet(name: 'Sheet1') { |sheet| sheet.add_row([ 'placeholder' ]) }
        package.serialize(file.path)
      end

      sheet_xml = <<~XML
        <?xml version="1.0" encoding="UTF-8"?><worksheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main"><sheetData><row r="1"><c r="A1" t="s"><v>0</v></c><c r="B1" t="s"><v>1</v></c></row><row r="2"><c r="A2" t="s"><v>2</v></c><c r="B2" t="inlineStr"><is><r><t>&#28450;&#23383;</t></r><rPh sb="0" eb="2"><t>&#12363;&#12435;&#12376;</t></rPh><phoneticPr fontId="1"/></is></c></row><row r="3"><c r="A3" t="s"><v>3</v></c><c r="B3" t="s"><v>4</v></c></row></sheetData></worksheet>
      XML

      shared_strings_xml = <<~XML
        <?xml version="1.0" encoding="UTF-8"?><sst xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main" count="5" uniqueCount="5"><si><t>Name</t></si><si><t>Notes</t></si><si><t>Widget A</t></si><si><t>Widget B</t></si><si><r><t>&#28450;&#23383;</t></r><rPh sb="0" eb="2"><t>&#12363;&#12435;&#12376;</t></rPh><phoneticPr fontId="1"/></si></sst>
      XML

      Zip::File.open(file.path) do |zip|
        zip.get_output_stream('xl/worksheets/sheet1.xml') { |f| f.write(sheet_xml) }
        zip.get_output_stream('xl/sharedStrings.xml') { |f| f.write(shared_strings_xml) }
      end

      klass =
        Class.new(described_class) do
          target_model ImporterExcelSpecWidget
          mode :raw_insert_all
          required_headers({ 'Name' => :name, 'Notes' => :notes })
          rich_text_headers [ 'Notes' ]

          def cast_notes(_raw_value)
            rich_text_header_value('Notes').to_s
          end
        end

      klass.new(file_path: file.path).import!

      expect(ImporterExcelSpecWidget.find_by(name: 'Widget A').notes).to eq(
        expected_value([ expected_run('漢字') ])
      )
      expect(ImporterExcelSpecWidget.find_by(name: 'Widget B').notes).to eq(
        expected_value([ expected_run('漢字') ])
      )
    end

    # t="str" is a formula cell's own cell type - <v> holds the formula's cached,
    # computed string result directly (not an index, unlike t="s"; not wrapped in
    # <is>/<r> either, since a formula's result has no rich-text runs of its own to
    # compute - it's always one plain string). caxlsx can't produce a real,
    # engine-computed formula result at all (see FINDINGS.md's "core reading" findings),
    # so this is hand-built directly, the same technique as every other OOXML shape
    # caxlsx can't produce.
    it "returns a single unstyled run for a formula cell's cached string result (t=\"str\")" do
      file = Tempfile.new([ 'import', '.xlsx' ])
      Axlsx::Package.new do |package|
        package.workbook.add_worksheet(name: 'Sheet1') { |sheet| sheet.add_row([ 'placeholder' ]) }
        package.serialize(file.path)
      end

      sheet_xml = <<~XML
        <?xml version="1.0" encoding="UTF-8"?><worksheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main"><sheetData><row r="1"><c r="A1" t="s"><v>0</v></c><c r="B1" t="s"><v>1</v></c></row><row r="2"><c r="A2" t="s"><v>2</v></c><c r="B2" t="str"><f>UPPER("plain")</f><v>concatenated result</v></c></row></sheetData></worksheet>
      XML

      shared_strings_xml = <<~XML
        <?xml version="1.0" encoding="UTF-8"?><sst xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main" count="3" uniqueCount="3"><si><t>Name</t></si><si><t>Notes</t></si><si><t>Widget A</t></si></sst>
      XML

      Zip::File.open(file.path) do |zip|
        zip.get_output_stream('xl/worksheets/sheet1.xml') { |f| f.write(sheet_xml) }
        zip.get_output_stream('xl/sharedStrings.xml') { |f| f.write(shared_strings_xml) }
      end

      klass =
        Class.new(described_class) do
          target_model ImporterExcelSpecWidget
          mode :raw_insert_all
          required_headers({ 'Name' => :name, 'Notes' => :notes })
          rich_text_headers [ 'Notes' ]

          def cast_notes(_raw_value)
            rich_text_header_value('Notes').to_s
          end
        end

      klass.new(file_path: file.path).import!

      expect(ImporterExcelSpecWidget.find_by(name: 'Widget A').notes).to eq(
        expected_value([ expected_plain_run('concatenated result') ])
      )
    end

    # styles.xml is not actually mandatory for a valid .xlsx - `roo` itself doesn't
    # require it either (verified directly, see FINDINGS.md) - so this strips it out of
    # an otherwise normal caxlsx-generated workbook, rather than assuming every workbook
    # has one. Deliberately a minimal, plain-string-only fixture (Name/Notes, no
    # date/numeric-formatted column) rather than reusing write_rich_text_xlsx's shared
    # 5-column layout - a Date column needs its own numFmt style to be recognized as a
    # date at all, which makes `roo` itself (not this class's own code) raise once
    # styles.xml is gone, before this test could ever reach the code path it means to
    # exercise.
    it 'does not raise when the workbook has no styles.xml part at all' do
      file = Tempfile.new([ 'import', '.xlsx' ])
      Axlsx::Package.new do |package|
        package.workbook.add_worksheet(name: 'Sheet1') do |sheet|
          sheet.add_row [ 'Name', 'Notes' ]
          sheet.add_row [ 'Widget A', rich_text_run('one', b: true) ]
        end
        package.serialize(file.path)
      end

      # Strips styles.xml's own zip entry *and* the two package-level references to it
      # ([Content_Types].xml's Override, xl/_rels/workbook.xml.rels' Relationship) -
      # `roo` doesn't validate either against actual zip members, but leaving them
      # dangling would test something subtly different from a workbook that's
      # genuinely, internally valid without a styles part at all.
      Zip::File.open(file.path) do |zip|
        content_types = zip.find_entry('[Content_Types].xml').get_input_stream.read
        content_types = content_types.sub(%r{<Override PartName="/xl/styles\.xml"[^>]*/>}, '')
        zip.get_output_stream('[Content_Types].xml') { |f| f.write(content_types) }

        workbook_rels = zip.find_entry('xl/_rels/workbook.xml.rels').get_input_stream.read
        workbook_rels = workbook_rels.sub(%r{<Relationship Target="styles\.xml"[^>]*/>}, '')
        zip.get_output_stream('xl/_rels/workbook.xml.rels') { |f| f.write(workbook_rels) }

        zip.remove('xl/styles.xml')
      end

      klass =
        Class.new(described_class) do
          target_model ImporterExcelSpecWidget
          mode :raw_insert_all
          required_headers({ 'Name' => :name, 'Notes' => :notes })
          rich_text_headers [ 'Notes' ]

          def cast_notes(_raw_value)
            rich_text_header_value('Notes').to_s
          end
        end

      klass.new(file_path: file.path).import!

      expect(ImporterExcelSpecWidget.find_by(name: 'Widget A').notes).to eq(
        expected_value([ expected_run('one', bold: true) ])
      )
    end

    it 'closes the rich-text file handle even when a row fails partway through the import' do
      klass =
        rich_text_importer_class do
          def cast_notes(_raw_value)
            raise 'forced cast failure'
          end
        end

      file = write_rich_text_xlsx([ [ 'Widget A', 10, 19.99, Date.new(2024, 1, 5), true, 'plain notes' ] ])

      importer = klass.new(file_path: file.path)

      expect { importer.import! }.to raise_error(described_class::ImportError, /forced cast failure/)
      expect(importer.send(:parser).send(:rich_text).instance_variable_get(:@file)).to be_closed
    end

    # advance_through! stops feeding chunks and calls the parser's own #finish, rather
    # than raising, if EOF is reached before the requested row - shouldn't happen in a
    # real import (the row numbers each_row asks for are already bounded by the sheet's
    # own real row count), but it's a real safety net worth exercising directly rather
    # than trusting it by inspection alone.
    it 'does not raise when asked to advance past a row number the file never reaches' do
      file = write_rich_text_xlsx([ [ 'Widget A', 10, 19.99, Date.new(2024, 1, 5), true, 'plain notes' ] ])

      importer = rich_text_importer_class.new(file_path: file.path)
      importer.send(:assert_configured!)
      parser = importer.send(:parser)
      parser.send(:excel_workbook).default_sheet = parser.send(:excel_sheet_name)

      expect { parser.send(:rich_text).advance_through!(9_999) }.not_to raise_error
      expect(parser.send(:rich_text).instance_variable_get(:@handler).last_closed_row).to be < 9_999
    end

    # `roo`'s own row() starts at the sheet's *first used column*, not always column A -
    # verified directly (see FINDINGS.md). A sheet whose used range starts at column B
    # is exactly the case caxlsx's own add_row can't easily produce (it always starts at
    # A), so this is hand-built directly.
    it "resolves the correct column when the sheet's used range does not start at column A" do
      file = Tempfile.new([ 'import', '.xlsx' ])
      Axlsx::Package.new do |package|
        package.workbook.add_worksheet(name: 'Sheet1') { |sheet| sheet.add_row([ 'placeholder' ]) }
        package.serialize(file.path)
      end

      sheet_xml = <<~XML
        <?xml version="1.0" encoding="UTF-8"?><worksheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main"><dimension ref="B1:C2"/><sheetData><row r="1"><c r="B1" t="inlineStr"><is><t>Name</t></is></c><c r="C1" t="inlineStr"><is><t>Notes</t></is></c></row><row r="2"><c r="B2" t="inlineStr"><is><t>Widget A</t></is></c><c r="C2" t="inlineStr"><is><t>hello</t></is></c></row></sheetData></worksheet>
      XML

      Zip::File.open(file.path) { |zip| zip.get_output_stream('xl/worksheets/sheet1.xml') { |f| f.write(sheet_xml) } }

      klass =
        Class.new(described_class) do
          target_model ImporterExcelSpecWidget
          mode :raw_insert_all
          required_headers({ 'Name' => :name, 'Notes' => :notes })
          rich_text_headers [ 'Notes' ]

          def cast_notes(_raw_value)
            rich_text_header_value('Notes').to_s
          end
        end

      klass.new(file_path: file.path).import!

      expect(ImporterExcelSpecWidget.find_by(name: 'Widget A').notes).to eq(expected_value([ expected_plain_run('hello') ]))
    end

    it 'treats val="none" (underline) and val="baseline" (vertical alignment) as no formatting, not a truthy value' do
      notes = Axlsx::RichText.new
      notes.add_run('plain-ish', u: :none, vertAlign: :baseline)

      file = write_rich_text_xlsx([ [ 'Widget A', 10, 19.99, Date.new(2024, 1, 5), true, notes ] ])

      rich_text_importer_class.new(file_path: file.path).import!

      expect(ImporterExcelSpecWidget.find_by(name: 'Widget A').notes).to eq(
        expected_value([ expected_run('plain-ish') ])
      )
    end

    it "returns a single unstyled run for a plain numeric cell's value, not runs: nil" do
      file = Tempfile.new([ 'import', '.xlsx' ])
      Axlsx::Package.new do |package|
        package.workbook.add_worksheet(name: 'Sheet1') { |sheet| sheet.add_row([ 'placeholder' ]) }
        package.serialize(file.path)
      end

      sheet_xml = <<~XML
        <?xml version="1.0" encoding="UTF-8"?><worksheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main"><sheetData><row r="1"><c r="A1" t="inlineStr"><is><t>Name</t></is></c><c r="B1" t="inlineStr"><is><t>Notes</t></is></c></row><row r="2"><c r="A2" t="inlineStr"><is><t>Widget A</t></is></c><c r="B2"><v>42</v></c></row></sheetData></worksheet>
      XML

      Zip::File.open(file.path) { |zip| zip.get_output_stream('xl/worksheets/sheet1.xml') { |f| f.write(sheet_xml) } }

      klass =
        Class.new(described_class) do
          target_model ImporterExcelSpecWidget
          mode :raw_insert_all
          required_headers({ 'Name' => :name, 'Notes' => :notes })
          rich_text_headers [ 'Notes' ]

          def cast_notes(_raw_value)
            rich_text_header_value('Notes').to_s
          end
        end

      klass.new(file_path: file.path).import!

      expect(ImporterExcelSpecWidget.find_by(name: 'Widget A').notes).to eq(expected_value([ expected_plain_run('42') ]))
    end

    # r is optional per CT_Row's own schema - an absent r means "one more than the
    # previous row's index" (row 1, then row 2, here, purely by document order).
    it 'tracks rows correctly even when <row> omits its own r attribute' do
      file = Tempfile.new([ 'import', '.xlsx' ])
      Axlsx::Package.new do |package|
        package.workbook.add_worksheet(name: 'Sheet1') { |sheet| sheet.add_row([ 'placeholder' ]) }
        package.serialize(file.path)
      end

      sheet_xml = <<~XML
        <?xml version="1.0" encoding="UTF-8"?><worksheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main"><sheetData><row><c r="A1" t="inlineStr"><is><t>Name</t></is></c></row><row><c r="A2" t="inlineStr"><is><t>hello there</t></is></c></row></sheetData></worksheet>
      XML

      Zip::File.open(file.path) { |zip| zip.get_output_stream('xl/worksheets/sheet1.xml') { |f| f.write(sheet_xml) } }

      klass =
        Class.new(described_class) do
          target_model ImporterExcelSpecWidget
          mode :raw_insert_all
          required_headers({ 'Name' => :name })
          rich_text_headers [ 'Name' ]

          def cast_name(_raw_value)
            rich_text_header_value('Name').to_s
          end
        end

      klass.new(file_path: file.path).import!

      expect(ImporterExcelSpecWidget.first.name).to eq(expected_value([ expected_plain_run('hello there') ]))
    end

    # r is optional per CT_Cell's own schema too, not just CT_Row - an absent r means
    # "one more than the previous cell's column, or column 1 for the first cell in a
    # row". The header row's first cell has an explicit r (column A) so
    # rich_text_target_columns itself still resolves correctly; the data row's second
    # cell (the one actually declared in rich_text_headers) omits r entirely, relying
    # purely on implicit position tracking.
    it 'tracks columns correctly even when <c> omits its own r attribute' do
      file = Tempfile.new([ 'import', '.xlsx' ])
      Axlsx::Package.new do |package|
        package.workbook.add_worksheet(name: 'Sheet1') { |sheet| sheet.add_row([ 'placeholder' ]) }
        package.serialize(file.path)
      end

      sheet_xml = <<~XML
        <?xml version="1.0" encoding="UTF-8"?><worksheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main"><sheetData><row r="1"><c r="A1" t="inlineStr"><is><t>Name</t></is></c><c t="inlineStr"><is><t>Notes</t></is></c></row><row r="2"><c t="inlineStr"><is><t>Widget A</t></is></c><c t="inlineStr"><is><t>hello there</t></is></c></row></sheetData></worksheet>
      XML

      Zip::File.open(file.path) { |zip| zip.get_output_stream('xl/worksheets/sheet1.xml') { |f| f.write(sheet_xml) } }

      klass =
        Class.new(described_class) do
          target_model ImporterExcelSpecWidget
          mode :raw_insert_all
          required_headers({ 'Name' => :name, 'Notes' => :notes })
          rich_text_headers [ 'Notes' ]

          def cast_notes(_raw_value)
            rich_text_header_value('Notes').to_s
          end
        end

      klass.new(file_path: file.path).import!

      expect(ImporterExcelSpecWidget.find_by(name: 'Widget A').notes).to eq(
        expected_value([ expected_plain_run('hello there') ])
      )
    end

    # A namespace *prefix* (<x:row> under an xmlns:x declaration) is legal, if unusual,
    # XML - `caxlsx` (and every real workbook this project has actually seen) always
    # uses a *default* namespace instead, so this is hand-built directly.
    it 'extracts rich text correctly even when the sheet XML uses a namespace prefix' do
      file = Tempfile.new([ 'import', '.xlsx' ])
      Axlsx::Package.new do |package|
        package.workbook.add_worksheet(name: 'Sheet1') { |sheet| sheet.add_row([ 'placeholder' ]) }
        package.serialize(file.path)
      end

      sheet_xml = <<~XML
        <?xml version="1.0" encoding="UTF-8"?><x:worksheet xmlns:x="http://schemas.openxmlformats.org/spreadsheetml/2006/main"><x:sheetData><x:row r="1"><x:c r="A1" t="inlineStr"><x:is><x:t>Name</x:t></x:is></x:c></x:row><x:row r="2"><x:c r="A2" t="inlineStr"><x:is><x:r><x:rPr><x:b val="1"/></x:rPr><x:t>bold text</x:t></x:r></x:is></x:c></x:row></x:sheetData></x:worksheet>
      XML

      Zip::File.open(file.path) { |zip| zip.get_output_stream('xl/worksheets/sheet1.xml') { |f| f.write(sheet_xml) } }

      klass =
        Class.new(described_class) do
          target_model ImporterExcelSpecWidget
          mode :raw_insert_all
          required_headers({ 'Name' => :name })
          rich_text_headers [ 'Name' ]

          def cast_name(_raw_value)
            rich_text_header_value('Name').to_s
          end
        end

      klass.new(file_path: file.path).import!

      expect(ImporterExcelSpecWidget.first.name).to eq(expected_value([ expected_run('bold text', bold: true) ]))
    end

    it 'accepts a symbol or untrimmed rich_text_headers declaration, matching what extraction already tolerates' do
      klass = rich_text_importer_class { rich_text_headers [ :Notes ] }

      file = write_rich_text_xlsx([ [ 'Widget A', 10, 19.99, Date.new(2024, 1, 5), true, 'plain notes' ] ])

      klass.new(file_path: file.path).import!

      expect(ImporterExcelSpecWidget.find_by(name: 'Widget A').notes).to eq(
        expected_value([ expected_plain_run('plain notes') ])
      )
    end

    it 'extracts an auto color (both valid XSD-boolean spellings), an outline effect, a shadow effect, condense, and extend from a run' do
      file = Tempfile.new([ 'import', '.xlsx' ])
      Axlsx::Package.new do |package|
        package.workbook.add_worksheet(name: 'Sheet1') { |sheet| sheet.add_row([ 'placeholder' ]) }
        package.serialize(file.path)
      end

      sheet_xml = <<~XML
        <?xml version="1.0" encoding="UTF-8"?><worksheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main"><sheetData><row r="1"><c r="A1" t="inlineStr"><is><t>Header</t></is></c></row><row r="2"><c r="A2" t="inlineStr"><is><r><rPr><color auto="1"/><outline val="1"/><shadow val="1"/></rPr><t>styled</t></r><r><rPr><color auto="true"/><condense val="1"/><extend val="1"/></rPr><t>styled2</t></r></is></c></row></sheetData></worksheet>
      XML

      Zip::File.open(file.path) { |zip| zip.get_output_stream('xl/worksheets/sheet1.xml') { |f| f.write(sheet_xml) } }

      klass =
        Class.new(described_class) do
          target_model ImporterExcelSpecWidget
          mode :raw_insert_all
          required_headers({ 'Header' => :name })
          rich_text_headers [ 'Header' ]

          def cast_name(_raw_value)
            rich_text_header_value('Header').to_s
          end
        end

      klass.new(file_path: file.path).import!

      expect(ImporterExcelSpecWidget.first.name).to eq(
        expected_value(
          [
            expected_run('styled', color: { auto: true }, outline: true, shadow: true),
            expected_run('styled2', color: { auto: true }, condense: true, extend: true)
          ]
        )
      )
    end

    it 'extracts a theme-and-tint color and an indexed color, not just a direct rgb value' do
      file = Tempfile.new([ 'import', '.xlsx' ])
      Axlsx::Package.new do |package|
        package.workbook.add_worksheet(name: 'Sheet1') { |sheet| sheet.add_row([ 'placeholder' ]) }
        package.serialize(file.path)
      end

      sheet_xml = <<~XML
        <?xml version="1.0" encoding="UTF-8"?><worksheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main"><sheetData><row r="1"><c r="A1" t="inlineStr"><is><t>Header</t></is></c></row><row r="2"><c r="A2" t="inlineStr"><is><r><rPr><color theme="1" tint="-0.25"/></rPr><t>themed</t></r><r><rPr><color indexed="10"/></rPr><t>indexed</t></r></is></c></row></sheetData></worksheet>
      XML

      Zip::File.open(file.path) { |zip| zip.get_output_stream('xl/worksheets/sheet1.xml') { |f| f.write(sheet_xml) } }

      klass =
        Class.new(described_class) do
          target_model ImporterExcelSpecWidget
          mode :raw_insert_all
          required_headers({ 'Header' => :name })
          rich_text_headers [ 'Header' ]

          def cast_name(_raw_value)
            rich_text_header_value('Header').to_s
          end
        end

      klass.new(file_path: file.path).import!

      expect(ImporterExcelSpecWidget.first.name).to eq(
        expected_value(
          [
            expected_run('themed', color: { theme: 1, tint: -0.25 }),
            expected_run('indexed', color: { indexed: 10 })
          ]
        )
      )
    end

    it "falls back to the cell's own style (bold/size/color/font/charset) for a plain cell with no rich-text run of its own" do
      file = Tempfile.new([ 'import', '.xlsx' ])
      Axlsx::Package.new do |package|
        package.workbook.add_worksheet(name: 'Sheet1') do |sheet|
          sheet.add_row [ 'Header' ]
          bold_red_style =
            sheet.workbook.styles.add_style(b: true, sz: 14, fg_color: 'FFFF0000', font_name: 'Calibri', charset: 1)
          sheet.add_row([ 'plain via cell style' ], style: [ bold_red_style ])
          sheet.add_row([ 'totally plain' ])
        end
        package.serialize(file.path)
      end

      klass =
        Class.new(described_class) do
          target_model ImporterExcelSpecWidget
          mode :raw_insert_all
          required_headers({ 'Header' => :name })
          rich_text_headers [ 'Header' ]

          def cast_name(_raw_value)
            rich_text_header_value('Header').to_s
          end
        end

      klass.new(file_path: file.path).import!

      widgets = ImporterExcelSpecWidget.pluck(:name)

      expect(widgets).to include(
        expected_value(
          [
            expected_run(
              'plain via cell style', bold: true, size: 14.0, color: { rgb: 'FFFF0000' }, font: 'Calibri',
              font_family: 1, charset: 1
            )
          ]
        )
      )
      expect(widgets).to include(expected_value([ expected_plain_run('totally plain') ]))
    end

    # caxlsx's cell-style Font class has no `scheme` setter at all (only its
    # RichTextRun class supports `scheme` - verified directly against the gem source),
    # so the cell-level fallback's own `font_scheme` has to be hand-built directly,
    # the same technique as every other OOXML shape caxlsx can't produce.
    it "falls back to the cell's own style's theme-font scheme for a plain cell with no rich-text run of its own" do
      file = Tempfile.new([ 'import', '.xlsx' ])
      Axlsx::Package.new do |package|
        package.workbook.add_worksheet(name: 'Sheet1') { |sheet| sheet.add_row([ 'placeholder' ]) }
        package.serialize(file.path)
      end

      sheet_xml = <<~XML
        <?xml version="1.0" encoding="UTF-8"?><worksheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main"><sheetData><row r="1"><c r="A1" t="inlineStr"><is><t>Header</t></is></c></row><row r="2"><c r="A2" s="3" t="inlineStr"><is><t>plain via cell style</t></is></c></row></sheetData></worksheet>
      XML

      styles_xml = <<~XML
        <?xml version="1.0" encoding="UTF-8"?><styleSheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main"><fonts count="2"><font><name val="Arial"/><sz val="11"/><family val="1"/></font><font><name val="Calibri"/><sz val="11"/><family val="1"/><scheme val="minor"/></font></fonts><fills count="1"><fill><patternFill patternType="none"></patternFill></fill></fills><borders count="1"><border></border></borders><cellStyleXfs count="1"><xf numFmtId="0" fontId="0" fillId="0" borderId="0"/></cellStyleXfs><cellXfs count="4"><xf numFmtId="0" fontId="0" fillId="0" borderId="0" xfId="0"/><xf numFmtId="0" fontId="0" fillId="0" borderId="0" xfId="0"/><xf numFmtId="0" fontId="0" fillId="0" borderId="0" xfId="0"/><xf numFmtId="0" fontId="1" fillId="0" borderId="0" xfId="0" applyFont="1"/></cellXfs><cellStyles count="1"><cellStyle name="Normal" xfId="0"/></cellStyles></styleSheet>
      XML

      Zip::File.open(file.path) do |zip|
        zip.get_output_stream('xl/worksheets/sheet1.xml') { |f| f.write(sheet_xml) }
        zip.get_output_stream('xl/styles.xml') { |f| f.write(styles_xml) }
      end

      klass =
        Class.new(described_class) do
          target_model ImporterExcelSpecWidget
          mode :raw_insert_all
          required_headers({ 'Header' => :name })
          rich_text_headers [ 'Header' ]

          def cast_name(_raw_value)
            rich_text_header_value('Header').to_s
          end
        end

      klass.new(file_path: file.path).import!

      expect(ImporterExcelSpecWidget.first.name).to eq(
        expected_value(
          [ expected_run('plain via cell style', font: 'Calibri', size: 11.0, font_family: 1, font_scheme: :minor) ]
        )
      )
    end

    it "does not merge a genuinely rich-text cell's runs with its own cell style - only a plain cell falls back" do
      file = Tempfile.new([ 'import', '.xlsx' ])
      Axlsx::Package.new do |package|
        package.workbook.add_worksheet(name: 'Sheet1') do |sheet|
          sheet.add_row [ 'Header' ]
          bold_red_style = sheet.workbook.styles.add_style(b: true, fg_color: 'FFFF0000')
          rt = Axlsx::RichText.new
          rt.add_run('italic run', i: true)
          sheet.add_row([ rt ], style: [ bold_red_style ])
        end
        package.serialize(file.path)
      end

      klass =
        Class.new(described_class) do
          target_model ImporterExcelSpecWidget
          mode :raw_insert_all
          required_headers({ 'Header' => :name })
          rich_text_headers [ 'Header' ]

          def cast_name(_raw_value)
            rich_text_header_value('Header').to_s
          end
        end

      klass.new(file_path: file.path).import!

      expect(ImporterExcelSpecWidget.first.name).to eq(expected_value([ expected_run('italic run', italic: true) ]))
    end

    it 'extracts font family, charset, and theme-font scheme from a run' do
      file = Tempfile.new([ 'import', '.xlsx' ])
      Axlsx::Package.new do |package|
        package.workbook.add_worksheet(name: 'Sheet1') do |sheet|
          sheet.add_row [ 'Header' ]
          rt = Axlsx::RichText.new
          rt.add_run('styled', family: 2, charset: 1, scheme: :minor)
          sheet.add_row [ rt ]
        end
        package.serialize(file.path)
      end

      klass =
        Class.new(described_class) do
          target_model ImporterExcelSpecWidget
          mode :raw_insert_all
          required_headers({ 'Header' => :name })
          rich_text_headers [ 'Header' ]

          def cast_name(_raw_value)
            rich_text_header_value('Header').to_s
          end
        end

      klass.new(file_path: file.path).import!

      expect(ImporterExcelSpecWidget.first.name).to eq(
        expected_value([ expected_run('styled', font_family: 2, charset: 1, font_scheme: :minor) ])
      )
    end

    it 'treats scheme="none" as no theme-font scheme, not a truthy :none value' do
      file = Tempfile.new([ 'import', '.xlsx' ])
      Axlsx::Package.new do |package|
        package.workbook.add_worksheet(name: 'Sheet1') do |sheet|
          sheet.add_row [ 'Header' ]
          rt = Axlsx::RichText.new
          rt.add_run('unscoped', scheme: :none)
          sheet.add_row [ rt ]
        end
        package.serialize(file.path)
      end

      klass =
        Class.new(described_class) do
          target_model ImporterExcelSpecWidget
          mode :raw_insert_all
          required_headers({ 'Header' => :name })
          rich_text_headers [ 'Header' ]

          def cast_name(_raw_value)
            rich_text_header_value('Header').to_s
          end
        end

      klass.new(file_path: file.path).import!

      expect(ImporterExcelSpecWidget.first.name).to eq(expected_value([ expected_run('unscoped') ]))
    end

    # caxlsx has no API for a non-solid pattern fill or a gradient fill, so both are
    # hand-built directly - the same technique as every other OOXML shape it can't
    # produce.
    it "extracts a non-solid pattern fill's pattern type and both colors, not just fgColor" do
      file = Tempfile.new([ 'import', '.xlsx' ])
      Axlsx::Package.new do |package|
        package.workbook.add_worksheet(name: 'Sheet1') { |sheet| sheet.add_row([ 'placeholder' ]) }
        package.serialize(file.path)
      end

      sheet_xml = <<~XML
        <?xml version="1.0" encoding="UTF-8"?><worksheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main"><sheetData><row r="1"><c r="A1" t="inlineStr"><is><t>Header</t></is></c></row><row r="2"><c r="A2" s="3" t="inlineStr"><is><t>patterned</t></is></c></row></sheetData></worksheet>
      XML

      styles_xml = <<~XML
        <?xml version="1.0" encoding="UTF-8"?><styleSheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main"><fonts count="1"><font><name val="Arial"/><sz val="11"/><family val="1"/></font></fonts><fills count="2"><fill><patternFill patternType="none"></patternFill></fill><fill><patternFill patternType="darkGray"><fgColor rgb="FFFF0000"/><bgColor rgb="FF00FF00"/></patternFill></fill></fills><borders count="1"><border></border></borders><cellStyleXfs count="1"><xf numFmtId="0" fontId="0" fillId="0" borderId="0"/></cellStyleXfs><cellXfs count="4"><xf numFmtId="0" fontId="0" fillId="0" borderId="0" xfId="0"/><xf numFmtId="0" fontId="0" fillId="0" borderId="0" xfId="0"/><xf numFmtId="0" fontId="0" fillId="0" borderId="0" xfId="0"/><xf numFmtId="0" fontId="0" fillId="1" borderId="0" xfId="0" applyFill="1"/></cellXfs><cellStyles count="1"><cellStyle name="Normal" xfId="0"/></cellStyles></styleSheet>
      XML

      Zip::File.open(file.path) do |zip|
        zip.get_output_stream('xl/worksheets/sheet1.xml') { |f| f.write(sheet_xml) }
        zip.get_output_stream('xl/styles.xml') { |f| f.write(styles_xml) }
      end

      klass =
        Class.new(described_class) do
          target_model ImporterExcelSpecWidget
          mode :raw_insert_all
          required_headers({ 'Header' => :name })
          rich_text_headers [ 'Header' ]

          def cast_name(_raw_value)
            rich_text_header_value('Header').to_s
          end
        end

      klass.new(file_path: file.path).import!

      expect(ImporterExcelSpecWidget.first.name).to eq(
        expected_value(
          [ expected_plain_run('patterned') ],
          background_color: { pattern_type: :darkGray, fg_color: { rgb: 'FFFF0000' }, bg_color: { rgb: 'FF00FF00' } }
        )
      )
    end

    it "returns a minimal gradient marker for a gradient fill, not nil or a misleading solid color" do
      file = Tempfile.new([ 'import', '.xlsx' ])
      Axlsx::Package.new do |package|
        package.workbook.add_worksheet(name: 'Sheet1') { |sheet| sheet.add_row([ 'placeholder' ]) }
        package.serialize(file.path)
      end

      sheet_xml = <<~XML
        <?xml version="1.0" encoding="UTF-8"?><worksheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main"><sheetData><row r="1"><c r="A1" t="inlineStr"><is><t>Header</t></is></c></row><row r="2"><c r="A2" s="3" t="inlineStr"><is><t>gradient</t></is></c></row></sheetData></worksheet>
      XML

      styles_xml = <<~XML
        <?xml version="1.0" encoding="UTF-8"?><styleSheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main"><fonts count="1"><font><name val="Arial"/><sz val="11"/><family val="1"/></font></fonts><fills count="2"><fill><patternFill patternType="none"></patternFill></fill><fill><gradientFill degree="90"><stop position="0"><color rgb="FFFFFFFF"/></stop><stop position="1"><color rgb="FF000000"/></stop></gradientFill></fill></fills><borders count="1"><border></border></borders><cellStyleXfs count="1"><xf numFmtId="0" fontId="0" fillId="0" borderId="0"/></cellStyleXfs><cellXfs count="4"><xf numFmtId="0" fontId="0" fillId="0" borderId="0" xfId="0"/><xf numFmtId="0" fontId="0" fillId="0" borderId="0" xfId="0"/><xf numFmtId="0" fontId="0" fillId="0" borderId="0" xfId="0"/><xf numFmtId="0" fontId="0" fillId="1" borderId="0" xfId="0" applyFill="1"/></cellXfs><cellStyles count="1"><cellStyle name="Normal" xfId="0"/></cellStyles></styleSheet>
      XML

      Zip::File.open(file.path) do |zip|
        zip.get_output_stream('xl/worksheets/sheet1.xml') { |f| f.write(sheet_xml) }
        zip.get_output_stream('xl/styles.xml') { |f| f.write(styles_xml) }
      end

      klass =
        Class.new(described_class) do
          target_model ImporterExcelSpecWidget
          mode :raw_insert_all
          required_headers({ 'Header' => :name })
          rich_text_headers [ 'Header' ]

          def cast_name(_raw_value)
            rich_text_header_value('Header').to_s
          end
        end

      klass.new(file_path: file.path).import!

      expect(ImporterExcelSpecWidget.first.name).to eq(
        expected_value([ expected_plain_run('gradient') ], background_color: { pattern_type: :gradient })
      )
    end
  end
end
