#Encoding: utf-8
require 'spec_helper'

describe DashboardStats do
  let(:country){
    create(:geo_entity_type, :name => GeoEntityType::COUNTRY)
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
    DashboardStats.new @argentina, 'Animalia', 5
  }
  let(:ds_gh){
    DashboardStats.new ghana, 'Animalia', 5
  }

  describe "#trade" do
    include_context "Shipments"
    before(:each) do
      Sapi::StoredProcedures.rebuild_cites_taxonomy_and_listings
      @shipment4_by_partner = create(
        :shipment,
        :taxon_concept => @animal_species,
        :appendix => 'II',
        :purpose => @purpose,
        :source => @source_wild,
        :term => @term_liv,
        :unit => nil,
        :importer => @portugal,
        :exporter => @argentina,
        :country_of_origin => nil,
        :year => 2013,
        :reported_by_exporter => true,
        :quantity => 40
      )
    end
    it "argentina should have 35 exported animals and no imports" do
      trade_results = ds_ar.trade
      trade_results[:exports][:top_traded].length.should == 1
      trade_results[:exports][:top_traded][0][:count].should eq 35
      trade_results[:imports][:top_traded].length.should eq 0
    end
  end
end
