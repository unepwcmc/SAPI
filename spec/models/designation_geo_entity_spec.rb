require 'spec_helper'

describe DesignationGeoEntity do
  let(:geo_entity) { create(:geo_entity) }

  before { described_class.create!(designation: cites, geo_entity:) }

  it 'refuses the same geo entity twice for one designation' do
    expect(described_class.new(designation: cites, geo_entity:)).not_to be_valid
  end

  it 'allows the same geo entity for another designation' do
    expect(described_class.new(designation: cms_designation, geo_entity:)).to be_valid
  end

  it 'clears the cached geo entity search, which carries designations' do
    allow(GeoEntitySearch).to receive(:increment_cache_iterator)
    described_class.create!(designation: cms_designation, geo_entity:)
    expect(GeoEntitySearch).to have_received(:increment_cache_iterator)
  end
end
