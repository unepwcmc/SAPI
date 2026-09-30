require 'spec_helper'

# Every loader is constructible and usable directly - no Importer::Base subclass, no
# target_model DSL, no file at all - proving the actual point of the composition
# refactor (see FINDINGS.md).
RSpec.describe 'Importer::Loaders' do
  # rubocop:disable RSpec/BeforeAfterAll -- table DDL, not row data
  before(:context) do
    ActiveRecord::Base.connection.create_table :loaders_spec_widgets, force: true do |t|
      t.string :name
      t.integer :quantity
    end
    ActiveRecord::Base.connection.add_index :loaders_spec_widgets, :name, unique: true
  end

  after(:context) do
    ActiveRecord::Base.connection.drop_table :loaders_spec_widgets, if_exists: true
  end
  # rubocop:enable RSpec/BeforeAfterAll

  let(:widget_class) do
    Class.new(ApplicationRecord) do
      self.table_name = 'loaders_spec_widgets'
      validates :name, presence: true
    end
  end

  # A stand-in for Importer::Base - just enough to satisfy `host.send(:on_row_skip, ...)`.
  let(:host) do
    Class.new do
      attr_reader :skipped

      def initialize
        @skipped = []
      end

      def on_row_skip(**args)
        @skipped << args
      end
    end.new
  end

  let(:logger) { Importer::Logger.new }

  before { stub_const('LoadersSpecWidget', widget_class) }

  def loader_for(klass, unique_by: nil, on_failure: :rollback, allow_primary_key_write: false)
    klass.new(
      importer_class: 'StandaloneSpec', target_model: LoadersSpecWidget, on_failure:,
      allow_primary_key_write:, unique_by:, written_attributes: %i[name quantity], host:, logger:
    )
  end

  describe Importer::Loaders::RawInsertAll do
    it 'writes a batch and reports it as written, with no Importer::Base involved at all' do
      loader = loader_for(described_class)
      batch = [ { line_number: 2, attrs: { name: 'Widget A', quantity: 1 }, row: {} } ]

      result = loader.write_batch(batch)

      expect(result).to eq(written: 1, skipped: 0)
      expect(LoadersSpecWidget.find_by(name: 'Widget A').quantity).to eq(1)
    end
  end

  describe Importer::Loaders::RawUpsertAll do
    it 'inserts new rows and updates existing ones on conflict' do
      LoadersSpecWidget.create!(name: 'Widget A', quantity: 1)
      loader = loader_for(described_class, unique_by: :name)

      batch = [
        { line_number: 2, attrs: { name: 'Widget A', quantity: 99 }, row: {} },
        { line_number: 3, attrs: { name: 'Widget B', quantity: 2 }, row: {} }
      ]

      result = loader.write_batch(batch)

      expect(result).to eq(written: 2, skipped: 0)
      expect(LoadersSpecWidget.find_by(name: 'Widget A').quantity).to eq(99)
      expect(LoadersSpecWidget.find_by(name: 'Widget B').quantity).to eq(2)
    end

    it 'raises for two rows in the same batch sharing a unique_by value' do
      loader = loader_for(described_class, unique_by: :name)
      batch = [
        { line_number: 2, attrs: { name: 'Widget A', quantity: 1 }, row: {} },
        { line_number: 3, attrs: { name: 'Widget A', quantity: 2 }, row: {} }
      ]

      expect { loader.write_batch(batch) }
        .to raise_error(Importer::Base::ImportError, /Duplicate unique_by value\(s\)/)
    end
  end

  describe Importer::Loaders::PlainRecord do
    it 'saves each row individually and reports written/skipped counts' do
      loader = loader_for(described_class, on_failure: :skip)
      batch = [
        { line_number: 2, attrs: { name: 'Widget A', quantity: 1 }, row: {} },
        { line_number: 3, attrs: { name: nil, quantity: 2 }, row: {} }
      ]

      result = loader.write_batch(batch)

      expect(result).to eq(written: 1, skipped: 1)
      expect(host.skipped.size).to eq(1)
    end
  end

  describe Importer::Loaders::ActiverecordImport do
    it 'writes a batch in one bulk statement and reports it as written' do
      loader = loader_for(described_class)
      batch = [ { line_number: 2, attrs: { name: 'Widget A', quantity: 1 }, row: {} } ]

      result = loader.write_batch(batch)

      expect(result).to eq(written: 1, skipped: 0)
      expect(LoadersSpecWidget.find_by(name: 'Widget A')).to be_present
    end
  end

  describe Importer::Loaders do
    it 'resolves each declared mode to its concrete loader class' do
      expect(described_class.class_for(:raw_insert_all)).to eq(Importer::Loaders::RawInsertAll)
      expect(described_class.class_for(:raw_upsert_all)).to eq(Importer::Loaders::RawUpsertAll)
      expect(described_class.class_for(:activerecord)).to eq(Importer::Loaders::PlainRecord)
      expect(described_class.class_for(:activerecord_import)).to eq(Importer::Loaders::ActiverecordImport)
    end

    it 'raises for an unrecognized mode' do
      expect { described_class.class_for(:not_a_mode) }.to raise_error(NotImplementedError, /not_a_mode mode is not implemented yet/)
    end
  end
end
