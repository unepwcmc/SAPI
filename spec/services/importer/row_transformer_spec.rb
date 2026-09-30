require 'spec_helper'

RSpec.describe Importer::RowTransformer do
  # rubocop:disable RSpec/BeforeAfterAll -- table DDL, not row data
  before(:context) do
    ActiveRecord::Base.connection.create_table :row_transformer_spec_widgets, force: true do |t|
      t.string :name
      t.integer :quantity
    end
  end

  after(:context) do
    ActiveRecord::Base.connection.drop_table :row_transformer_spec_widgets, if_exists: true
  end
  # rubocop:enable RSpec/BeforeAfterAll

  let(:widget_class) do
    Class.new(ApplicationRecord) { self.table_name = 'row_transformer_spec_widgets' }
  end

  # A stand-in for Importer::Base - just enough to satisfy the cast_<attribute>
  # dispatch, with no Importer::Base subclass involved at all.
  let(:host) do
    Class.new do
      private

      def cast_quantity(raw_value)
        raw_value.to_i * 2
      end
    end.new
  end

  let(:logger) { Importer::Logger.new }

  before { stub_const('RowTransformerSpecWidget', widget_class) }

  def transformer(derived_attributes: [], belongs_to_lookups: {})
    described_class.new(
      importer_class: 'StandaloneSpec', target_model: RowTransformerSpecWidget,
      required_headers: { 'Name' => :name, 'Quantity' => :quantity }, derived_attributes:,
      belongs_to_lookups:, host:, logger:
    )
  end

  describe '.considered_blank?' do
    it 'treats a literal false as not blank, unlike Object#blank?' do
      expect(described_class.considered_blank?(false)).to be(false)
      expect(described_class.considered_blank?(nil)).to be(true)
      expect(described_class.considered_blank?('')).to be(true)
    end
  end

  describe '#build_attributes' do
    it 'casts a mapped attribute via the default caster, with no Importer::Base involved at all' do
      row_transformer = transformer
      attrs = row_transformer.build_attributes({ 'Name' => 'Widget A', 'Quantity' => '5' }, 2, primary_key_attribute: :id)

      expect(attrs).to eq(name: 'Widget A', quantity: 10) # cast_quantity doubles it
    end

    it 'raises a wrapped ImportError naming the line and column, and logs it, on a cast failure' do
      # A host with no cast_quantity override, so the strict default integer caster
      # runs (Integer('not-a-number') raises) - the shared `host` above always doubles
      # the value via to_i, which never raises for non-numeric input.
      plain_host = Class.new.new
      row_transformer =
        described_class.new(
          importer_class: 'StandaloneSpec', target_model: RowTransformerSpecWidget,
          required_headers: { 'Name' => :name, 'Quantity' => :quantity }, derived_attributes: [],
          belongs_to_lookups: {}, host: plain_host, logger:
        )

      expect {
        row_transformer.build_attributes({ 'Name' => 'Widget A', 'Quantity' => 'not-a-number' }, 7, primary_key_attribute: :id)
      }.to raise_error(Importer::Base::ImportError, /Line 7, column 'quantity'/)

      expect(logger.entries).to include(a_hash_including(level: 'error', row: 7, column: 'quantity'))
    end

    it 'omits a blank primary key entirely rather than including it as nil' do
      row_transformer = transformer
      attrs = row_transformer.build_attributes({ 'Name' => '', 'Quantity' => '1' }, 2, primary_key_attribute: :name)

      expect(attrs).not_to have_key(:name)
    end
  end

  describe '#validate!' do
    it 'raises when a derived attribute has no cast_ method to produce its value' do
      row_transformer = transformer(derived_attributes: [ :missing_caster ])

      expect { row_transformer.validate! }.to raise_error(ArgumentError, /has no cast_missing_caster method/)
    end

    it 'raises when the same attribute is both mapped and declared derived' do
      row_transformer = transformer(derived_attributes: [ :quantity ])

      expect { row_transformer.validate! }.to raise_error(ArgumentError, /declared in derived_attributes and also mapped/)
    end

    it 'does not raise for a valid configuration' do
      row_transformer = transformer

      expect { row_transformer.validate! }.not_to raise_error
    end
  end
end
