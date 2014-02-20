#Encoding: utf-8
require 'spec_helper'

describe DashboardStats do
  let(:country){
    create(:geo_entity_type, :name => GeoEntityType::COUNTRY)
  }
  let(:argentina){
    create(
      :geo_entity,
      :geo_entity_type => country,
      :name => 'Argentina',
      :iso_code2 => 'AR'
    )
  }
  let(:ghana){
    create(
      :geo_entity,
      :geo_entity_type => country,
      :name => 'Ghana',
      :iso_code2 => 'GH'
    )
  }
  let(:ds_ar){
    DashboardStats.new argentina, 'Animalia', 5
  }
  let(:ds_gh){
    DashboardStats.new ghana, 'Animalia', 5
  }

  describe "#new" do
    it "takes one parameter and returns a DashboardStats object" do
      ds_ar.should be_an_instance_of DashboardStats
    end
  end

  describe "#species" do
    include_context "Caiman latirostris"
    it "has one results for argentina" do
      ds_ar.species[0][:count].should eq 1
    end
    it "has no results for ghana" do
      ds_gh.species[0][:count].should eq 0
    end
  end

# describe "#trade" do
#    include_context "Shipments"
#   it "should have some results" do
#      ds_ar = DashboardStats.new @argentina
#      
#   end
#    
# end

end
