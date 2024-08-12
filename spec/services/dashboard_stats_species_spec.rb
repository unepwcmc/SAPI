require 'spec_helper'

describe DashboardStats do
  let(:argentina) {
    create(
      :geo_entity,
      geo_entity_type: country_geo_entity_type,
      name: 'Argentina',
      iso_code2: 'AR'
    )
  }
  let(:ghana) {
    create(
      :geo_entity,
      geo_entity_type: country_geo_entity_type,
      name: 'Ghana',
      iso_code2: 'GH'
    )
  }
  let(:ds_ar) {
    DashboardStats.new argentina, { kingdom: 'Animalia', trade_limit: 5 }
  }
  let(:ds_gh) {
    DashboardStats.new ghana, { kingdom: 'Animalia', trade_limit: 5 }
  }

  describe "#new" do
    it "takes three parameters and returns a DashboardStats object" do
      expect(ds_ar).to be_an_instance_of DashboardStats
    end
  end

  describe "#species" do
    include_context "Caiman latirostris"
    it "has one results for argentina" do
      expect(ds_ar.species[:cites_eu][0][:count]).to eq 1
    end
    it "has no results for ghana" do
      expect(ds_gh.species[:cites_eu][0][:count]).to eq 0
    end
  end

end
