require 'spec_helper'

describe Admin::ListingChangesController do
  login_admin

  before do
    @taxon_concept = create(:taxon_concept)
    @designation = create(:designation, :name => "EU", :taxonomy => @taxon_concept.taxonomy)
    @eu_regulation = create(:eu_regulation, :designation_id => @designation.id)
    @annex = create(
      :species_listing,
      :designation_id => @designation.id,
      :name => 'Annex A',
      :abbreviation => 'A'
    )
    @addition = create(
      :change_type,
      :designation_id => @designation.id,
      :name => 'ADDITION'
    )
    create(
      :change_type,
      :designation_id => @designation.id,
      :name => 'EXCEPTION'
    )
  end

  describe "GET index" do
    it "assigns @listing_changes sorted by effective_at" do
      listing_change1 = create(
        :listing_change,
        :species_listing => @annex,
        :taxon_concept_id => @taxon_concept.id,
        :change_type_id => @addition.id,
        :event_id => @eu_regulation.id,
        :effective_at => 2.weeks.ago)
      listing_change2 = create(
        :listing_change,
        :species_listing => @annex,
        :taxon_concept_id => @taxon_concept.id,
        :change_type_id => @addition.id,
        :event_id => @eu_regulation.id,
        :effective_at => 1.week.ago
      )
      get :index, :eu_regulation_id => @eu_regulation.id
      assigns(:listing_changes).should eq([listing_change2, listing_change1])
      assigns(:eu_regulation).should eq @eu_regulation
    end
    it "renders the index template" do
      get :index, :eu_regulation_id => @eu_regulation.id
      response.should render_template("index")
    end
    it "renders the admin layout" do
      get :index, :eu_regulation_id => @eu_regulation.id
      response.should render_template('layouts/admin')
    end
  end

  describe "DELETE destroy" do
    before(:each) do
      @listing_change = create(
        :listing_change,
        :taxon_concept_id => @taxon_concept.id,
        :change_type_id => @addition.id,
        :species_listing_id => @annex.id,
        :event_id => @eu_regulation.id,
        :effective_at => 1.week.ago
      )
    end
    it "redirects after delete" do
      delete :destroy, :id => @listing_change.id,
        :eu_regulation_id => @eu_regulation.id
      response.should redirect_to(
        admin_eu_regulation_listing_changes_url(@eu_regulation)
      )
    end
  end
end
