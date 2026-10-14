require 'spec_helper'
require 'tempfile'
require 'zip'

RSpec.describe Importer::Base do
  # No migrated model has the mix of column types (integer/decimal/date/boolean) needed to
  # exercise the default cast pipeline, so this spec creates its own scratch table instead.
  # rubocop:disable RSpec/BeforeAfterAll -- table DDL, not row data; nothing here needs a per-example rollback
  before(:context) do
    ActiveRecord::Base.connection.create_table :importer_base_spec_widgets, force: true do |t|
      t.string :name
      t.integer :quantity
      t.decimal :price
      t.date :delivered_on
      t.datetime :happened_at
      t.boolean :active
      t.date :date # regression: a column literally named after a Ruby/Date type keyword
      t.string :code # a second, separate unique column - not used as unique_by, only to
      # trigger a DB-level failure unrelated to the raw_upsert_all conflict target
      t.string :external_ref # a nullable unique_by column - Postgres allows any number
      # of NULLs in a unique index, unlike a real duplicate value
      t.jsonb :metadata # a column type this class has no default caster for at all
    end
    ActiveRecord::Base.connection.add_index :importer_base_spec_widgets, :name, unique: true
    ActiveRecord::Base.connection.add_index :importer_base_spec_widgets, :code, unique: true
    ActiveRecord::Base.connection.add_index :importer_base_spec_widgets, :external_ref, unique: true
    ActiveRecord::Base.connection.add_index :importer_base_spec_widgets, :quantity # deliberately not unique
  end

  after(:context) do
    ActiveRecord::Base.connection.drop_table :importer_base_spec_widgets, if_exists: true
  end
  # rubocop:enable RSpec/BeforeAfterAll

  let(:widget_class) do
    Class.new(ApplicationRecord) do
      self.table_name = 'importer_base_spec_widgets'

      # Only exercised by :activerecord mode - the raw_* modes never instantiate a
      # model, so this validation/callback/virtual writer have zero effect on them.
      validates :name, presence: true
      before_save { self.quantity = (quantity || 0) + 1000 }

      def custom_virtual=(value)
        # Not a real column - assigned to `code` too purely so a test can prove this
        # writer actually ran, since @custom_virtual itself is never persisted.
        @custom_virtual = value
        self.code = value
      end

      attr_reader :custom_virtual
    end
  end

  before do
    stub_const('ImporterBaseSpecWidget', widget_class)
    # Postgres sequences aren't transactional - a resync (Importer::Concerns::
    # PrimaryKeyGuard#reset_pk_sequence!) survives this example's own
    # rollback, so a hardcoded "safely out of the way" id in one example (e.g. 999991)
    # can collide with a different example's hardcoded id later, once some other
    # example's allow_primary_key_write run has already bumped the real sequence that
    # high. Resetting here, before every example, while the table is still empty,
    # keeps every example's sequence position deterministic regardless of run order.
    ActiveRecord::Base.connection.reset_pk_sequence!('importer_base_spec_widgets')
  end

  def write_csv(content, extension: '.csv')
    file = Tempfile.new([ 'import', extension ])
    file.binmode
    file.write(content)
    file.close
    file
  end

  def write_zip(entries)
    file = Tempfile.new([ 'import', '.zip' ])
    file.close
    File.delete(file.path)
    Zip::File.open(file.path, create: true) do |zip|
      entries.each { |name, content| zip.get_output_stream(name) { |out| out.write(content) } }
    end
    file
  end

  def importer_class(&block)
    Class.new(described_class) do
      target_model ImporterBaseSpecWidget
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

  def upsert_importer_class(&block)
    Class.new(described_class) do
      target_model ImporterBaseSpecWidget
      mode :raw_upsert_all
      unique_by :name
      required_headers(
        {
          'Name' => :name,
          'Quantity' => :quantity,
          'Price' => :price,
          'Delivered On' => :delivered_on,
          'Active' => :active,
          'Code' => :code
        }
      )

      class_eval(&block) if block
    end
  end

  def activerecord_importer_class(&block)
    Class.new(described_class) do
      target_model ImporterBaseSpecWidget
      mode :activerecord
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

  def activerecord_import_importer_class(&block)
    Class.new(described_class) do
      target_model ImporterBaseSpecWidget
      mode :activerecord_import
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

  describe 'zipped CSV input' do
    let(:csv) { "Name,Quantity,Price,Delivered On,Active\nZip A,10,1.50,2026-01-02,true\nZip B,3,2.00,2026-01-03,false\n" }

    it 'imports the single CSV inside a .zip exactly like a plain .csv' do
      zip = write_zip({ 'widgets.csv' => csv })

      importer = importer_class.new(file_path: zip.path).import!

      expect(ImporterBaseSpecWidget.order(:name).pluck(:name, :quantity)).to eq([ [ 'Zip A', 10 ], [ 'Zip B', 3 ] ])
      expect(importer.logs.last).to include(processed: 2, written: 2)
    end

    it 'honours csv_delimiter for the zipped file' do
      zip = write_zip({ 'widgets.csv' => csv.tr(',', ';') })

      importer_class { csv_delimiter ';' }.new(file_path: zip.path).import!

      expect(ImporterBaseSpecWidget.pluck(:name)).to contain_exactly('Zip A', 'Zip B')
    end

    it 'reports the inner format through file_format - :tsv for a zipped .tsv, :csv for a zipped .csv' do
      seen = []
      klass = importer_class { define_method(:before_batch) { |_batch| seen << file_format } }

      klass.new(file_path: write_zip({ 'w.tsv' => csv.tr(',', "\t") }).path).import!
      klass.new(file_path: write_zip({ 'w.csv' => csv.sub('Zip A', 'Zip C').sub('Zip B', 'Zip D') }).path).import!

      expect(seen).to eq(%i[tsv csv])
    end

    it 'rolls back and raises for a zip holding more than one file, importing nothing' do
      zip = write_zip({ 'a.csv' => csv, 'b.csv' => csv })

      expect { importer_class.new(file_path: zip.path).import! }
        .to raise_error(Importer::Base::ImportError, /exactly one file, found 2/)
      expect(ImporterBaseSpecWidget.count).to eq(0)
    end

    it 'refuses a zipped entry over a declared max_uncompressed_bytes, importing nothing' do
      zip = write_zip({ 'widgets.csv' => csv })

      expect { importer_class { max_uncompressed_bytes 10 }.new(file_path: zip.path).import! }
        .to raise_error(Importer::Base::ImportError, /larger than 10 bytes/)
      expect(ImporterBaseSpecWidget.count).to eq(0)
    end

    it 'rejects a non-positive or non-Integer max_uncompressed_bytes at config time' do
      [ 0, -1, '1MB', 1.5 ].each do |bad|
        expect { importer_class { max_uncompressed_bytes bad }.new(file_path: write_zip({ 'w.csv' => csv }).path).import! }
          .to raise_error(ArgumentError, /max_uncompressed_bytes must be a positive Integer/)
      end
    end

    it 'defaults max_uncompressed_bytes to 512 MB' do
      expect(importer_class.max_uncompressed_bytes).to eq(512.megabytes)
    end

    it 'rejects a zipped Excel file rather than guessing' do
      zip = write_zip({ 'widgets.xlsx' => 'PK' })

      expect { importer_class.new(file_path: zip.path).import! }
        .to raise_error(Importer::Base::ImportError, /must have one of these extensions/)
    end

    it 'reports missing headers from inside the zip' do
      zip = write_zip({ 'widgets.csv' => "Name\nZip A\n" })

      expect { importer_class.new(file_path: zip.path).import! }
        .to raise_error(Importer::Base::ImportError, /Missing required headers/)
    end
  end

  describe 'configuration guards' do
    it 'lets a subclass of an already-configured importer inherit its config, not just Importer::Base itself' do
      parent_klass = importer_class { on_failure :rollback }
      child_klass = Class.new(parent_klass) { on_failure :typo } # deliberately invalid, to prove it's the child's own value

      expect(child_klass.target_model).to eq(ImporterBaseSpecWidget)
      expect(child_klass.mode).to eq(:raw_insert_all)
      expect(child_klass.required_headers).to eq(parent_klass.required_headers)
      expect(child_klass.on_failure).to eq(:typo)
      expect(parent_klass.on_failure).to eq(:rollback) # unaffected by the child's own override
    end

    it 'raises when target_model is not declared' do
      klass =
        Class.new(described_class) do
          required_headers({ 'Name' => :name })
        end

      csv = write_csv("Name\nfoo\n")

      expect { klass.new(file_path: csv.path).import! }
        .to raise_error(ArgumentError, /must declare `target_model`/)
    end

    it 'raises when mode is not declared' do
      klass =
        Class.new(described_class) do
          target_model ImporterBaseSpecWidget
          required_headers({ 'Name' => :name })
        end

      csv = write_csv("Name\nfoo\n")

      expect { klass.new(file_path: csv.path).import! }
        .to raise_error(ArgumentError, /must declare `mode`/)
    end

    it 'raises when mode is not a supported value' do
      klass =
        Class.new(described_class) do
          target_model ImporterBaseSpecWidget
          mode :something_unsupported
          required_headers({ 'Name' => :name })
        end

      csv = write_csv("Name\nfoo\n")

      expect { klass.new(file_path: csv.path).import! }
        .to raise_error(ArgumentError, /unsupported mode `something_unsupported`/)
    end

    it 'raises NotImplementedError if SUPPORTED_MODES ever lists a mode write_batch has no branch for' do
      stub_const('Importer::Base::SUPPORTED_MODES', %i[raw_insert_all raw_upsert_all not_really_a_mode])

      klass =
        Class.new(described_class) do
          target_model ImporterBaseSpecWidget
          mode :not_really_a_mode
          required_headers({ 'Name' => :name })
        end

      csv = write_csv("Name\nWidget A\n")

      expect { klass.new(file_path: csv.path).import! }
        .to raise_error(NotImplementedError, /not_really_a_mode mode is not implemented yet/)
    end

    it 'raises when required_headers maps to a column that does not exist' do
      klass =
        Class.new(described_class) do
          target_model ImporterBaseSpecWidget
          mode :raw_insert_all
          required_headers({ 'Name' => :not_a_real_column })
        end

      csv = write_csv("Name\nfoo\n")

      expect { klass.new(file_path: csv.path).import! }
        .to raise_error(ArgumentError, /is not writable.*raw_insert_all mode writes real columns only/)
    end

    it 'raises when raw_upsert_all mode does not declare unique_by' do
      klass =
        Class.new(described_class) do
          target_model ImporterBaseSpecWidget
          mode :raw_upsert_all
          required_headers({ 'Name' => :name })
        end

      csv = write_csv("Name\nfoo\n")

      expect { klass.new(file_path: csv.path).import! }
        .to raise_error(ArgumentError, /must declare `unique_by`/)
    end

    it 'raises when unique_by names a column with no index at all' do
      klass =
        Class.new(described_class) do
          target_model ImporterBaseSpecWidget
          mode :raw_upsert_all
          unique_by :price
          required_headers({ 'Name' => :name, 'Price' => :price })
        end

      csv = write_csv("Name,Price\nfoo,1.00\n")

      expect { klass.new(file_path: csv.path).import! }
        .to raise_error(ArgumentError, /no unique index found.*unique_by: :price/)
    end

    it 'raises when unique_by names a column that has an index, but the index is not unique' do
      klass =
        Class.new(described_class) do
          target_model ImporterBaseSpecWidget
          mode :raw_upsert_all
          unique_by :quantity
          required_headers({ 'Name' => :name, 'Quantity' => :quantity })
        end

      csv = write_csv("Name,Quantity\nfoo,1\n")

      expect { klass.new(file_path: csv.path).import! }
        .to raise_error(ArgumentError, /no unique index found.*unique_by: :quantity/)
    end

    it 'raises when unique_by names an existing index by name, but the index is not unique' do
      klass =
        Class.new(described_class) do
          target_model ImporterBaseSpecWidget
          mode :raw_upsert_all
          unique_by :index_importer_base_spec_widgets_on_quantity
          required_headers({ 'Name' => :name, 'Quantity' => :quantity })
        end

      csv = write_csv("Name,Quantity\nfoo,1\n")

      expect { klass.new(file_path: csv.path).import! }
        .to raise_error(ArgumentError, /no unique index found/)
    end

    it 'raises when on_failure :skip is declared on a mode that does not support it' do
      klass = importer_class { on_failure :skip }

      csv = write_csv("Name,Quantity,Price,Delivered On,Active\nWidget A,10,19.99,2024-01-05,yes\n")

      expect { klass.new(file_path: csv.path).import! }
        .to raise_error(ArgumentError, /on_failure :skip is not supported by raw_insert_all mode/)
    end

    it 'raises for an unrecognized on_failure value on a model-backed mode, rather than silently ' \
       'behaving like :rollback' do
      klass = activerecord_importer_class { on_failure :typo }

      csv = write_csv("Name,Quantity,Price,Delivered On,Active\nWidget A,10,19.99,2024-01-05,yes\n")

      expect { klass.new(file_path: csv.path).import! }
        .to raise_error(ArgumentError, /on_failure must be one of :rollback or :skip, got :typo/)
    end

    it 'raises for an unrecognized on_failure value on a raw mode, with a message about the value, ' \
       'not a misleading "skip not supported" message' do
      klass = importer_class { on_failure :typo }

      csv = write_csv("Name,Quantity,Price,Delivered On,Active\nWidget A,10,19.99,2024-01-05,yes\n")

      expect { klass.new(file_path: csv.path).import! }
        .to raise_error(ArgumentError, /on_failure must be one of :rollback or :skip, got :typo/)
    end

    it 'allows on_failure :skip for activerecord mode' do
      klass = activerecord_importer_class { on_failure :skip }

      csv = write_csv("Name,Quantity,Price,Delivered On,Active\nWidget A,10,19.99,2024-01-05,yes\n")

      expect { klass.new(file_path: csv.path).import! }.not_to raise_error
    end

    it 'allows a virtual/writer-method attribute for activerecord mode, unlike the raw modes' do
      klass =
        activerecord_importer_class do
          required_headers(
            {
              'Name' => :name,
              'Quantity' => :quantity,
              'Price' => :price,
              'Delivered On' => :delivered_on,
              'Active' => :active,
              'Virtual' => :custom_virtual
            }
          )
        end

      csv = write_csv("Name,Quantity,Price,Delivered On,Active,Virtual\nWidget A,10,19.99,2024-01-05,yes,hi\n")

      expect { klass.new(file_path: csv.path).import! }.not_to raise_error
    end

    it 'raises for activerecord mode when required_headers maps to something with no attribute or writer at all' do
      klass =
        activerecord_importer_class do
          required_headers({ 'Name' => :name, 'Nope' => :totally_not_a_thing })
        end

      csv = write_csv("Name,Nope\nfoo,bar\n")

      expect { klass.new(file_path: csv.path).import! }
        .to raise_error(ArgumentError, /no such attribute or writer method/)
    end

    it 'accepts an index name for unique_by, not just a column' do
      klass =
        Class.new(described_class) do
          target_model ImporterBaseSpecWidget
          mode :raw_upsert_all
          unique_by :index_importer_base_spec_widgets_on_name
          required_headers({ 'Name' => :name })
        end

      csv = write_csv("Name\nWidget A\n")

      expect { klass.new(file_path: csv.path).import! }.not_to raise_error
      expect(ImporterBaseSpecWidget.find_by(name: 'Widget A')).to be_present
    end

    it 'raises when unique_by names a real unique index but required_headers never maps that column' do
      klass =
        Class.new(described_class) do
          target_model ImporterBaseSpecWidget
          mode :raw_upsert_all
          unique_by :name
          required_headers({ 'Quantity' => :quantity })
        end

      csv = write_csv("Quantity\n1\n")

      expect { klass.new(file_path: csv.path).import! }
        .to raise_error(ArgumentError, /unique_by column\(s\) name must be mapped in required_headers/)
    end

    it 'raises when a derived attribute has no cast_ method to produce its value' do
      klass = importer_class { derived_attributes :code }

      csv = write_csv("Name,Quantity,Price,Delivered On,Active\nWidget A,10,19.99,2024-01-05,yes\n")

      expect { klass.new(file_path: csv.path).import! }
        .to raise_error(ArgumentError, /derived attribute 'code' has no cast_code method/)
    end

    it 'raises when the same attribute is both mapped in required_headers and declared derived' do
      klass =
        importer_class do
          derived_attributes :name

          def cast_name(_raw_value)
            'whatever'
          end
        end

      csv = write_csv("Name,Quantity,Price,Delivered On,Active\nWidget A,10,19.99,2024-01-05,yes\n")

      expect { klass.new(file_path: csv.path).import! }
        .to raise_error(ArgumentError, /'name' is declared in derived_attributes and also mapped in required_headers/)
    end

    it 'raises when a derived attribute is not writable on target_model, the same as a mapped one' do
      klass =
        importer_class do
          derived_attributes :not_a_real_column

          def cast_not_a_real_column(_raw_value)
            'whatever'
          end
        end

      csv = write_csv("Name,Quantity,Price,Delivered On,Active\nWidget A,10,19.99,2024-01-05,yes\n")

      expect { klass.new(file_path: csv.path).import! }
        .to raise_error(ArgumentError, /'not_a_real_column' is not writable/)
    end

    it 'applies the primary key write guard to a derived attribute too, not just a mapped one' do
      klass =
        importer_class do
          derived_attributes :id

          def cast_id(_raw_value)
            999_999
          end
        end

      csv = write_csv("Name,Quantity,Price,Delivered On,Active\nWidget A,10,19.99,2024-01-05,yes\n")

      expect { klass.new(file_path: csv.path).import! }
        .to raise_error(ArgumentError, /'id' is the primary key.*declaring it in derived_attributes/m)
    end

    it 'accepts a derived attribute as the unique_by conflict target, since it is still written' do
      klass =
        Class.new(described_class) do
          target_model ImporterBaseSpecWidget
          mode :raw_upsert_all
          unique_by :name
          required_headers({ 'Quantity' => :quantity })
          derived_attributes :name

          def cast_name(_raw_value)
            "Widget #{raw_value_for(:quantity)}"
          end
        end

      csv = write_csv("Quantity\n7\n")

      expect { klass.new(file_path: csv.path).import! }.not_to raise_error
      expect(ImporterBaseSpecWidget.find_by(name: 'Widget 7').quantity).to eq(7)
    end
  end

  describe 'derived_attributes' do
    it 'writes an attribute that has no source column at all, from its own cast_ method' do
      klass =
        importer_class do
          required_headers({ 'Name' => :name, 'Quantity' => :quantity })
          derived_attributes :active

          def cast_active(_raw_value)
            raw_value_for(:name).start_with?('Global')
          end
        end

      csv = write_csv(<<~CSV)
        Name,Quantity
        Global Ocean,1
        North Sea,2
      CSV

      klass.new(file_path: csv.path).import!

      expect(ImporterBaseSpecWidget.find_by(name: 'Global Ocean').active).to be(true)
      expect(ImporterBaseSpecWidget.find_by(name: 'North Sea').active).to be(false)
    end

    it 'passes nil as the raw value, since there is no column for it to come from' do
      received = []

      klass =
        importer_class do
          required_headers({ 'Name' => :name })
          derived_attributes :code

          define_method(:cast_code) do |raw_value|
            received << raw_value
            "code-#{raw_value_for(:name)}"
          end
        end

      csv = write_csv("Name\nWidget A\n")

      klass.new(file_path: csv.path).import!

      expect(received).to eq([ nil ])
      expect(ImporterBaseSpecWidget.find_by(name: 'Widget A').code).to eq('code-Widget A')
    end

    it 'still raises from raw_value_for when a derived attribute is asked for by name - it has no header' do
      klass =
        importer_class do
          required_headers({ 'Name' => :name })
          derived_attributes :code

          def cast_code(_raw_value)
            raw_value_for(:code)
          end
        end

      csv = write_csv("Name\nWidget A\n")

      expect { klass.new(file_path: csv.path).import! }
        .to raise_error(described_class::ImportError, /code.*is not in required_headers/)
    end

    it 'works the same in activerecord mode, including for a hand-written virtual writer' do
      klass =
        activerecord_importer_class do
          required_headers({ 'Name' => :name })
          derived_attributes :custom_virtual

          def cast_custom_virtual(_raw_value)
            "virtual-#{raw_value_for(:name)}"
          end
        end

      csv = write_csv("Name\nWidget A\n")

      klass.new(file_path: csv.path).import!

      # The writer assigns `code` too, which is what proves it actually ran.
      expect(ImporterBaseSpecWidget.find_by(name: 'Widget A').code).to eq('virtual-Widget A')
    end

    it 'accepts several derived attributes at once' do
      klass =
        importer_class do
          required_headers({ 'Name' => :name })
          derived_attributes %i[code active]

          def cast_code(_raw_value)
            'fixed-code'
          end

          def cast_active(_raw_value)
            true
          end
        end

      csv = write_csv("Name\nWidget A\n")

      klass.new(file_path: csv.path).import!

      widget = ImporterBaseSpecWidget.find_by(name: 'Widget A')
      expect(widget.code).to eq('fixed-code')
      expect(widget.active).to be(true)
    end

    it 'reports a raising derived cast the same way a mapped column cast is reported' do
      klass =
        importer_class do
          required_headers({ 'Name' => :name })
          derived_attributes :quantity

          def cast_quantity(_raw_value)
            raise 'no quantity to derive'
          end
        end

      csv = write_csv("Name\nWidget A\n")
      importer = klass.new(file_path: csv.path)

      expect { importer.import! }
        .to raise_error(described_class::ImportError, /Line 2, column 'quantity': no quantity to derive/)
      expect(importer.logs).to include(hash_including(level: 'error', row: 2, column: 'quantity'))
    end

    it 'is inherited by a subclass, like every other config macro' do
      parent_klass =
        importer_class do
          derived_attributes :code

          def cast_code(_raw_value)
            'inherited'
          end
        end

      expect(Class.new(parent_klass).derived_attributes).to eq([ :code ])
    end

    it 'defaults to an empty list, so an importer that never declares one is unaffected' do
      expect(importer_class.derived_attributes).to eq([])
      expect(importer_class.written_attributes).to eq(%i[name quantity price delivered_on active])
    end
  end

  describe '#import!' do
    it 'casts and inserts valid rows' do
      csv = write_csv(<<~CSV)
        Name,Quantity,Price,Delivered On,Active
        Widget A,10,19.99,2024-01-05,yes
        Widget B,3,5.50,2024-02-01,N
      CSV

      importer = importer_class.new(file_path: csv.path)
      importer.import!

      expect(ImporterBaseSpecWidget.count).to eq(2)

      widget_a = ImporterBaseSpecWidget.find_by(name: 'Widget A')
      expect(widget_a.quantity).to eq(10)
      expect(widget_a.price).to eq(BigDecimal('19.99'))
      expect(widget_a.delivered_on).to eq(Date.new(2024, 1, 5))
      expect(widget_a.active).to be(true)

      widget_b = ImporterBaseSpecWidget.find_by(name: 'Widget B')
      expect(widget_b.active).to be(false)
    end

    it 'records a summary log entry after a successful import' do
      csv = write_csv(<<~CSV)
        Name,Quantity,Price,Delivered On,Active
        Widget A,10,19.99,2024-01-05,yes
      CSV

      importer = importer_class.new(file_path: csv.path)
      importer.import!

      expect(importer.logs).to include(
        a_hash_including(level: 'info', processed: 1, written: 1)
      )
    end

    it 'raises and imports nothing when a required header is missing' do
      csv = write_csv(<<~CSV)
        Name,Quantity,Price,Active
        Widget A,10,19.99,yes
      CSV

      importer = importer_class.new(file_path: csv.path)

      expect { importer.import! }.to raise_error(described_class::ImportError, /Missing required headers/)
      expect(ImporterBaseSpecWidget.count).to eq(0)
    end

    it 'tolerates stray whitespace around header names' do
      csv = write_csv(<<~CSV)
        Name, Quantity ,Price,Delivered On,Active
        Widget A,10,19.99,2024-01-05,yes
      CSV

      importer_class.new(file_path: csv.path).import!

      expect(ImporterBaseSpecWidget.find_by(name: 'Widget A').quantity).to eq(10)
    end

    it 'raises when a required header appears more than once in the file' do
      csv = write_csv(<<~CSV)
        Name,Name,Quantity,Price,Delivered On,Active
        Widget A,Widget B,10,19.99,2024-01-05,yes
      CSV

      importer = importer_class.new(file_path: csv.path)

      expect { importer.import! }.to raise_error(described_class::ImportError, /Duplicate header\(s\) in file: Name/)
      expect(ImporterBaseSpecWidget.count).to eq(0)
    end

    it 'drops a fully blank row by default rather than writing it as an all-NULL record' do
      csv = write_csv(<<~CSV)
        Name,Quantity,Price,Delivered On,Active
        Widget A,10,19.99,2024-01-05,yes

        Widget B,3,5.50,2024-02-01,no
      CSV

      importer = importer_class.new(file_path: csv.path)
      importer.import!

      expect(ImporterBaseSpecWidget.count).to eq(2)
      expect(importer.logs).to include(a_hash_including(level: 'info', processed: 2))
    end

    it 'processes a blank row as real data when drop_blank_rows is disabled' do
      klass = importer_class { drop_blank_rows false }

      csv = write_csv(<<~CSV)
        Name,Quantity,Price,Delivered On,Active
        Widget A,10,19.99,2024-01-05,yes

      CSV

      klass.new(file_path: csv.path).import!

      expect(ImporterBaseSpecWidget.count).to eq(2)
      expect(ImporterBaseSpecWidget.where(name: nil).count).to eq(1)
    end

    it 'excludes a row via a subclass exclude_row? override, based on a column outside required_headers' do
      klass =
        importer_class do
          def exclude_row?(row)
            row['Status'] == 'Draft'
          end
        end

      csv = write_csv(<<~CSV)
        Name,Quantity,Price,Delivered On,Active,Status
        Widget A,10,19.99,2024-01-05,yes,Published
        Widget B,3,5.50,2024-02-01,no,Draft
      CSV

      klass.new(file_path: csv.path).import!

      expect(ImporterBaseSpecWidget.pluck(:name)).to eq([ 'Widget A' ])
    end

    it 'lets exclude_row? read the current row via raw_header_value, including on the very first row' do
      # Regression: @current_row/@current_line_number used to be set only inside
      # build_attributes, which doesn't run until after exclude_row? has already returned -
      # so raw_header_value called from exclude_row? on the very first row read @current_row
      # while it was still nil (raising NoMethodError), and on any later row read whatever
      # row was processed *previously*, not the one exclude_row? was actually deciding on.
      klass =
        importer_class do
          def exclude_row?(row)
            raw_header_value('Status') == 'Draft'
          end
        end

      csv = write_csv(<<~CSV)
        Name,Quantity,Price,Delivered On,Active,Status
        Widget A,10,19.99,2024-01-05,yes,Draft
        Widget B,3,5.50,2024-02-01,no,Published
        Widget C,7,1.23,2024-03-01,yes,Draft
      CSV

      klass.new(file_path: csv.path).import!

      expect(ImporterBaseSpecWidget.pluck(:name)).to eq([ 'Widget B' ])
    end

    it 'lets exclude_row? read the current row via raw_value_for, not a mapped attribute cast_ override' do
      klass =
        importer_class do
          def exclude_row?(row)
            raw_value_for(:name) == 'Widget B'
          end
        end

      csv = write_csv(<<~CSV)
        Name,Quantity,Price,Delivered On,Active
        Widget A,10,19.99,2024-01-05,yes
        Widget B,3,5.50,2024-02-01,no
      CSV

      klass.new(file_path: csv.path).import!

      expect(ImporterBaseSpecWidget.pluck(:name)).to eq([ 'Widget A' ])
    end

    it 'counts an excluded row separately in the summary log entry, not toward processed_count' do
      klass =
        importer_class do
          def exclude_row?(row)
            row['Status'] == 'Draft'
          end
        end

      csv = write_csv(<<~CSV)
        Name,Quantity,Price,Delivered On,Active,Status
        Widget A,10,19.99,2024-01-05,yes,Published
        Widget B,3,5.50,2024-02-01,no,Draft
        Widget C,7,1.23,2024-03-01,yes,Published
      CSV

      importer = klass.new(file_path: csv.path)
      importer.import!

      expect(importer.logs).to include(
        a_hash_including(level: 'info', processed: 2, written: 2, skipped: 0, excluded: 1)
      )
    end

    it 'excludes nothing by default when a subclass does not override exclude_row?' do
      csv = write_csv(<<~CSV)
        Name,Quantity,Price,Delivered On,Active
        Widget A,10,19.99,2024-01-05,yes
      CSV

      importer = importer_class.new(file_path: csv.path)
      importer.import!

      expect(importer.logs).to include(a_hash_including(level: 'info', excluded: 0))
    end

    it 'raises before processing any row when the file has invalid UTF-8 bytes' do
      csv = write_csv("Name,Quantity,Price,Delivered On,Active\nWidget A,10,19.99,2024-01-05,yes\n")
      File.open(csv.path, 'ab') { |f| f.write("Bad\xFF,1,1,2024-01-01,yes\n".b) }

      importer = importer_class.new(file_path: csv.path)

      expect { importer.import! }.to raise_error(described_class::ImportError, /Invalid UTF-8/)
      expect(ImporterBaseSpecWidget.count).to eq(0)
    end

    describe 'skip_file_validation' do
      it 'no longer catches invalid UTF-8 bytes with this class\'s own clear error - Ruby\'s CSV parser still ' \
         'raises its own, less helpful error once it reaches the bad line, just not before any row is processed' do
        klass = importer_class { skip_file_validation true }
        csv = write_csv("Name,Quantity,Price,Delivered On,Active\nWidget A,10,19.99,2024-01-05,yes\n")
        File.open(csv.path, 'ab') { |f| f.write("Bad\xFF,1,1,2024-01-01,yes\n".b) }

        expect { klass.new(file_path: csv.path).import! }
          .to raise_error { |error| expect(error).not_to be_a(described_class::ImportError) }
      end

      it 'does not affect a genuinely valid UTF-8 file - the import still succeeds normally' do
        klass = importer_class { skip_file_validation true }
        csv = write_csv("Name,Quantity,Price,Delivered On,Active\nWidget A,10,19.99,2024-01-05,yes\n")

        klass.new(file_path: csv.path).import!

        expect(ImporterBaseSpecWidget.count).to eq(1)
      end

      it 'still raises for a missing required header even when skip_file_validation is true' do
        klass = importer_class { skip_file_validation true }
        csv = write_csv("Quantity,Price,Delivered On,Active\n10,19.99,2024-01-05,yes\n")

        expect { klass.new(file_path: csv.path).import! }
          .to raise_error(described_class::ImportError, /Missing required headers: Name/)
      end

      it 'still raises for invalid UTF-8 bytes when skip_file_validation is false (the default)' do
        csv = write_csv("Name,Quantity,Price,Delivered On,Active\nWidget A,10,19.99,2024-01-05,yes\n")
        File.open(csv.path, 'ab') { |f| f.write("Bad\xFF,1,1,2024-01-01,yes\n".b) }

        expect { importer_class.new(file_path: csv.path).import! }
          .to raise_error(described_class::ImportError, /Invalid UTF-8/)
      end
    end

    it 'raises before any file I/O when file_path does not end in .csv, .tsv, or .xlsx' do
      csv = write_csv("Name,Quantity,Price,Delivered On,Active\nWidget A,10,19.99,2024-01-05,yes\n", extension: '.txt')

      importer = importer_class.new(file_path: csv.path)

      expect { importer.import! }
        .to raise_error(described_class::ImportError, /file must have one of these extensions: \.csv, \.tsv, \.xlsx/)
      expect(ImporterBaseSpecWidget.count).to eq(0)
    end

    it 'raises at config time when csv_delimiter is not comma or semicolon' do
      klass = importer_class { csv_delimiter '|' }

      csv = write_csv("Name,Quantity,Price,Delivered On,Active\nWidget A,10,19.99,2024-01-05,yes\n")

      expect { klass.new(file_path: csv.path).import! }
        .to raise_error(ArgumentError, /csv_delimiter must be one of.*got "\|"/)
    end

    it 'reads a semicolon-delimited .csv file when csv_delimiter is declared' do
      klass = importer_class { csv_delimiter ';' }

      csv = write_csv("Name;Quantity;Price;Delivered On;Active\nWidget A;10;19.99;2024-01-05;yes\n")

      klass.new(file_path: csv.path).import!

      expect(ImporterBaseSpecWidget.pluck(:name)).to eq([ 'Widget A' ])
    end

    it 'reads a .tsv file as tab-delimited without any csv_delimiter declaration' do
      csv = write_csv("Name\tQuantity\tPrice\tDelivered On\tActive\nWidget A\t10\t19.99\t2024-01-05\tyes\n", extension: '.tsv')

      importer_class.new(file_path: csv.path).import!

      expect(ImporterBaseSpecWidget.pluck(:name)).to eq([ 'Widget A' ])
    end

    it 'ignores a declared csv_delimiter for a .tsv file - tab always wins' do
      klass = importer_class { csv_delimiter ';' }

      csv = write_csv("Name\tQuantity\tPrice\tDelivered On\tActive\nWidget A\t10\t19.99\t2024-01-05\tyes\n", extension: '.tsv')

      klass.new(file_path: csv.path).import!

      expect(ImporterBaseSpecWidget.pluck(:name)).to eq([ 'Widget A' ])
    end

    it 'raises at config time when csv_encoding is not a known encoding' do
      klass = importer_class { csv_encoding 'Not-A-Real-Encoding' }

      csv = write_csv("Name,Quantity,Price,Delivered On,Active\nWidget A,10,19.99,2024-01-05,yes\n")

      expect { klass.new(file_path: csv.path).import! }
        .to raise_error(ArgumentError, /csv_encoding "Not-A-Real-Encoding" is not a known encoding/)
    end

    it 'transcodes a declared csv_encoding to UTF-8, including non-ASCII characters' do
      klass =
        importer_class do
          csv_encoding 'Windows-1252'
          required_headers({ 'Name' => :name, 'Code' => :code })
        end

      content = "Name,Code\nWidget A,Café “deluxe”\n".encode('Windows-1252')
      csv = write_csv(content)

      klass.new(file_path: csv.path).import!

      widget = ImporterBaseSpecWidget.find_by(name: 'Widget A')
      expect(widget.code).to eq('Café “deluxe”')
    end

    it 'transcodes a multi-byte csv_encoding (Big5) to UTF-8 too, not just single-byte ones' do
      klass =
        importer_class do
          csv_encoding 'Big5'
          required_headers({ 'Name' => :name, 'Code' => :code })
        end

      content = "Name,Code\nWidget A,廣東話\n".encode('Big5')
      csv = write_csv(content)

      klass.new(file_path: csv.path).import!

      expect(ImporterBaseSpecWidget.find_by(name: 'Widget A').code).to eq('廣東話')
    end

    it 'raises a clear error naming the declared encoding and line number for a byte that does not fit it' do
      klass = importer_class { csv_encoding 'Windows-1252' }

      csv = write_csv("Name,Quantity,Price,Delivered On,Active\nWidget A,10,19.99,2024-01-05,yes\n")
      File.open(csv.path, 'ab') { |f| f.write("Bad\x81,1,1,2024-01-01,yes\n".b) }

      expect { klass.new(file_path: csv.path).import! }
        .to raise_error(described_class::ImportError, /Invalid Windows-1252 encoding at line 3/)
      expect(ImporterBaseSpecWidget.count).to eq(0)
    end

    # Regression: csv_encoding declared as UTF-8 itself (redundant, but not an error to
    # write) must not lose BOM handling - "utf-8:UTF-8" alone has no BOM awareness at
    # all, unlike the default 'bom|utf-8', and would otherwise bake the BOM into the
    # first header as a literal U+FEFF character, breaking required_headers matching.
    it 'still strips a leading BOM when csv_encoding is declared as UTF-8 itself' do
      klass = importer_class { csv_encoding 'utf-8' }

      csv = write_csv("\xEF\xBB\xBFName,Quantity,Price,Delivered On,Active\nWidget A,10,19.99,2024-01-05,yes\n".b)

      klass.new(file_path: csv.path).import!

      expect(ImporterBaseSpecWidget.pluck(:name)).to eq([ 'Widget A' ])
    end

    # csv_encoding declared as UTF-8 takes the same validation path as no csv_encoding at
    # all (Parsers::Csv#effective_utf8?), not the declared-encoding transcode path. That
    # matters: 'bom|utf-8' does no transcode, so there is no EncodingError for the
    # declared path to rescue - a malformed byte used to slip past validation entirely and
    # surface mid-import as a raw CSV::InvalidEncodingError, inside the run's transaction.
    it 'rejects a malformed byte at validation time when csv_encoding is declared as UTF-8' do
      klass = importer_class { csv_encoding 'utf-8' }

      csv = write_csv("Name,Quantity,Price,Delivered On,Active\nWidget A,10,19.99,2024-01-05,yes\n\xFF\xFEbroken\n".b)

      expect { klass.new(file_path: csv.path).import! }
        .to raise_error(described_class::ImportError, /Invalid UTF-8 encoding at line 3/)
      expect(ImporterBaseSpecWidget.count).to eq(0)
    end

    it 'answers file_format before import! has built a parser' do
      klass = importer_class

      csv = write_csv("Name,Quantity,Price,Delivered On,Active\n")

      expect(klass.new(file_path: csv.path).send(:file_format)).to eq(:csv)
      expect(klass.new(file_path: csv.path).send(:excel_file?)).to be(false)
    end

    it 'lets a subclass read file_format (:csv) from cast_<attribute>' do
      klass =
        Class.new(described_class) do
          target_model ImporterBaseSpecWidget
          mode :raw_insert_all
          required_headers({ 'Name' => :name })

          def cast_name(_raw_value)
            file_format.to_s
          end
        end

      csv = write_csv("Name\nWidget A\n")

      klass.new(file_path: csv.path).import!

      expect(ImporterBaseSpecWidget.pluck(:name)).to eq([ 'csv' ])
    end

    it 'lets a subclass read file_format (:tsv) from cast_<attribute>' do
      klass =
        Class.new(described_class) do
          target_model ImporterBaseSpecWidget
          mode :raw_insert_all
          required_headers({ 'Name' => :name })

          def cast_name(_raw_value)
            file_format.to_s
          end
        end

      csv = write_csv("Name\nWidget A\n", extension: '.tsv')

      klass.new(file_path: csv.path).import!

      expect(ImporterBaseSpecWidget.pluck(:name)).to eq([ 'tsv' ])
    end

    # Integer() without an explicit base applies Ruby's own literal prefix rules to the
    # string. Zero-padded numeric codes are common in CSV/Excel exports, so this is the
    # difference between reading a reference number correctly and silently writing a
    # different one.
    it 'parses a zero-padded integer as decimal, not octal' do
      csv = write_csv(<<~CSV)
        Name,Quantity,Price,Delivered On,Active
        Widget A,007,19.99,2024-01-05,yes
        Widget B,010,19.99,2024-01-05,yes
        Widget C,08,19.99,2024-01-05,yes
        Widget D,09,19.99,2024-01-05,yes
      CSV

      importer_class.new(file_path: csv.path).import!

      expect(ImporterBaseSpecWidget.order(:name).pluck(:quantity)).to eq([ 7, 10, 8, 9 ])
    end

    it 'rejects a hex or binary literal rather than silently accepting it as a number' do
      %w[0x1F 0b11].each do |literal|
        ImporterBaseSpecWidget.delete_all

        csv = write_csv(<<~CSV)
          Name,Quantity,Price,Delivered On,Active
          Widget A,#{literal},19.99,2024-01-05,yes
        CSV

        expect { importer_class.new(file_path: csv.path).import! }
          .to raise_error(described_class::ImportError, /invalid integer: "#{literal}"/)
        expect(ImporterBaseSpecWidget.count).to eq(0)
      end
    end

    it 'rolls back the whole batch when a later row fails to cast' do
      csv = write_csv(<<~CSV)
        Name,Quantity,Price,Delivered On,Active
        Widget A,10,19.99,2024-01-05,yes
        Widget B,not_a_number,5.50,2024-02-01,no
      CSV

      importer = importer_class.new(file_path: csv.path)

      expect { importer.import! }.to raise_error(described_class::ImportError, /invalid integer/)
      expect(ImporterBaseSpecWidget.count).to eq(0)
    end

    it 'raises a clear error for an invalid decimal value' do
      csv = write_csv(<<~CSV)
        Name,Quantity,Price,Delivered On,Active
        Widget A,10,not_a_price,2024-01-05,yes
      CSV

      importer = importer_class.new(file_path: csv.path)

      expect { importer.import! }.to raise_error(described_class::ImportError, /invalid decimal/)
    end

    # Its own isolated scratch table, not a column added to ImporterBaseSpecWidget - :price
    # there is an unscaled decimal (no precision/scale given at all), which is exactly one
    # of the cases this feature needs to prove never raises, so it can't also be the
    # column used to prove the opposite (a *scaled* decimal raising past its scale).
    describe 'decimal scale enforcement' do
      before do
        ActiveRecord::Base.connection.create_table :importer_decimal_scale_spec_widgets, force: true do |t|
          t.string :name
          t.decimal :amount, precision: 6, scale: 2
          t.decimal :amount_unscaled
        end
        stub_const(
          'ImporterDecimalScaleSpecWidget',
          Class.new(ApplicationRecord) { self.table_name = 'importer_decimal_scale_spec_widgets' }
        )
      end

      after do
        ActiveRecord::Base.connection.drop_table :importer_decimal_scale_spec_widgets, if_exists: true
      end

      def decimal_scale_importer_class(&block)
        Class.new(described_class) do
          target_model ImporterDecimalScaleSpecWidget
          mode :raw_insert_all
          required_headers({ 'Name' => :name, 'Amount' => :amount })
          class_eval(&block) if block
        end
      end

      # Regression: this used to be silently rounded away with no error at all - verified
      # empirically that ActiveRecord::Type::Decimal#cast (what insert_all!/upsert_all/a
      # plain model assignment all eventually run a value through) rounds silently to a
      # column's scale, so a decimal(6,2) column given "123.4567" used to store 123.46
      # with nothing raised and nothing logged. See FINDINGS.md.
      it 'raises when a value has more decimal places than the column scale allows' do
        csv = write_csv(<<~CSV)
          Name,Amount
          Widget A,123.4567
        CSV

        importer = decimal_scale_importer_class.new(file_path: csv.path)

        expect { importer.import! }
          .to raise_error(described_class::ImportError, /has more decimal places than this column's scale of 2 allows/)
        expect(ImporterDecimalScaleSpecWidget.count).to eq(0)
      end

      it 'does not raise when a value fits exactly within the column scale' do
        csv = write_csv(<<~CSV)
          Name,Amount
          Widget A,123.46
        CSV

        decimal_scale_importer_class.new(file_path: csv.path).import!

        expect(ImporterDecimalScaleSpecWidget.find_by(name: 'Widget A').amount).to eq(BigDecimal('123.46'))
      end

      it 'does not raise when a value has fewer decimal places than the column scale allows' do
        csv = write_csv(<<~CSV)
          Name,Amount
          Widget A,123.4
        CSV

        decimal_scale_importer_class.new(file_path: csv.path).import!

        expect(ImporterDecimalScaleSpecWidget.find_by(name: 'Widget A').amount).to eq(BigDecimal('123.4'))
      end

      it 'never raises for an unscaled decimal column, regardless of how many decimal places the value has' do
        klass =
          decimal_scale_importer_class { required_headers({ 'Name' => :name, 'Amount' => :amount_unscaled }) }

        csv = write_csv(<<~CSV)
          Name,Amount
          Widget A,123.456789
        CSV

        klass.new(file_path: csv.path).import!

        expect(ImporterDecimalScaleSpecWidget.find_by(name: 'Widget A').amount_unscaled).to eq(BigDecimal('123.456789'))
      end
    end

    it 'raises a clear error for an invalid date value' do
      csv = write_csv(<<~CSV)
        Name,Quantity,Price,Delivered On,Active
        Widget A,10,19.99,not_a_date,yes
      CSV

      importer = importer_class.new(file_path: csv.path)

      expect { importer.import! }.to raise_error(described_class::ImportError, /invalid date/)
    end

    it 'preserves the time-of-day for a :datetime column, unlike a :date column' do
      klass =
        importer_class do
          required_headers(
            {
              'Name' => :name,
              'Quantity' => :quantity,
              'Price' => :price,
              'Delivered On' => :delivered_on,
              'Active' => :active,
              'Happened At' => :happened_at
            }
          )
        end

      csv = write_csv(<<~CSV)
        Name,Quantity,Price,Delivered On,Active,Happened At
        Widget A,10,19.99,2024-01-05,yes,2024-01-05 15:30:45
      CSV

      klass.new(file_path: csv.path).import!

      widget = ImporterBaseSpecWidget.find_by(name: 'Widget A')
      expect(widget.happened_at).to eq(Time.utc(2024, 1, 5, 15, 30, 45))
    end

    it 'raises a clear error for an invalid datetime value, rather than silently returning nil' do
      klass =
        importer_class do
          required_headers(
            {
              'Name' => :name,
              'Quantity' => :quantity,
              'Price' => :price,
              'Delivered On' => :delivered_on,
              'Active' => :active,
              'Happened At' => :happened_at
            }
          )
        end

      csv = write_csv(<<~CSV)
        Name,Quantity,Price,Delivered On,Active,Happened At
        Widget A,10,19.99,2024-01-05,yes,not_a_datetime
      CSV

      importer = klass.new(file_path: csv.path)

      expect { importer.import! }.to raise_error(described_class::ImportError, /invalid datetime/)
    end

    it 'raises a clear error identifying the offending row and column' do
      csv = write_csv(<<~CSV)
        Name,Quantity,Price,Delivered On,Active
        Widget A,10,19.99,2024-01-05,maybe
      CSV

      importer = importer_class.new(file_path: csv.path)

      expect { importer.import! }.to raise_error(
        described_class::ImportError, /Line 2, column 'active': invalid boolean/
      )
    end

    it 'reports the true physical line number, not just which record this is, once a quoted ' \
       'field earlier in the file spans multiple physical lines' do
      csv = write_csv(<<~CSV)
        Name,Quantity,Price,Delivered On,Active
        "Widget A
        continued",10,19.99,2024-01-05,yes
        Widget B,10,19.99,2024-01-05,maybe
      CSV

      importer = importer_class.new(file_path: csv.path)

      # Widget A's own row is one CSV record but spans physical lines 2-3; Widget B's
      # bad "Active" value is truly on physical line 4 - reported as "Line 3" before this
      # fix, since a plain per-record counter has no way to know the previous record
      # took up an extra physical line.
      expect { importer.import! }.to raise_error(
        described_class::ImportError, /Line 4, column 'active': invalid boolean/
      )
    end

    # Same scenario as above, but built with an explicit row separator rather than a
    # heredoc (which always uses a plain "\n" for its own line breaks, regardless of
    # what the file is meant to test) - so this actually exercises the row separator it
    # names, not just Ruby source formatting.
    def multiline_csv(row_sep)
      [
        'Name,Quantity,Price,Delivered On,Active',
        "\"Widget A#{row_sep}continued\",10,19.99,2024-01-05,yes",
        'Widget B,10,19.99,2024-01-05,maybe',
        ''
      ].join(row_sep)
    end

    it 'reports the true physical line number for a CRLF-separated file too' do
      csv = write_csv(multiline_csv("\r\n"))
      importer = importer_class.new(file_path: csv.path)

      expect { importer.import! }.to raise_error(
        described_class::ImportError, /Line 4, column 'active': invalid boolean/
      )
    end

    it 'reports the true physical line number for a bare-CR-separated file too - the pre-OS X ' \
       'classic Mac convention, long extinct in practice but still something CSV itself parses' do
      csv = write_csv(multiline_csv("\r"))
      importer = importer_class.new(file_path: csv.path)

      expect { importer.import! }.to raise_error(
        described_class::ImportError, /Line 4, column 'active': invalid boolean/
      )
    end

    it 'raises for a column of a type with no default caster at all, rather than silently ' \
       'passing the raw value through' do
      klass =
        importer_class do
          required_headers({ 'Name' => :name, 'Metadata' => :metadata })
        end

      csv = write_csv("Name,Metadata\nWidget A,{}\n")

      expect { klass.new(file_path: csv.path).import! }
        .to raise_error(described_class::ImportError, /no default cast for :jsonb - define cast_metadata/)
    end

    it 'casts :string and :text columns as a no-op, unaffected by the unsupported-type raise above' do
      klass =
        importer_class do
          required_headers({ 'Name' => :name, 'Code' => :code })
        end

      csv = write_csv("Name,Code\nWidget A,some-code\n")

      klass.new(file_path: csv.path).import!

      expect(ImporterBaseSpecWidget.find_by(name: 'Widget A').code).to eq('some-code')
    end

    it 'logs the row and column of a cast failure, even though the whole run still raises' do
      csv = write_csv(<<~CSV)
        Name,Quantity,Price,Delivered On,Active
        Widget A,10,19.99,2024-01-05,maybe
      CSV

      importer = importer_class.new(file_path: csv.path)

      expect { importer.import! }.to raise_error(described_class::ImportError)
      expect(importer.logs).to include(
        a_hash_including(level: 'error', row: 2, column: 'active')
      )
    end

    it 'logs the row number for a DB-level write failure and still rolls back everything' do
      csv = write_csv(<<~CSV)
        Name,Quantity,Price,Delivered On,Active
        Widget A,10,19.99,2024-01-05,yes
        Widget A,3,5.50,2024-02-01,no
      CSV

      importer = importer_class.new(file_path: csv.path)

      expect { importer.import! }.to raise_error(described_class::ImportError, /Row write failed for line\(s\) 3/)
      expect(importer.logs).to include(a_hash_including(level: 'error', row: 3))
      expect(ImporterBaseSpecWidget.count).to eq(0)
    end

    it 'supports a cast_ override for a column named after an internal parser method, without collision' do
      klass =
        importer_class do
          required_headers(
            {
              'Name' => :name,
              'Quantity' => :quantity,
              'Price' => :price,
              'Delivered On' => :delivered_on,
              'Active' => :active,
              'Date' => :date
            }
          )

          def cast_date(raw_value)
            Date.strptime(raw_value.strip, '%d/%m/%Y')
          end
        end

      csv = write_csv(<<~CSV)
        Name,Quantity,Price,Delivered On,Active,Date
        Widget A,10,19.99,2024-01-05,yes,25/12/2024
      CSV

      klass.new(file_path: csv.path).import!

      widget = ImporterBaseSpecWidget.find_by(name: 'Widget A')
      expect(widget.delivered_on).to eq(Date.new(2024, 1, 5))
      expect(widget[:date]).to eq(Date.new(2024, 12, 25))
    end

    it 'uses a cast_ override in place of the default cast for a column' do
      klass =
        importer_class do
          def cast_active(raw_value)
            raw_value.strip == 'Present'
          end
        end

      csv = write_csv(<<~CSV)
        Name,Quantity,Price,Delivered On,Active
        Widget A,10,19.99,2024-01-05,Present
        Widget B,3,5.50,2024-02-01,Absent
      CSV

      klass.new(file_path: csv.path).import!

      expect(ImporterBaseSpecWidget.find_by(name: 'Widget A').active).to be(true)
      expect(ImporterBaseSpecWidget.find_by(name: 'Widget B').active).to be(false)
    end

    it 'lets a cast_ override read another column raw value via raw_value_for' do
      klass =
        importer_class do
          def cast_delivered_on(_raw_value)
            month = raw_value_for(:name).delete_prefix('Widget ').rjust(2, '0')
            Date.parse("2024-#{month}-01")
          end
        end

      csv = write_csv(<<~CSV)
        Name,Quantity,Price,Delivered On,Active
        Widget 6,10,19.99,ignored,yes
      CSV

      klass.new(file_path: csv.path).import!

      expect(ImporterBaseSpecWidget.find_by(name: 'Widget 6').delivered_on).to eq(Date.new(2024, 6, 1))
    end

    it 'raises from raw_value_for when the attribute is not in required_headers' do
      klass =
        importer_class do
          def cast_active(_raw_value)
            raw_value_for(:not_a_mapped_attribute)
          end
        end

      csv = write_csv(<<~CSV)
        Name,Quantity,Price,Delivered On,Active
        Widget A,10,19.99,2024-01-05,yes
      CSV

      expect { klass.new(file_path: csv.path).import! }
        .to raise_error(described_class::ImportError, /not_a_mapped_attribute.*is not in required_headers/)
    end

    it 'lets a cast_ override read a column outside required_headers via raw_header_value' do
      klass =
        importer_class do
          def cast_active(_raw_value)
            raw_header_value('Status') == 'Enabled'
          end
        end

      csv = write_csv(<<~CSV)
        Name,Quantity,Price,Delivered On,Active,Status
        Widget A,10,19.99,2024-01-05,ignored,Enabled
        Widget B,3,5.50,2024-02-01,ignored,Disabled
      CSV

      klass.new(file_path: csv.path).import!

      expect(ImporterBaseSpecWidget.find_by(name: 'Widget A').active).to be(true)
      expect(ImporterBaseSpecWidget.find_by(name: 'Widget B').active).to be(false)
    end

    it 'returns nil from raw_header_value for a header that does not exist, rather than raising' do
      klass =
        importer_class do
          def cast_active(_raw_value)
            raw_header_value('Nope').nil?
          end
        end

      csv = write_csv(<<~CSV)
        Name,Quantity,Price,Delivered On,Active
        Widget A,10,19.99,2024-01-05,ignored
      CSV

      klass.new(file_path: csv.path).import!

      expect(ImporterBaseSpecWidget.find_by(name: 'Widget A').active).to be(true)
    end

    it 'strips leading/trailing whitespace from every raw value by default' do
      csv = write_csv(<<~CSV)
        Name,Quantity,Price,Delivered On,Active
        " Widget A ", 10 , 19.99 ,2024-01-05, yes
      CSV

      importer_class.new(file_path: csv.path).import!

      expect(ImporterBaseSpecWidget.find_by(name: 'Widget A')).to be_present
    end

    it 'allows a subclass to disable stripping with strip_raw_value false' do
      klass = importer_class { strip_raw_value false }

      csv = write_csv(<<~CSV)
        Name,Quantity,Price,Delivered On,Active
        " Widget A ",10,19.99,2024-01-05,yes
      CSV

      klass.new(file_path: csv.path).import!

      expect(ImporterBaseSpecWidget.find_by(name: ' Widget A ')).to be_present
    end

    it 'processes more than one batch when rows exceed batch_size' do
      klass = importer_class { batch_size 1 }

      csv = write_csv(<<~CSV)
        Name,Quantity,Price,Delivered On,Active
        Widget A,10,19.99,2024-01-05,yes
        Widget B,3,5.50,2024-02-01,no
        Widget C,7,1.23,2024-03-01,yes
      CSV

      klass.new(file_path: csv.path).import!

      expect(ImporterBaseSpecWidget.count).to eq(3)
    end
  end

  describe '#import! with raw_upsert_all mode' do
    it 'inserts new rows and updates existing rows on conflict, keyed on unique_by' do
      ImporterBaseSpecWidget.create!(name: 'Widget A', quantity: 1, code: 'existing-a')

      csv = write_csv(<<~CSV)
        Name,Quantity,Price,Delivered On,Active,Code
        Widget A,99,19.99,2024-01-05,yes,a1
        Widget B,3,5.50,2024-02-01,no,b1
      CSV

      upsert_importer_class.new(file_path: csv.path).import!

      expect(ImporterBaseSpecWidget.count).to eq(2)
      expect(ImporterBaseSpecWidget.find_by(name: 'Widget A').quantity).to eq(99)
      expect(ImporterBaseSpecWidget.find_by(name: 'Widget B').quantity).to eq(3)
    end

    it 'isolates and logs a DB-level failure unrelated to unique_by, and still rolls back everything' do
      csv = write_csv(<<~CSV)
        Name,Quantity,Price,Delivered On,Active,Code
        Widget A,10,19.99,2024-01-05,yes,dup-code
        Widget B,3,5.50,2024-02-01,no,dup-code
      CSV

      importer = upsert_importer_class.new(file_path: csv.path)

      expect { importer.import! }.to raise_error(described_class::ImportError, /Row write failed for line\(s\) 3/)
      expect(importer.logs).to include(a_hash_including(level: 'error', row: 3))
      expect(ImporterBaseSpecWidget.count).to eq(0)
    end

    it 'proactively catches two rows in the same batch sharing a unique_by value, logging both lines' do
      csv = write_csv(<<~CSV)
        Name,Quantity,Price,Delivered On,Active,Code
        Widget A,10,19.99,2024-01-05,yes,a1
        Widget A,3,5.50,2024-02-01,no,a2
      CSV

      importer = upsert_importer_class.new(file_path: csv.path)

      expect { importer.import! }
        .to raise_error(described_class::ImportError, /Duplicate unique_by value\(s\) within the same batch at line\(s\) 2, 3/)
      expect(importer.logs).to contain_exactly(
        a_hash_including(level: 'error', row: 2),
        a_hash_including(level: 'error', row: 3)
      )
      expect(ImporterBaseSpecWidget.count).to eq(0)
    end

    it 'does not raise when two rows in the same batch share a nil value for a nullable unique_by column' do
      klass =
        upsert_importer_class do
          unique_by :external_ref
          required_headers(
            {
              'Name' => :name,
              'Quantity' => :quantity,
              'Price' => :price,
              'Delivered On' => :delivered_on,
              'Active' => :active,
              'External Ref' => :external_ref
            }
          )
        end

      csv = write_csv(<<~CSV)
        Name,Quantity,Price,Delivered On,Active,External Ref
        Widget A,10,19.99,2024-01-05,yes,
        Widget B,3,5.50,2024-02-01,no,
      CSV

      importer = klass.new(file_path: csv.path)

      expect { importer.import! }.not_to raise_error
      expect(ImporterBaseSpecWidget.count).to eq(2)
    end

    it 'still raises for two rows in the same batch sharing the same non-nil unique_by value' do
      klass =
        upsert_importer_class do
          unique_by :external_ref
          required_headers(
            {
              'Name' => :name,
              'Quantity' => :quantity,
              'Price' => :price,
              'Delivered On' => :delivered_on,
              'Active' => :active,
              'External Ref' => :external_ref
            }
          )
        end

      csv = write_csv(<<~CSV)
        Name,Quantity,Price,Delivered On,Active,External Ref
        Widget A,10,19.99,2024-01-05,yes,dup-ref
        Widget B,3,5.50,2024-02-01,no,dup-ref
      CSV

      importer = klass.new(file_path: csv.path)

      expect { importer.import! }
        .to raise_error(described_class::ImportError, /Duplicate unique_by value\(s\) within the same batch at line\(s\) 2, 3/)
      expect(ImporterBaseSpecWidget.count).to eq(0)
    end

    describe ':activerecord mode and a nullable unique_by column' do
      # Regression: find_or_initialize_by(external_ref: nil) is a perfectly well-formed
      # query that happily returns whatever existing NULL row comes back first - unlike
      # raw_upsert_all's own conflict-target SQL, nothing here tells Postgres "these two
      # nils aren't a match" the way its own default (nulls-distinct) unique index
      # already agrees they aren't. Before the fix, the 2nd row below would silently
      # overwrite the 1st row's own record instead of inserting its own.
      it 'inserts each row as its own record when unique_by is nil, rather than collapsing them onto one existing NULL row' do
        klass =
          activerecord_importer_class do
            unique_by :external_ref
            required_headers(
              {
                'Name' => :name,
                'Quantity' => :quantity,
                'Price' => :price,
                'Delivered On' => :delivered_on,
                'Active' => :active,
                'External Ref' => :external_ref
              }
            )
          end

        csv = write_csv(<<~CSV)
          Name,Quantity,Price,Delivered On,Active,External Ref
          Widget A,10,19.99,2024-01-05,yes,
          Widget B,3,5.50,2024-02-01,no,
        CSV

        klass.new(file_path: csv.path).import!

        expect(ImporterBaseSpecWidget.count).to eq(2)
        expect(ImporterBaseSpecWidget.pluck(:name)).to contain_exactly('Widget A', 'Widget B')
      end

      it 'still finds and updates the correct existing record when unique_by has a real, non-nil value' do
        existing = ImporterBaseSpecWidget.create!(name: 'Old Name', external_ref: 'ref-1')

        klass =
          activerecord_importer_class do
            unique_by :external_ref
            required_headers(
              {
                'Name' => :name,
                'Quantity' => :quantity,
                'Price' => :price,
                'Delivered On' => :delivered_on,
                'Active' => :active,
                'External Ref' => :external_ref
              }
            )
          end

        csv = write_csv(<<~CSV)
          Name,Quantity,Price,Delivered On,Active,External Ref
          Widget A,10,19.99,2024-01-05,yes,ref-1
        CSV

        klass.new(file_path: csv.path).import!

        expect(ImporterBaseSpecWidget.count).to eq(1)
        expect(existing.reload.name).to eq('Widget A')
      end
    end

    # NULLS NOT DISTINCT gets its own isolated scratch table, not a column added to
    # ImporterBaseSpecWidget - it's a per-table index property, so any other test
    # sharing that table would implicitly get a nil value for it too (every raw mode
    # omits an unmapped column entirely, which Postgres then defaults to nil) - safe for
    # the default NULLS DISTINCT index above (any number of nils coexist there), but a
    # NULLS NOT DISTINCT index would make every one of those unrelated rows conflict
    # with every other one.
    describe 'with a NULLS NOT DISTINCT index' do
      before do
        ActiveRecord::Base.connection.create_table :importer_nnd_spec_widgets, force: true do |t|
          t.string :name
          t.string :col_a
          t.string :col_b
        end
        ActiveRecord::Base.connection.add_index(
          :importer_nnd_spec_widgets, :col_a, unique: true, nulls_not_distinct: true, name: 'idx_nnd_spec_single'
        )
        ActiveRecord::Base.connection.add_index(
          :importer_nnd_spec_widgets, %i[col_a col_b], unique: true, nulls_not_distinct: true, name: 'idx_nnd_spec_composite'
        )
        stub_const(
          'ImporterNndSpecWidget',
          Class.new(ApplicationRecord) { self.table_name = 'importer_nnd_spec_widgets' }
        )
      end

      after do
        ActiveRecord::Base.connection.drop_table :importer_nnd_spec_widgets, if_exists: true
      end

      def nnd_composite_importer_class(&block)
        Class.new(described_class) do
          target_model ImporterNndSpecWidget
          mode :raw_upsert_all
          unique_by %i[col_a col_b]
          required_headers({ 'Name' => :name, 'Col A' => :col_a, 'Col B' => :col_b })
          class_eval(&block) if block
        end
      end

      it 'raises for two rows in the same batch sharing a nil value, on a single-column unique_by' do
        klass =
          Class.new(described_class) do
            target_model ImporterNndSpecWidget
            mode :raw_upsert_all
            unique_by :col_a
            required_headers({ 'Name' => :name, 'Col A' => :col_a })
          end

        csv = write_csv(<<~CSV)
          Name,Col A
          Widget A,
          Widget B,
        CSV

        importer = klass.new(file_path: csv.path)

        expect { importer.import! }
          .to raise_error(described_class::ImportError, /Duplicate unique_by value\(s\) within the same batch at line\(s\) 2, 3/)
        expect(importer.logs).to include(a_hash_including(level: 'error', row: 2))
        expect(ImporterNndSpecWidget.count).to eq(0)
      end

      it 'raises when both columns of a composite unique_by match, including a shared nil, in the same batch' do
        csv = write_csv(<<~CSV)
          Name,Col A,Col B
          Widget A,x,
          Widget B,x,
        CSV

        importer = nnd_composite_importer_class.new(file_path: csv.path)

        expect { importer.import! }
          .to raise_error(described_class::ImportError, /Duplicate unique_by value\(s\) within the same batch at line\(s\) 2, 3/)
        expect(ImporterNndSpecWidget.count).to eq(0)
      end

      it 'does not raise when only one column matches and the other is nil for both rows' do
        csv = write_csv(<<~CSV)
          Name,Col A,Col B
          Widget A,x,
          Widget B,y,
        CSV

        importer = nnd_composite_importer_class.new(file_path: csv.path)

        expect { importer.import! }.not_to raise_error
        expect(ImporterNndSpecWidget.count).to eq(2)
      end

      it 'still finds and updates the single existing NULL row under :activerecord mode, since the database itself treats it as one' do
        klass =
          Class.new(described_class) do
            target_model ImporterNndSpecWidget
            mode :activerecord
            unique_by :col_a
            required_headers({ 'Name' => :name, 'Col A' => :col_a })
          end

        klass.new(file_path: write_csv("Name,Col A\nWidget A,\n").path).import!
        klass.new(file_path: write_csv("Name,Col A\nWidget B,\n").path).import!

        expect(ImporterNndSpecWidget.count).to eq(1)
        expect(ImporterNndSpecWidget.first.name).to eq('Widget B')
      end
    end

    it 'does not raise, and silently updates, when duplicate unique_by rows fall in different batches' do
      klass = upsert_importer_class { batch_size 1 }

      csv = write_csv(<<~CSV)
        Name,Quantity,Price,Delivered On,Active,Code
        Widget A,10,19.99,2024-01-05,yes,a1
        Widget A,99,5.50,2024-02-01,no,a2
      CSV

      importer = klass.new(file_path: csv.path)
      importer.import!

      expect(ImporterBaseSpecWidget.count).to eq(1)
      expect(ImporterBaseSpecWidget.find_by(name: 'Widget A').quantity).to eq(99)
      expect(importer.logs).not_to include(a_hash_including(level: 'error'))
    end
  end

  # A dedicated scratch table/model, not a column added to ImporterBaseSpecWidget -
  # a partial index's predicate is specific to the shape being tested here, and this
  # app's own real partial index (users.webauthn_id, `where: "webauthn_id IS NOT NULL"`)
  # would just retest nullability, which Importer::Loaders::PlainRecord's own separate nil
  # guard (see the ':activerecord mode and a nullable unique_by column' spec above)
  # already covers on its own - archived/active is a non-null-based predicate instead,
  # so these specs actually exercise the partial-index-scoping fix on its own, not the
  # nil guard's.
  describe '#import! and a partial unique index' do
    before do
      ActiveRecord::Base.connection.create_table :importer_partial_idx_spec_widgets, force: true do |t|
        t.string :name
        t.string :ext_ref
        t.boolean :archived, default: false, null: false
      end
      ActiveRecord::Base.connection.add_index(
        :importer_partial_idx_spec_widgets, :ext_ref, unique: true, where: 'archived = false'
      )
      stub_const(
        'ImporterPartialIdxSpecWidget',
        Class.new(ApplicationRecord) { self.table_name = 'importer_partial_idx_spec_widgets' }
      )
    end

    after do
      ActiveRecord::Base.connection.drop_table :importer_partial_idx_spec_widgets, if_exists: true
    end

    def partial_idx_importer_class(mode_name, &block)
      Class.new(described_class) do
        target_model ImporterPartialIdxSpecWidget
        mode mode_name
        unique_by :ext_ref
        required_headers({ 'Name' => :name, 'Ext Ref' => :ext_ref })
        class_eval(&block) if block
      end
    end

    describe ':activerecord mode' do
      it 'does not match or update an existing row that falls outside the partial index\'s own predicate' do
        ImporterPartialIdxSpecWidget.create!(name: 'Old', ext_ref: 'ref-1', archived: true)

        csv = write_csv("Name,Ext Ref\nNew,ref-1\n")
        partial_idx_importer_class(:activerecord).new(file_path: csv.path).import!

        expect(ImporterPartialIdxSpecWidget.count).to eq(2)
        expect(ImporterPartialIdxSpecWidget.find_by(archived: true).name).to eq('Old')
        expect(ImporterPartialIdxSpecWidget.find_by(archived: false).name).to eq('New')
      end

      it 'still finds and updates an existing row that does satisfy the predicate' do
        existing = ImporterPartialIdxSpecWidget.create!(name: 'Old', ext_ref: 'ref-1', archived: false)

        csv = write_csv("Name,Ext Ref\nNew,ref-1\n")
        partial_idx_importer_class(:activerecord).new(file_path: csv.path).import!

        expect(ImporterPartialIdxSpecWidget.count).to eq(1)
        expect(existing.reload.name).to eq('New')
      end
    end

    describe ':activerecord_import mode' do
      it 'builds an ON CONFLICT clause that actually matches the partial index, instead of raising' do
        existing = ImporterPartialIdxSpecWidget.create!(name: 'Old', ext_ref: 'ref-1', archived: false)

        csv = write_csv("Name,Ext Ref\nNew,ref-1\n")

        expect { partial_idx_importer_class(:activerecord_import).new(file_path: csv.path).import! }.not_to raise_error
        expect(ImporterPartialIdxSpecWidget.count).to eq(1)
        expect(existing.reload.name).to eq('New')
      end
    end
  end

  describe '#import! with activerecord mode' do
    it 'runs model validations, unlike the raw modes' do
      csv = write_csv(<<~CSV)
        Name,Quantity,Price,Delivered On,Active
        ,10,19.99,2024-01-05,yes
      CSV

      importer = activerecord_importer_class.new(file_path: csv.path)

      expect { importer.import! }.to raise_error(described_class::ImportError, /Line 2: Name can't be blank/)
      expect(importer.logs).to include(a_hash_including(level: 'error', row: 2, message: "Name can't be blank"))
      expect(ImporterBaseSpecWidget.count).to eq(0)
    end

    it 'runs model callbacks, unlike the raw modes' do
      csv = write_csv(<<~CSV)
        Name,Quantity,Price,Delivered On,Active
        Widget A,10,19.99,2024-01-05,yes
      CSV

      activerecord_importer_class.new(file_path: csv.path).import!

      # before_save bumps quantity by 1000 - only fires if a real model was saved.
      expect(ImporterBaseSpecWidget.find_by(name: 'Widget A').quantity).to eq(1010)
    end

    it 'writes to a virtual/writer-method attribute, unlike the raw modes' do
      klass =
        activerecord_importer_class do
          required_headers(
            {
              'Name' => :name,
              'Quantity' => :quantity,
              'Price' => :price,
              'Delivered On' => :delivered_on,
              'Active' => :active,
              'Virtual' => :custom_virtual
            }
          )
        end

      csv = write_csv(<<~CSV)
        Name,Quantity,Price,Delivered On,Active,Virtual
        Widget A,10,19.99,2024-01-05,yes,via-virtual-writer
      CSV

      klass.new(file_path: csv.path).import!

      expect(ImporterBaseSpecWidget.find_by(name: 'Widget A').code).to eq('via-virtual-writer')
    end

    it 'always inserts a new record when unique_by is not declared' do
      ImporterBaseSpecWidget.create!(name: 'Widget A', quantity: 1)

      csv = write_csv(<<~CSV)
        Name,Quantity,Price,Delivered On,Active
        Widget A,5,19.99,2024-01-05,yes
      CSV

      importer = activerecord_importer_class.new(file_path: csv.path)

      expect { importer.import! }.to raise_error(described_class::ImportError, /Line 2/)
      expect(importer.logs).to include(a_hash_including(level: 'error', row: 2))
      expect(ImporterBaseSpecWidget.count).to eq(1)
    end

    it 'updates the existing record instead of inserting a duplicate when unique_by is declared' do
      ImporterBaseSpecWidget.create!(name: 'Widget A', quantity: 1)

      csv = write_csv(<<~CSV)
        Name,Quantity,Price,Delivered On,Active
        Widget A,5,19.99,2024-01-05,yes
      CSV

      klass = activerecord_importer_class { unique_by :name }
      klass.new(file_path: csv.path).import!

      expect(ImporterBaseSpecWidget.count).to eq(1)
      expect(ImporterBaseSpecWidget.find_by(name: 'Widget A').quantity).to eq(1005)
    end

    it 'updates the existing record when unique_by names an index, not just a column' do
      ImporterBaseSpecWidget.create!(name: 'Widget A', quantity: 1)

      csv = write_csv(<<~CSV)
        Name,Quantity,Price,Delivered On,Active
        Widget A,5,19.99,2024-01-05,yes
      CSV

      klass = activerecord_importer_class { unique_by :index_importer_base_spec_widgets_on_name }
      klass.new(file_path: csv.path).import!

      expect(ImporterBaseSpecWidget.count).to eq(1)
      expect(ImporterBaseSpecWidget.find_by(name: 'Widget A').quantity).to eq(1005)
    end

    it 'logs and skips a failing row under on_failure :skip, keeping the good rows and not raising' do
      klass = activerecord_importer_class { on_failure :skip }

      csv = write_csv(<<~CSV)
        Name,Quantity,Price,Delivered On,Active
        Widget A,10,19.99,2024-01-05,yes
        ,3,5.50,2024-02-01,no
        Widget C,7,1.23,2024-03-01,yes
      CSV

      importer = klass.new(file_path: csv.path)

      expect { importer.import! }.not_to raise_error
      expect(ImporterBaseSpecWidget.count).to eq(2)
      expect(ImporterBaseSpecWidget.pluck(:name)).to contain_exactly('Widget A', 'Widget C')
      expect(importer.logs).to include(
        a_hash_including(level: 'error', row: 3, message: "Name can't be blank")
      )
    end

    it 'includes the skipped count in the summary log entry' do
      klass = activerecord_importer_class { on_failure :skip }

      csv = write_csv(<<~CSV)
        Name,Quantity,Price,Delivered On,Active
        Widget A,10,19.99,2024-01-05,yes
        ,3,5.50,2024-02-01,no
      CSV

      importer = klass.new(file_path: csv.path)
      importer.import!

      expect(importer.logs).to include(
        a_hash_including(level: 'info', processed: 2, written: 1, skipped: 1)
      )
    end

    it 'does not skip a bad cast under on_failure :skip - it still aborts and rolls back the whole run' do
      klass = activerecord_importer_class { on_failure :skip }

      csv = write_csv(<<~CSV)
        Name,Quantity,Price,Delivered On,Active
        Widget A,10,19.99,2024-01-05,yes
        Widget B,not_a_number,5.50,2024-02-01,no
        Widget C,7,1.23,2024-03-01,yes
      CSV

      importer = klass.new(file_path: csv.path)

      expect { importer.import! }.to raise_error(described_class::ImportError, /invalid integer/)
      expect(ImporterBaseSpecWidget.count).to eq(0)
    end

    it 'does not rescue an exception raised by the model\'s own callback under on_failure :skip - ' \
       'it aborts uncaught, with no #logs entry, rolling back the whole run' do
      buggy_widget_class =
        Class.new(ApplicationRecord) do
               self.table_name = 'importer_base_spec_widgets'
               before_create { raise 'boom from a buggy callback' if name == 'Widget B' }
        end
      stub_const('BuggyImporterBaseSpecWidget', buggy_widget_class)

      klass =
        Class.new(described_class) do
          target_model BuggyImporterBaseSpecWidget
          mode :activerecord
          on_failure :skip
          required_headers({ 'Name' => :name })
        end

      csv = write_csv(<<~CSV)
        Name
        Widget A
        Widget B
        Widget C
      CSV

      importer = klass.new(file_path: csv.path)

      expect { importer.import! }.to raise_error(RuntimeError, 'boom from a buggy callback')
      expect(importer.logs).to eq([])
      expect(BuggyImporterBaseSpecWidget.count).to eq(0)
    end
  end

  describe '#import! with activerecord_import mode' do
    it 'inserts new rows in one bulk statement' do
      csv = write_csv(<<~CSV)
        Name,Quantity,Price,Delivered On,Active
        Widget A,10,19.99,2024-01-05,yes
        Widget B,3,5.50,2024-02-01,no
      CSV

      activerecord_import_importer_class.new(file_path: csv.path).import!

      expect(ImporterBaseSpecWidget.count).to eq(2)
    end

    it 'runs model validations, unlike the raw modes' do
      csv = write_csv(<<~CSV)
        Name,Quantity,Price,Delivered On,Active
        ,10,19.99,2024-01-05,yes
      CSV

      importer = activerecord_import_importer_class.new(file_path: csv.path)

      expect { importer.import! }.to raise_error(described_class::ImportError, /Row validation failed for line\(s\) 2/)
      expect(importer.logs).to include(a_hash_including(level: 'error', row: 2, message: "Name can't be blank"))
      expect(ImporterBaseSpecWidget.count).to eq(0)
    end

    it 'does not run model callbacks, unlike :activerecord mode - inherent to a bulk INSERT' do
      csv = write_csv(<<~CSV)
        Name,Quantity,Price,Delivered On,Active
        Widget A,10,19.99,2024-01-05,yes
      CSV

      activerecord_import_importer_class.new(file_path: csv.path).import!

      # before_save bumps quantity by 1000 - it never fires here, unlike :activerecord mode.
      expect(ImporterBaseSpecWidget.find_by(name: 'Widget A').quantity).to eq(10)
    end

    it 'raises at config time for a virtual/writer-method attribute, unlike activerecord mode - ' \
       'support was removed entirely, see FINDINGS.md' do
      klass =
        activerecord_import_importer_class do
          required_headers(
            {
              'Name' => :name,
              'Quantity' => :quantity,
              'Price' => :price,
              'Delivered On' => :delivered_on,
              'Active' => :active,
              'Virtual' => :custom_virtual
            }
          )
        end

      csv = write_csv("Name,Quantity,Price,Delivered On,Active,Virtual\nWidget A,10,19.99,2024-01-05,yes,x\n")

      expect { klass.new(file_path: csv.path).import! }
        .to raise_error(ArgumentError, /'custom_virtual' is not writable.*activerecord_import mode writes real columns only/)
    end

    it 'raises at config time when unique_by is declared but required_headers maps nothing else, ' \
       'since a conflicting row could never be refreshed at all' do
      klass =
        activerecord_import_importer_class do
          unique_by :name
          required_headers({ 'Name' => :name })
        end

      csv = write_csv("Name\nWidget A\n")

      expect { klass.new(file_path: csv.path).import! }
        .to raise_error(ArgumentError, /needs at least one other written column to update on conflict/)
    end

    it 'does not raise that config-time error when the only non-unique_by attribute is derived, ' \
       'and refreshes that derived column on conflict' do
      klass =
        activerecord_import_importer_class do
          unique_by :name
          required_headers({ 'Name' => :name })
          derived_attributes :code

          def cast_code(_raw_value)
            "code-#{raw_value_for(:name)}"
          end
        end

      ImporterBaseSpecWidget.create!(name: 'Widget A', code: 'stale')

      csv = write_csv("Name\nWidget A\n")

      expect { klass.new(file_path: csv.path).import! }.not_to raise_error
      expect(ImporterBaseSpecWidget.where(name: 'Widget A').count).to eq(1)
      expect(ImporterBaseSpecWidget.find_by(name: 'Widget A').code).to eq('code-Widget A')
    end

    it 'raises at config time when unique_by is declared against a connection the installed ' \
       'activerecord-import gem cannot build an upsert for' do
      # activerecord-import's own MySQL adapter extension never actually gets mixed
      # into a real mysql2 connection under this app's installed Rails/gem versions
      # (verified directly against a real MySQL connection - see FINDINGS.md), so
      # connection.supports_on_duplicate_key_update? is what this class checks -
      # stubbed here (rather than needing a real non-Postgres connection in this spec
      # suite) to simulate exactly that unsupported-adapter case portably.
      klass = activerecord_import_importer_class { unique_by :name }

      allow(ImporterBaseSpecWidget.connection).to receive(:supports_on_duplicate_key_update?).and_return(false)

      csv = write_csv("Name,Quantity\nWidget A,1\n")

      expect { klass.new(file_path: csv.path).import! }
        .to raise_error(ArgumentError, /needs the connected database to support an upsert the installed activerecord-import gem can build/)
    end

    it 'always inserts a new record when unique_by is not declared' do
      ImporterBaseSpecWidget.create!(name: 'Widget A', quantity: 1)

      csv = write_csv(<<~CSV)
        Name,Quantity,Price,Delivered On,Active
        Widget A,5,19.99,2024-01-05,yes
      CSV

      importer = activerecord_import_importer_class.new(file_path: csv.path)

      expect { importer.import! }.to raise_error(described_class::ImportError, /Batch write failed/)
      expect(ImporterBaseSpecWidget.count).to eq(1)
    end

    it 'updates the existing record instead of inserting a duplicate when unique_by is declared' do
      ImporterBaseSpecWidget.create!(name: 'Widget A', quantity: 1)

      csv = write_csv(<<~CSV)
        Name,Quantity,Price,Delivered On,Active
        Widget A,5,19.99,2024-01-05,yes
      CSV

      klass = activerecord_import_importer_class { unique_by :name }
      klass.new(file_path: csv.path).import!

      expect(ImporterBaseSpecWidget.count).to eq(1)
      expect(ImporterBaseSpecWidget.find_by(name: 'Widget A').quantity).to eq(5)
    end

    it 'updates the existing record when unique_by names an index, not just a column' do
      ImporterBaseSpecWidget.create!(name: 'Widget A', quantity: 1)

      csv = write_csv(<<~CSV)
        Name,Quantity,Price,Delivered On,Active
        Widget A,5,19.99,2024-01-05,yes
      CSV

      klass = activerecord_import_importer_class { unique_by :index_importer_base_spec_widgets_on_name }
      klass.new(file_path: csv.path).import!

      expect(ImporterBaseSpecWidget.count).to eq(1)
      expect(ImporterBaseSpecWidget.find_by(name: 'Widget A').quantity).to eq(5)
    end

    it 'builds a plain column Array for on_duplicate_key_update on an adapter without conflict_target ' \
       'support, instead of the {conflict_target:, columns:} shape PostgreSQL/SQLite need' do
      # activerecord_import_upsert_option branches on connection.supports_insert_
      # conflict_target? - this spec suite's own connection is PostgreSQL (always
      # true), so the {conflict_target:, columns:} branch every other test in this
      # describe block exercises is covered already, but the other branch (MySQL/
      # MariaDB, in practice - see FINDINGS.md) never naturally occurs here, so it's
      # stubbed directly. Checked via the private method's own return value, not a
      # full import! - the gem's actual SQL generation for *this* real connection
      # still expects PostgreSQL's own shape regardless of what this class decides to
      # build, so actually writing with the MySQL-shaped option here would exercise a
      # mismatch this test isn't about; assert_configured! is still called directly
      # first, to build the loader (which resolves unique_by) and pass the new
      # upsert-support guard (stubbed true here - a separate, already-covered concern).
      klass = activerecord_import_importer_class { unique_by :name }
      csv = write_csv("Name,Quantity,Price,Delivered On,Active\nWidget A,5,19.99,2024-01-05,yes\n")
      importer = klass.new(file_path: csv.path)

      allow(ImporterBaseSpecWidget.connection).to receive_messages(
        supports_insert_conflict_target?: false,
        supports_on_duplicate_key_update?: true
      )

      importer.send(:assert_configured!)

      expect(importer.send(:loader).send(:activerecord_import_upsert_option))
        .to eq(on_duplicate_key_update: [ :quantity, :price, :delivered_on, :active ])
    end

    it 'logs and skips a failing row under on_failure :skip, keeping the good rows and not raising' do
      klass = activerecord_import_importer_class { on_failure :skip }

      csv = write_csv(<<~CSV)
        Name,Quantity,Price,Delivered On,Active
        Widget A,10,19.99,2024-01-05,yes
        ,3,5.50,2024-02-01,no
        Widget C,7,1.23,2024-03-01,yes
      CSV

      importer = klass.new(file_path: csv.path)

      expect { importer.import! }.not_to raise_error
      expect(ImporterBaseSpecWidget.count).to eq(2)
      expect(ImporterBaseSpecWidget.pluck(:name)).to contain_exactly('Widget A', 'Widget C')
      expect(importer.logs).to include(
        a_hash_including(level: 'error', row: 3, message: "Name can't be blank")
      )
    end

    it 'includes the skipped count in the summary log entry' do
      klass = activerecord_import_importer_class { on_failure :skip }

      csv = write_csv(<<~CSV)
        Name,Quantity,Price,Delivered On,Active
        Widget A,10,19.99,2024-01-05,yes
        ,3,5.50,2024-02-01,no
      CSV

      importer = klass.new(file_path: csv.path)
      importer.import!

      expect(importer.logs).to include(
        a_hash_including(level: 'info', processed: 2, written: 1, skipped: 1)
      )
    end

    it 'aborts and rolls back the whole run for a DB-level failure not caught by validation, ' \
       'regardless of on_failure :skip' do
      klass =
        activerecord_import_importer_class do
          on_failure :skip
          required_headers(
            {
              'Name' => :name,
              'Quantity' => :quantity,
              'Price' => :price,
              'Delivered On' => :delivered_on,
              'Active' => :active,
              'Code' => :code
            }
          )
        end

      csv = write_csv(<<~CSV)
        Name,Quantity,Price,Delivered On,Active,Code
        Widget A,10,19.99,2024-01-05,yes,dup-code
        Widget B,3,5.50,2024-02-01,no,dup-code
      CSV

      importer = klass.new(file_path: csv.path)

      expect { importer.import! }.to raise_error(described_class::ImportError, /Batch write failed for line\(s\) 2-3/)
      expect(ImporterBaseSpecWidget.count).to eq(0)
    end

    it 'proactively catches two rows in the same batch sharing a unique_by value, logging both lines' do
      klass = activerecord_import_importer_class { unique_by :name }

      csv = write_csv(<<~CSV)
        Name,Quantity,Price,Delivered On,Active
        Widget A,10,19.99,2024-01-05,yes
        Widget A,3,5.50,2024-02-01,no
      CSV

      importer = klass.new(file_path: csv.path)

      expect { importer.import! }
        .to raise_error(described_class::ImportError, /Duplicate unique_by value\(s\) within the same batch at line\(s\) 2, 3/)
      expect(importer.logs).to contain_exactly(
        a_hash_including(level: 'error', row: 2),
        a_hash_including(level: 'error', row: 3)
      )
      expect(ImporterBaseSpecWidget.count).to eq(0)
    end

    it 'does not run the same-batch duplicate check when unique_by is not declared' do
      csv = write_csv(<<~CSV)
        Name,Quantity,Price,Delivered On,Active
        Widget A,10,19.99,2024-01-05,yes
        Widget A,3,5.50,2024-02-01,no
      CSV

      importer = activerecord_import_importer_class.new(file_path: csv.path)

      expect { importer.import! }.to raise_error(described_class::ImportError, /Batch write failed/)
      expect(ImporterBaseSpecWidget.count).to eq(0)
    end
  end

  describe 'primary key handling' do
    it 'raises at config time when the primary key is mapped without allow_primary_key_write, ' \
       'for a mode with no lookup step' do
      klass =
        importer_class do
          required_headers({ 'Name' => :name, 'Id' => :id })
        end

      csv = write_csv("Name,Id\nWidget A,1\n")

      expect { klass.new(file_path: csv.path).import! }
        .to raise_error(ArgumentError, /'id' is the primary key.*allow_primary_key_write true/)
    end

    it 'raises at config time when the primary key is mapped and unique_by resolves to something else' do
      klass =
        upsert_importer_class do
          required_headers(
            {
              'Name' => :name,
              'Quantity' => :quantity,
              'Price' => :price,
              'Delivered On' => :delivered_on,
              'Active' => :active,
              'Code' => :code,
              'Id' => :id
            }
          )
        end

      csv = write_csv("Name,Quantity,Price,Delivered On,Active,Code,Id\nWidget A,1,1.00,2024-01-01,yes,c1,5\n")

      expect { klass.new(file_path: csv.path).import! }
        .to raise_error(ArgumentError, /'id' is the primary key/)
    end

    it 'raises at config time when the primary key is mapped and unique_by is not declared at all' do
      klass =
        activerecord_importer_class do
          required_headers({ 'Name' => :name, 'Id' => :id })
        end

      csv = write_csv("Name,Id\nWidget A,1\n")

      expect { klass.new(file_path: csv.path).import! }
        .to raise_error(ArgumentError, /'id' is the primary key/)
    end

    it 'does not raise at config time when unique_by resolves to the primary key itself' do
      klass =
        upsert_importer_class do
          unique_by :id
          required_headers({ 'Id' => :id, 'Name' => :name })
        end

      csv = write_csv("Id,Name\n,Widget A\n")

      expect { klass.new(file_path: csv.path).import! }.not_to raise_error
    end

    it 'raises even when unique_by is declared as the primary key, for a mode with no lookup step at all' do
      klass =
        importer_class do
          unique_by :id
          required_headers({ 'Name' => :name, 'Id' => :id })
        end

      csv = write_csv("Name,Id\nWidget A,1\n")

      expect { klass.new(file_path: csv.path).import! }
        .to raise_error(ArgumentError, /'id' is the primary key.*not raw_insert_all's case here/)
    end

    describe 'with raw_insert_all mode (no lookup step, allow_primary_key_write true)' do
      def pk_write_importer_class(&block)
        importer_class do
          allow_primary_key_write true
          required_headers({ 'Name' => :name, 'Id' => :id })
          class_eval(&block) if block
        end
      end

      it 'lets the database assign the id when the source value is blank' do
        csv = write_csv("Name,Id\nWidget A,\n")

        pk_write_importer_class.new(file_path: csv.path).import!

        expect(ImporterBaseSpecWidget.find_by(name: 'Widget A').id).to be_present
      end

      it 'inserts with the given id when provided' do
        csv = write_csv("Name,Id\nWidget A,999991\n")

        pk_write_importer_class.new(file_path: csv.path).import!

        expect(ImporterBaseSpecWidget.find_by(name: 'Widget A').id).to eq(999991)
      end

      it 'writes a batch mixing blank and provided ids without raising due to heterogeneous keys' do
        csv = write_csv(<<~CSV)
          Name,Id
          Widget A,999992
          Widget B,
        CSV

        pk_write_importer_class.new(file_path: csv.path).import!

        expect(ImporterBaseSpecWidget.pluck(:name)).to contain_exactly('Widget A', 'Widget B')
        expect(ImporterBaseSpecWidget.find_by(name: 'Widget A').id).to eq(999992)
        expect(ImporterBaseSpecWidget.find_by(name: 'Widget B').id).to be_present
      end

      it 'raises on collision when the given id already exists - no lookup, no update path' do
        existing = ImporterBaseSpecWidget.create!(name: 'Existing Widget')

        csv = write_csv("Name,Id\nWidget A,#{existing.id}\n")

        importer = pk_write_importer_class.new(file_path: csv.path)

        expect { importer.import! }.to raise_error(described_class::ImportError, /Row write failed for line\(s\) 2/)
        expect(existing.reload.name).to eq('Existing Widget')
      end

      it 'still isolates and logs the correct line number for a DB-level failure inside one ' \
         'primary-key-shaped partition, and rolls back the other partition too' do
        ImporterBaseSpecWidget.create!(name: 'Someone Else', code: 'taken-code')

        klass =
          pk_write_importer_class do
            required_headers({ 'Name' => :name, 'Id' => :id, 'Code' => :code })
          end
        csv = write_csv(<<~CSV)
          Name,Id,Code
          Widget X,999989,new-code
          Widget A,,taken-code
        CSV

        importer = klass.new(file_path: csv.path)

        expect { importer.import! }.to raise_error(described_class::ImportError, /Row write failed for line\(s\) 3/)
        expect(importer.logs).to include(a_hash_including(level: 'error', row: 3))
        expect(ImporterBaseSpecWidget.find_by(id: 999989)).to be_nil
      end
    end

    describe 'with raw_upsert_all mode, unique_by the primary key' do
      def pk_upsert_importer_class(&block)
        Class.new(described_class) do
          target_model ImporterBaseSpecWidget
          mode :raw_upsert_all
          unique_by :id
          required_headers({ 'Id' => :id, 'Name' => :name })
          class_eval(&block) if block
        end
      end

      it 'inserts a fresh record when the id is blank' do
        csv = write_csv("Id,Name\n,Widget A\n")

        pk_upsert_importer_class.new(file_path: csv.path).import!

        expect(ImporterBaseSpecWidget.find_by(name: 'Widget A')).to be_present
      end

      it 'updates the existing record when the given id matches' do
        widget = ImporterBaseSpecWidget.create!(name: 'Original')

        csv = write_csv("Id,Name\n#{widget.id},Updated\n")

        pk_upsert_importer_class.new(file_path: csv.path).import!

        expect(widget.reload.name).to eq('Updated')
        expect(ImporterBaseSpecWidget.count).to eq(1)
      end

      it 'raises when the given id matches no existing record, and allow_primary_key_write is false' do
        csv = write_csv("Id,Name\n999993,Widget A\n")

        importer = pk_upsert_importer_class.new(file_path: csv.path)

        expect { importer.import! }
          .to raise_error(described_class::ImportError, /Primary key not found for line\(s\) 2/)
        expect(importer.logs).to include(a_hash_including(level: 'error', row: 2))
        expect(ImporterBaseSpecWidget.count).to eq(0)
      end

      it 'inserts with the given id when it matches no existing record, and allow_primary_key_write is true' do
        klass = pk_upsert_importer_class { allow_primary_key_write true }

        csv = write_csv("Id,Name\n999994,Widget A\n")

        klass.new(file_path: csv.path).import!

        expect(ImporterBaseSpecWidget.find_by(id: 999994).name).to eq('Widget A')
      end

      it 'writes a batch mixing a matching id and a blank id without raising due to heterogeneous keys' do
        widget = ImporterBaseSpecWidget.create!(name: 'Original')

        csv = write_csv(<<~CSV)
          Id,Name
          #{widget.id},Updated
          ,Fresh Widget
        CSV

        pk_upsert_importer_class.new(file_path: csv.path).import!

        expect(widget.reload.name).to eq('Updated')
        expect(ImporterBaseSpecWidget.find_by(name: 'Fresh Widget')).to be_present
        expect(ImporterBaseSpecWidget.count).to eq(2)
      end

      it 'does not flag multiple blank-id rows in the same batch as duplicates of each other' do
        csv = write_csv(<<~CSV)
          Id,Name
          ,Widget A
          ,Widget B
          ,Widget C
        CSV

        importer = pk_upsert_importer_class.new(file_path: csv.path)

        expect { importer.import! }.not_to raise_error
        expect(ImporterBaseSpecWidget.pluck(:name)).to contain_exactly('Widget A', 'Widget B', 'Widget C')
      end

      it 'reports both rows as primary-key-not-found, not as duplicates, when two rows share the same ' \
         'non-existent id' do
        csv = write_csv(<<~CSV)
          Id,Name
          999989,Widget A
          999989,Widget B
        CSV

        importer = pk_upsert_importer_class.new(file_path: csv.path)

        expect { importer.import! }
          .to raise_error(described_class::ImportError, /Primary key not found for line\(s\) 2, 3/)
        expect(ImporterBaseSpecWidget.count).to eq(0)
      end

      it 'still isolates and logs the correct line number for a DB-level failure unrelated to the primary key' do
        ImporterBaseSpecWidget.create!(name: 'Someone Else', code: 'taken-code')

        klass = pk_upsert_importer_class { required_headers({ 'Id' => :id, 'Name' => :name, 'Code' => :code }) }

        csv = write_csv(<<~CSV)
          Id,Name,Code
          ,Widget A,taken-code
        CSV

        importer = klass.new(file_path: csv.path)

        expect { importer.import! }.to raise_error(described_class::ImportError, /Row write failed for line\(s\) 2/)
        expect(importer.logs).to include(a_hash_including(level: 'error', row: 2))
        expect(ImporterBaseSpecWidget.count).to eq(1)
      end
    end

    describe 'with activerecord mode, unique_by the primary key' do
      def pk_activerecord_importer_class(&block)
        Class.new(described_class) do
          target_model ImporterBaseSpecWidget
          mode :activerecord
          unique_by :id
          required_headers({ 'Id' => :id, 'Name' => :name })
          class_eval(&block) if block
        end
      end

      it 'inserts a fresh record when the id is blank, without matching an arbitrary existing row' do
        ImporterBaseSpecWidget.create!(name: 'Someone Else')

        csv = write_csv("Id,Name\n,Widget A\n")

        pk_activerecord_importer_class.new(file_path: csv.path).import!

        expect(ImporterBaseSpecWidget.count).to eq(2)
        expect(ImporterBaseSpecWidget.find_by(name: 'Widget A')).to be_present
        expect(ImporterBaseSpecWidget.find_by(name: 'Someone Else').name).to eq('Someone Else')
      end

      it 'updates the existing record when the given id matches' do
        widget = ImporterBaseSpecWidget.create!(name: 'Original')

        csv = write_csv("Id,Name\n#{widget.id},Updated\n")

        pk_activerecord_importer_class.new(file_path: csv.path).import!

        expect(widget.reload.name).to eq('Updated')
        expect(ImporterBaseSpecWidget.count).to eq(1)
      end

      it 'raises when the given id matches no existing record, and allow_primary_key_write is false' do
        csv = write_csv("Id,Name\n999995,Widget A\n")

        importer = pk_activerecord_importer_class.new(file_path: csv.path)

        expect { importer.import! }
          .to raise_error(described_class::ImportError, /Line 2.*no existing.*999995.*allow_primary_key_write is false/)
        expect(ImporterBaseSpecWidget.count).to eq(0)
      end

      it 'skips instead of raising under on_failure :skip, keeping the good row' do
        klass = pk_activerecord_importer_class { on_failure :skip }

        csv = write_csv(<<~CSV)
          Id,Name
          999996,Widget A
          ,Widget B
        CSV

        importer = klass.new(file_path: csv.path)

        expect { importer.import! }.not_to raise_error
        expect(ImporterBaseSpecWidget.pluck(:name)).to eq([ 'Widget B' ])
        expect(importer.logs).to include(a_hash_including(level: 'info', skipped: 1))
      end

      it 'inserts with the given id when it matches no existing record, and allow_primary_key_write is true' do
        klass = pk_activerecord_importer_class { allow_primary_key_write true }

        csv = write_csv("Id,Name\n999997,Widget A\n")

        klass.new(file_path: csv.path).import!

        expect(ImporterBaseSpecWidget.find_by(id: 999997).name).to eq('Widget A')
      end
    end

    describe 'with activerecord_import mode, unique_by the primary key' do
      def pk_activerecord_import_importer_class(&block)
        Class.new(described_class) do
          target_model ImporterBaseSpecWidget
          mode :activerecord_import
          unique_by :id
          required_headers({ 'Id' => :id, 'Name' => :name })
          class_eval(&block) if block
        end
      end

      it 'inserts a fresh record when the id is blank' do
        csv = write_csv("Id,Name\n,Widget A\n")

        pk_activerecord_import_importer_class.new(file_path: csv.path).import!

        expect(ImporterBaseSpecWidget.find_by(name: 'Widget A')).to be_present
      end

      it 'updates the existing record when the given id matches' do
        widget = ImporterBaseSpecWidget.create!(name: 'Original')

        csv = write_csv("Id,Name\n#{widget.id},Updated\n")

        pk_activerecord_import_importer_class.new(file_path: csv.path).import!

        expect(widget.reload.name).to eq('Updated')
        expect(ImporterBaseSpecWidget.count).to eq(1)
      end

      it 'raises when the given id matches no existing record, and allow_primary_key_write is false' do
        csv = write_csv("Id,Name\n999998,Widget A\n")

        importer = pk_activerecord_import_importer_class.new(file_path: csv.path)

        expect { importer.import! }
          .to raise_error(described_class::ImportError, /Primary key not found for line\(s\) 2/)
        expect(ImporterBaseSpecWidget.count).to eq(0)
      end

      it 'skips instead of raising under on_failure :skip, keeping the good row' do
        klass = pk_activerecord_import_importer_class { on_failure :skip }

        csv = write_csv(<<~CSV)
          Id,Name
          888881,Widget A
          ,Widget B
        CSV

        importer = klass.new(file_path: csv.path)

        expect { importer.import! }.not_to raise_error
        expect(ImporterBaseSpecWidget.pluck(:name)).to eq([ 'Widget B' ])
      end

      it 'inserts with the given id when it matches no existing record, and allow_primary_key_write is true' do
        klass = pk_activerecord_import_importer_class { allow_primary_key_write true }

        csv = write_csv("Id,Name\n888882,Widget A\n")

        klass.new(file_path: csv.path).import!

        expect(ImporterBaseSpecWidget.find_by(id: 888882).name).to eq('Widget A')
      end

      it 'writes a batch mixing a matching id and a blank id in one bulk import call' do
        widget = ImporterBaseSpecWidget.create!(name: 'Original')

        csv = write_csv(<<~CSV)
          Id,Name
          #{widget.id},Updated
          ,Fresh Widget
        CSV

        pk_activerecord_import_importer_class.new(file_path: csv.path).import!

        expect(widget.reload.name).to eq('Updated')
        expect(ImporterBaseSpecWidget.find_by(name: 'Fresh Widget')).to be_present
        expect(ImporterBaseSpecWidget.count).to eq(2)
      end

      it 'does not flag multiple blank-id rows in the same batch as duplicates of each other' do
        csv = write_csv(<<~CSV)
          Id,Name
          ,Widget A
          ,Widget B
          ,Widget C
        CSV

        importer = pk_activerecord_import_importer_class.new(file_path: csv.path)

        expect { importer.import! }.not_to raise_error
        expect(ImporterBaseSpecWidget.pluck(:name)).to contain_exactly('Widget A', 'Widget B', 'Widget C')
      end
    end
  end
end
