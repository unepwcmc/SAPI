require 'spec_helper'
require 'tempfile'

# resolve_belongs_to (Importer::Concerns::Config) needs a real belongs_to association to
# reflect on, which no migrated model in this app pairs with the column types the importer
# specs already exercise - so this spec builds its own two-table scratch schema, the same
# approach base_spec.rb takes for the cast pipeline.
RSpec.describe Importer::Base do
  # rubocop:disable RSpec/BeforeAfterAll -- table DDL, not row data; nothing here needs a per-example rollback
  before(:context) do
    connection = ActiveRecord::Base.connection

    connection.create_table :importer_bt_spec_makers, force: true do |t|
      t.string :slug
      t.integer :legacy_uid
    end
    connection.add_index :importer_bt_spec_makers, :slug, unique: true

    connection.create_table :importer_bt_spec_widgets, force: true do |t|
      t.string :name
      t.bigint :maker_id
      t.bigint :parent_widget_id
    end
    connection.add_index :importer_bt_spec_widgets, :name, unique: true
  end

  after(:context) do
    connection = ActiveRecord::Base.connection
    connection.drop_table :importer_bt_spec_widgets, if_exists: true
    connection.drop_table :importer_bt_spec_makers, if_exists: true
  end
  # rubocop:enable RSpec/BeforeAfterAll

  let(:maker_class) do
    Class.new(ApplicationRecord) do
      self.table_name = 'importer_bt_spec_makers'
    end
  end

  let(:widget_class) do
    Class.new(ApplicationRecord) do
      self.table_name = 'importer_bt_spec_widgets'

      belongs_to :maker, class_name: 'ImporterBtSpecMaker', optional: true
      # Deliberately named differently from its own foreign key, to prove the reflection is
      # found by foreign key rather than by stripping `_id` off the attribute name.
      belongs_to :parent_widget, class_name: 'ImporterBtSpecWidget', optional: true
    end
  end

  before do
    stub_const('ImporterBtSpecMaker', maker_class)
    stub_const('ImporterBtSpecWidget', widget_class)
  end

  def write_csv(content)
    file = Tempfile.new([ 'import', '.csv' ])
    file.binmode
    file.write(content)
    file.close
    file
  end

  def importer_class(mode_name = :activerecord, &block)
    Class.new(described_class) do
      target_model ImporterBtSpecWidget
      mode mode_name
      required_headers({ 'Name' => :name, 'Maker' => :maker_id })
      resolve_belongs_to :maker_id, by: :slug

      class_eval(&block) if block
    end
  end

  describe 'resolve_belongs_to' do
    it 'resolves a natural key in the source file to the associated record id' do
      maker = ImporterBtSpecMaker.create!(slug: 'acme')

      csv = write_csv("Name,Maker\nWidget A,acme\n")
      importer_class.new(file_path: csv.path).import!

      expect(ImporterBtSpecWidget.find_by(name: 'Widget A').maker_id).to eq(maker.id)
    end

    it 'raises for a present value that matches no record, naming the model, key and value' do
      csv = write_csv("Name,Maker\nWidget A,nope\n")
      importer = importer_class.new(file_path: csv.path)

      expect { importer.import! }.to raise_error(
        described_class::ImportError,
        /Line 2, column 'maker_id': no ImporterBtSpecMaker found with slug: "nope"/
      )
      expect(ImporterBtSpecWidget.count).to eq(0)
      expect(importer.logs).to include(hash_including(level: 'error', row: 2, column: 'maker_id'))
    end

    it 'resolves a blank value to nil rather than raising, leaving the association unset' do
      csv = write_csv("Name,Maker\nWidget A,\n")
      importer_class.new(file_path: csv.path).import!

      expect(ImporterBtSpecWidget.find_by(name: 'Widget A').maker_id).to be_nil
    end

    it 'queries once per distinct value for the whole run, not once per row' do
      ImporterBtSpecMaker.create!(slug: 'acme')
      ImporterBtSpecMaker.create!(slug: 'globex')

      csv = write_csv(<<~CSV)
        Name,Maker
        Widget A,acme
        Widget B,acme
        Widget C,globex
        Widget D,acme
      CSV

      queries = 0
      subscriber =
        ActiveSupport::Notifications.subscribe('sql.active_record') do |_n, _s, _f, _i, payload|
          queries += 1 if payload[:sql].include?('importer_bt_spec_makers')
        end

      begin
        importer_class.new(file_path: csv.path).import!
      ensure
        ActiveSupport::Notifications.unsubscribe(subscriber)
      end

      expect(queries).to eq(2) # acme, globex - not four rows' worth
      expect(ImporterBtSpecWidget.where.not(maker_id: nil).count).to eq(4)
    end

    it 'matches a native Excel-style Integer against a text key column, and an integer one' do
      ImporterBtSpecMaker.create!(slug: '44', legacy_uid: 44)

      text_keyed = importer_class { resolve_belongs_to :maker_id, by: :slug }
      csv = write_csv("Name,Maker\nWidget A,44\n")
      text_keyed.new(file_path: csv.path).import!

      integer_keyed = importer_class { resolve_belongs_to :maker_id, by: :legacy_uid }
      csv = write_csv("Name,Maker\nWidget B,44\n")
      integer_keyed.new(file_path: csv.path).import!

      maker_id = ImporterBtSpecMaker.first.id
      expect(ImporterBtSpecWidget.find_by(name: 'Widget A').maker_id).to eq(maker_id)
      expect(ImporterBtSpecWidget.find_by(name: 'Widget B').maker_id).to eq(maker_id)
    end

    it 'finds the association by foreign key, not by stripping _id from the attribute name' do
      parent = ImporterBtSpecWidget.create!(name: 'Parent')

      klass =
        Class.new(described_class) do
          target_model ImporterBtSpecWidget
          mode :activerecord
          required_headers({ 'Name' => :name, 'Parent' => :parent_widget_id })
          resolve_belongs_to :parent_widget_id, by: :name
        end

      csv = write_csv("Name,Parent\nChild,Parent\n")
      klass.new(file_path: csv.path).import!

      expect(ImporterBtSpecWidget.find_by(name: 'Child').parent_widget_id).to eq(parent.id)
    end

    # A resolved foreign key is an ordinary column value by the time write_batch sees it, so
    # this is mode-agnostic by construction - nothing here needs a model instance, and the
    # belongs_to reflection it reads is class-level. Covered for every mode rather than
    # argued for, since the raw_* modes never instantiate a model at all and
    # activerecord_import instantiates one without running the full save path.
    it 'resolves under raw_insert_all, which never instantiates a model' do
      maker = ImporterBtSpecMaker.create!(slug: 'acme')

      csv = write_csv("Name,Maker\nWidget A,acme\n")
      importer_class(:raw_insert_all).new(file_path: csv.path).import!

      expect(ImporterBtSpecWidget.find_by(name: 'Widget A').maker_id).to eq(maker.id)
    end

    it 'resolves under raw_upsert_all, on both the insert and the update path' do
      acme = ImporterBtSpecMaker.create!(slug: 'acme')
      globex = ImporterBtSpecMaker.create!(slug: 'globex')
      ImporterBtSpecWidget.create!(name: 'Widget A', maker_id: acme.id)

      klass = importer_class(:raw_upsert_all) { unique_by :name }

      csv = write_csv(<<~CSV)
        Name,Maker
        Widget A,globex
        Widget B,acme
      CSV
      klass.new(file_path: csv.path).import!

      expect(ImporterBtSpecWidget.count).to eq(2)
      expect(ImporterBtSpecWidget.find_by(name: 'Widget A').maker_id).to eq(globex.id) # updated
      expect(ImporterBtSpecWidget.find_by(name: 'Widget B').maker_id).to eq(acme.id)   # inserted
    end

    it 'resolves under activerecord_import, including as a column refreshed on conflict' do
      acme = ImporterBtSpecMaker.create!(slug: 'acme')
      globex = ImporterBtSpecMaker.create!(slug: 'globex')
      ImporterBtSpecWidget.create!(name: 'Widget A', maker_id: acme.id)

      klass = importer_class(:activerecord_import) { unique_by :name }

      csv = write_csv(<<~CSV)
        Name,Maker
        Widget A,globex
        Widget B,acme
      CSV
      klass.new(file_path: csv.path).import!

      expect(ImporterBtSpecWidget.count).to eq(2)
      expect(ImporterBtSpecWidget.find_by(name: 'Widget A').maker_id).to eq(globex.id)
      expect(ImporterBtSpecWidget.find_by(name: 'Widget B').maker_id).to eq(acme.id)
    end

    it 'raises for an unmatched value under a raw_* mode too, before anything is written' do
      ImporterBtSpecMaker.create!(slug: 'acme') # row 2 resolves fine; row 3 is the bad one

      csv = write_csv("Name,Maker\nWidget A,acme\nWidget B,nope\n")

      expect { importer_class(:raw_insert_all).new(file_path: csv.path).import! }
        .to raise_error(described_class::ImportError, /no ImporterBtSpecMaker found with slug: "nope"/)
      expect(ImporterBtSpecWidget.count).to eq(0)
    end

    it 'is usable as part of the unique_by conflict target' do
      maker = ImporterBtSpecMaker.create!(slug: 'acme')
      ImporterBtSpecWidget.create!(name: 'Widget A')

      klass = importer_class(:activerecord) { unique_by :name }

      csv = write_csv("Name,Maker\nWidget A,acme\n")
      klass.new(file_path: csv.path).import!

      expect(ImporterBtSpecWidget.where(name: 'Widget A').count).to eq(1)
      expect(ImporterBtSpecWidget.find_by(name: 'Widget A').maker_id).to eq(maker.id)
    end

    it "writes the association's own configured primary_key, not always id" do
      widget_class_with_override =
        Class.new(ApplicationRecord) do
          self.table_name = 'importer_bt_spec_widgets'

          belongs_to :maker, class_name: 'ImporterBtSpecMaker', optional: true, primary_key: :legacy_uid
        end
      stub_const('ImporterBtSpecWidget', widget_class_with_override)

      maker = ImporterBtSpecMaker.create!(slug: 'acme')
      legacy_uid = maker.id + 1000 # guaranteed distinct from maker.id itself
      maker.update!(legacy_uid: legacy_uid)

      csv = write_csv("Name,Maker\nWidget A,acme\n")
      importer_class.new(file_path: csv.path).import!

      expect(ImporterBtSpecWidget.find_by(name: 'Widget A').maker_id).to eq(legacy_uid)
      expect(ImporterBtSpecWidget.find_by(name: 'Widget A').maker_id).not_to eq(maker.id)
    end

    it 'is inherited by a subclass, like every other config macro' do
      expect(Class.new(importer_class).belongs_to_lookups).to eq({ maker_id: :slug })
    end

    it 'defaults to no lookups at all, leaving an unrelated importer untouched' do
      klass =
        Class.new(described_class) do
          target_model ImporterBtSpecWidget
          mode :activerecord
          required_headers({ 'Name' => :name })
        end

      expect(klass.belongs_to_lookups).to eq({})
    end
  end

  describe 'resolve_belongs_to configuration guards' do
    it 'raises when the foreign key is not mapped in required_headers' do
      klass =
        Class.new(described_class) do
          target_model ImporterBtSpecWidget
          mode :activerecord
          required_headers({ 'Name' => :name })
          resolve_belongs_to :maker_id, by: :slug
        end

      csv = write_csv("Name\nWidget A\n")

      expect { klass.new(file_path: csv.path).import! }
        .to raise_error(ArgumentError, /needs 'maker_id' mapped in required_headers/)
    end

    it 'raises when target_model has no belongs_to with that foreign key' do
      klass =
        Class.new(described_class) do
          target_model ImporterBtSpecMaker
          mode :activerecord
          required_headers({ 'Slug' => :slug, 'Legacy' => :legacy_uid })
          resolve_belongs_to :legacy_uid, by: :slug
        end

      csv = write_csv("Slug,Legacy\nacme,1\n")

      expect { klass.new(file_path: csv.path).import! }
        .to raise_error(ArgumentError, /needs a belongs_to on .* whose foreign key is 'legacy_uid'/)
    end

    it 'raises when the key column does not exist on the associated model' do
      klass = importer_class { resolve_belongs_to :maker_id, by: :not_a_column }

      csv = write_csv("Name,Maker\nWidget A,acme\n")

      expect { klass.new(file_path: csv.path).import! }
        .to raise_error(ArgumentError, /'not_a_column' is not a column on/)
    end

    it 'raises when an attribute has both a resolve_belongs_to and a cast_ method' do
      klass =
        importer_class do
          def cast_maker_id(_raw_value)
            1
          end
        end

      csv = write_csv("Name,Maker\nWidget A,acme\n")

      expect { klass.new(file_path: csv.path).import! }
        .to raise_error(ArgumentError, /both a resolve_belongs_to declaration and a cast_maker_id method/)
    end
  end
end
