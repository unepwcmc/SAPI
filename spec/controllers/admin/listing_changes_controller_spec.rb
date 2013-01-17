require 'spec_helper'

describe Admin::ListingChangesController do
  before do
    @taxon_concept = create(:taxon_concept)
  end

  describe "GET index" do
    it "assigns @listing_changes sorted by effective_at" do
      listing_change1 = create(:listing_change, :taxon_concept_id => @taxon_concept.id, :effective_at => 2.weeks.ago)
      listing_change2 = create(:listing_change, :taxon_concept_id => @taxon_concept.id, :effective_at => 1.week.ago)
      get :index, :taxon_concept_id => @taxon_concept.id
      assigns(:listing_changes).should eq([listing_change2, listing_change1])
      assigns(:taxon_concept).should eq @taxon_concept
    end
    it "renders the index template" do
      get :index, :taxon_concept_id => @taxon_concept.id
      response.should render_template("index")
    end
  end

  describe "XHR POST create" do
    it "renders create when successful" do
      xhr :post, :create, :listing_change => FactoryGirl.attributes_for(:listing_change), :taxon_concept_id => @taxon_concept.id
      response.should render_template("create")
    end
    it "renders new when not successful" do
      taxon_concept = create(:taxon_concept)
      xhr :post, :create, :listing_change => {}, :taxon_concept_id => @taxon_concept.id
      response.should render_template("create")
    end
  end

  describe "XHR PUT update" do
    let(:listing_change){ create(:listing_change, :taxon_concept_id => @taxon_concept.id) }
    it "responds with 200 when successful" do
      xhr :put, :update, :format => 'json', :id => listing_change.id, :listing_change => { :effective_at => 1.week.ago }
      response.should be_success
    end
    it "responds with json when not successful" do
      xhr :put, :update, :format => 'json', :id => listing_change.id, :listing_change => { :taxon_concept_id => nil }
      JSON.parse(response.body).should include('errors')
    end
  end

  describe "DELETE destroy" do
    let(:listing_change){ create(:listing_change) }
    it "redirects after delete" do
      delete :destroy, :id => listing_change.id 
      response.should render('destroy')
    end
  end

end

