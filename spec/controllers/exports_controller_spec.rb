require 'spec_helper'
describe ExportsController do
  describe "GET index" do
    it "assigns @designations, @cites, @eu, and @species_listings" do
      designation1 = create(:designation, :name => 'CITES', :taxonomy => create(:taxonomy))
      designation2 = create(:designation, :name => 'EU', :taxonomy => create(:taxonomy))
      species_listing1 = create(:species_listing, :designation => designation1, :name => 'I')
      species_listing2 = create(:species_listing, :designation => designation2, :name => 'A')
      get :index
      assigns(:designations).should eq([designation1, designation2])
      assigns(:cites).should eq(designation1)
      assigns(:eu).should eq(designation2)
      assigns(:species_listings).should eq([species_listing2, species_listing1])
    end
    it "renders the index template" do
      get :index
      response.should render_template("index")
    end
  end
end
