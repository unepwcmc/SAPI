require 'spec_helper'

RSpec.describe Importer::Loaders::UniqueByResolver do
  # rubocop:disable RSpec/BeforeAfterAll -- table DDL, not row data
  before(:context) do
    ActiveRecord::Base.connection.create_table :unique_by_resolver_spec_widgets, force: true do |t|
      t.string :name
      t.string :external_ref
    end
    ActiveRecord::Base.connection.add_index :unique_by_resolver_spec_widgets, :name, unique: true
    ActiveRecord::Base.connection.add_index :unique_by_resolver_spec_widgets, :external_ref, unique: true, where: 'external_ref IS NOT NULL'
  end

  after(:context) do
    ActiveRecord::Base.connection.drop_table :unique_by_resolver_spec_widgets, if_exists: true
  end
  # rubocop:enable RSpec/BeforeAfterAll

  let(:widget_class) do
    Class.new(ApplicationRecord) { self.table_name = 'unique_by_resolver_spec_widgets' }
  end

  before { stub_const('UniqueByResolverSpecWidget', widget_class) }

  it 'resolves a real unique index by column, with no Importer::Base involved at all' do
    config =
      described_class.resolve!(
        importer_class: 'SomeImporter', target_model: UniqueByResolverSpecWidget,
        unique_by: :name, written_attributes: %i[name]
      )

    expect(config.columns).to eq(%i[name])
    expect(config.nulls_not_distinct).to be(false)
    expect(config.index_predicate).to be_nil
  end

  it 'resolves the primary key directly, without querying connection.indexes at all' do
    config =
      described_class.resolve!(
        importer_class: 'SomeImporter', target_model: UniqueByResolverSpecWidget,
        unique_by: :id, written_attributes: %i[id]
      )

    expect(config.columns).to eq([ :id ])
    expect(config.nulls_not_distinct).to be(false)
    expect(config.index_predicate).to be_nil
  end

  it "captures a partial index's own predicate" do
    config =
      described_class.resolve!(
        importer_class: 'SomeImporter', target_model: UniqueByResolverSpecWidget,
        unique_by: :external_ref, written_attributes: %i[external_ref]
      )

    expect(config.index_predicate).to eq('(external_ref IS NOT NULL)')
  end

  # Resolved once at loader construction and only ever read afterwards - the surrounding
  # design leans on that ("constructing the loader *is* resolve-and-validate"), so it is
  # enforced rather than left as a convention. UniqueByConfig::NONE is frozen too.
  it 'returns a frozen config with a frozen columns Array' do
    config =
      described_class.resolve!(
        importer_class: 'SomeImporter', target_model: UniqueByResolverSpecWidget,
        unique_by: :external_ref, written_attributes: %i[external_ref]
      )

    expect(config).to be_frozen
    expect(config.columns).to be_frozen
    expect(Importer::Loaders::UniqueByConfig::NONE).to be_frozen
  end

  it 'raises naming the importer class and target model when no unique index matches' do
    expect {
      described_class.resolve!(
        importer_class: 'SomeImporter', target_model: UniqueByResolverSpecWidget,
        unique_by: :not_a_column, written_attributes: %i[not_a_column]
      )
    }.to raise_error(ArgumentError, /SomeImporter: no unique index found on UniqueByResolverSpecWidget.*unique_by: :not_a_column/)
  end

  it 'raises when the resolved column(s) are not in written_attributes' do
    expect {
      described_class.resolve!(
        importer_class: 'SomeImporter', target_model: UniqueByResolverSpecWidget,
        unique_by: :name, written_attributes: %i[external_ref]
      )
    }.to raise_error(ArgumentError, /unique_by column\(s\) name must be mapped in required_headers/)
  end
end
