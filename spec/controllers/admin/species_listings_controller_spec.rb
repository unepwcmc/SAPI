require 'spec_helper'

describe Admin::SpeciesListingsController do
  login_admin

  describe "index" do
    it "assigns @species_listings sorted by designation and name" do
      designation1 = create(:designation, :name => 'BB', :taxonomy => create(:taxonomy))
      designation2 = create(:designation, :name => 'AA', :taxonomy => create(:taxonomy))
      species_listing2_1 = create(:species_listing, :designation => designation2, :name => 'I')
      species_listing2_2 = create(:species_listing, :designation => designation2, :name => 'II')
      species_listing1 = create(:species_listing, :designation => designation1, :name => 'I')
      get :index
      assigns(:species_listings).should eq([species_listing1, species_listing2_1, species_listing2_2])
    end
    it "renders the index template" do
      get :index
      response.should render_template("index")
    end
  end

  describe "XHR POST create" do
    it "renders create when successful" do
      xhr :post, :create, species_listing: build_attributes(:species_listing)
      response.should render_template("create")
    end
    it "renders new when not successful" do
      xhr :post, :create, species_listing: {}
      response.should render_template("new")
    end
  end

  describe "XHR PUT update" do
    let(:species_listing) { create(:species_listing) }
    it "responds with 200 when successful" do
      xhr :put, :update, :format => 'json', :id => species_listing.id, :species_listing => { :name => 'ZZ' }
      response.should be_success
    end
    it "responds with json when not successful" do
      xhr :put, :update, :format => 'json', :id => species_listing.id, :species_listing => { :name => nil }
      JSON.parse(response.body).should include('errors')
    end
  end

  describe "DELETE destroy" do
    let(:species_listing) { create(:species_listing) }
    it "redirects after delete" do
      delete :destroy, :id => species_listing.id
      response.should redirect_to(admin_species_listings_url)
    end
  end

end
