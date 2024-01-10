require 'spec_helper'

describe DashboardStats do
  include_context "Shipments"
  describe "#trade" do
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
      @shipment_with_different_purpose = create(
        :shipment,
        :taxon_concept => @animal_species,
        :appendix => 'II',
        :purpose => create(:purpose, :code => 'Z'),
        :source => @source_wild,
        :term => @term_liv,
        :unit => nil,
        :importer => @portugal,
        :exporter => @argentina,
        :country_of_origin => nil,
        :year => 2013,
        :reported_by_exporter => false,
        :quantity => 1
      )
    end
    context "when no time range specified" do
      subject {
        DashboardStats.new(@argentina, {
          :kingdom => 'Animalia', :trade_limit => 5,
          :time_range_start => 2010, :time_range_end => 2013
        }).trade
      }
      it "argentina should have 40 exported animals and no imports" do
        subject[:exports][:top_traded].length.should == 1
        subject[:exports][:top_traded][0][:count].should eq 40
        subject[:imports][:top_traded].length.should eq 0
      end
    end
    context "when time range specified" do
      subject {
        DashboardStats.new(@argentina, {
          :kingdom => 'Animalia',
          :trade_limit => 5,
          :time_range_start => 2012, :time_range_end => 2012
        }).trade
      }
      it "argentina should have no exports in 2012-2012" do
        subject[:exports][:top_traded].length.should == 0
      end
    end
  end
end
