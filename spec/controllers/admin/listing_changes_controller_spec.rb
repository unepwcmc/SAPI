require 'spec_helper'

describe Admin::ListingChangesController do
  before do
    @taxon_concept = create(:taxon_concept)
    @addition = create(
      :change_type,
      :designation_id => @taxon_concept.designation_id,
      :name => 'ADDITION'
    )
  end

  describe "GET index" do
    it "assigns @listing_changes sorted by effective_at" do
      listing_change1 = create(
        :listing_change,
        :taxon_concept_id => @taxon_concept.id,
        :change_type_id => @addition.id,
        :effective_at => 2.weeks.ago)
      listing_change2 = create(
        :listing_change,
        :taxon_concept_id => @taxon_concept.id,
        :change_type_id => @addition.id,
        :effective_at => 1.week.ago
      )
      get :index, :taxon_concept_id => @taxon_concept.id
      assigns(:listing_changes).should eq([listing_change2, listing_change1])
      assigns(:taxon_concept).should eq @taxon_concept
    end
    it "renders the index template" do
      get :index, :taxon_concept_id => @taxon_concept.id
      response.should render_template("index")
    end
    it "renders the taxon_concepts_layout" do
      get :index, :taxon_concept_id => @taxon_concept.id
      response.should render_template('layouts/taxon_concepts')
    end
  end

  describe "XHR POST create" do
    it "renders create when successful" do
      xhr :post, :create, :listing_change => FactoryGirl.attributes_for(:listing_change).merge(
        :change_type_id => @addition.id,
        :effective_at => 1.week.ago
        ),
        :taxon_concept_id => @taxon_concept.id
      response.should render_template("create")
    end
    it "renders new when not successful" do
      taxon_concept = create(:taxon_concept)
      xhr :post, :create, :listing_change => {}, :taxon_concept_id => @taxon_concept.id
      response.should render_template("new")
    end
  end

end

