require 'spec_helper'

describe Admin::TaxonListingChangesController do
  login_admin

  before do
    @taxon_concept = create(:taxon_concept)
    @designation = create(:designation, :taxonomy => @taxon_concept.taxonomy)
    @appendix = create(
      :species_listing,
      :designation_id => @designation.id,
      :name => 'Appendix I',
      :abbreviation => 'I'
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
        :species_listing => @appendix,
        :taxon_concept_id => @taxon_concept.id,
        :change_type_id => @addition.id,
        :effective_at => 2.weeks.ago)
      listing_change2 = create(
        :listing_change,
        :species_listing => @appendix,
        :taxon_concept_id => @taxon_concept.id,
        :change_type_id => @addition.id,
        :effective_at => 1.week.ago
      )
      get :index, :taxon_concept_id => @taxon_concept.id,
        :designation_id => @designation.id
      assigns(:listing_changes).should eq([listing_change2, listing_change1])
      assigns(:taxon_concept).should eq @taxon_concept
    end
    it "renders the index template" do
      get :index, :taxon_concept_id => @taxon_concept.id,
        :designation_id => @designation.id
      response.should render_template("index")
    end
    it "renders the taxon_concepts_layout" do
      get :index, :taxon_concept_id => @taxon_concept.id,
        :designation_id => @designation.id
      response.should render_template('layouts/taxon_concepts')
    end
  end

  describe "GET new" do
    it "renders the new template" do
      get :new, :taxon_concept_id => @taxon_concept.id,
        :designation_id => @designation.id
      response.should render_template('new')
    end
    it "assigns @listing_change" do
      get :new, :taxon_concept_id => @taxon_concept.id,
        :designation_id => @designation.id
      assigns(:listing_change).should_not be_nil
    end
  end

  describe "POST create" do
    context "when successful" do
      it "redirects to taxon_concept listing_changes page" do
        post :create,
          :listing_change => {
            :change_type_id => @addition.id,
            :species_listing_id => @appendix.id,
            :effective_at => 1.week.ago
          },
          :taxon_concept_id => @taxon_concept.id,
          :designation_id => @designation.id
        response.should redirect_to(
          admin_taxon_concept_designation_listing_changes_url(@taxon_concept, @designation)
        )
      end
    end
    it "renders new when not successful" do
      taxon_concept = create(:taxon_concept)
      post :create, :listing_change => {},
        :taxon_concept_id => @taxon_concept.id,
        :designation_id => @designation.id
      response.should render_template("new")
    end
  end

  describe "GET edit" do
    before(:each) do
      @listing_change = create(
        :listing_change,
        :taxon_concept_id => @taxon_concept.id,
        :change_type_id => @addition.id,
        :species_listing_id => @appendix.id,
        :effective_at => 1.week.ago
      )
    end
    it "renders the edit template" do
      get :edit, :id => @listing_change.id,
        :taxon_concept_id => @taxon_concept.id,
        :designation_id => @designation.id
      response.should render_template('edit')
    end
    it "assigns the listing_change variable" do
      get :edit, :id => @listing_change.id,
        :taxon_concept_id => @taxon_concept.id,
        :designation_id => @designation.id
      assigns(:listing_change).should_not be_nil
    end
  end

  describe "PUT update" do
    before(:each) do
      @annotation = create(:annotation)
      @listing_change = create(
        :listing_change,
        :taxon_concept_id => @taxon_concept.id,
        :change_type_id => @addition.id,
        :species_listing_id => @appendix.id,
        :effective_at => 1.week.ago,
        :annotation_id => @annotation.id
      )
    end
    context "when successful" do
      it "redirects to taxon_concept listing_changes page" do
        put :update,
          :listing_change => {
            :change_type_id => @addition.id,
            :species_listing_id => @appendix.id,
            :effective_at => 1.week.ago
          },
          :id => @listing_change.id,
          :taxon_concept_id => @taxon_concept.id,
          :designation_id => @designation.id
        response.should redirect_to(
          admin_taxon_concept_designation_listing_changes_url(@taxon_concept, @designation)
        )
      end
      it "redirects to eu regulation listing changes page when param is set" do
        taxon_concept = create(:taxon_concept)
        eu_designation = create(:designation, :name => "EU",
                                :taxonomy => taxon_concept.taxonomy)
        eu_regulation = create(:eu_regulation, :designation_id => eu_designation.id)
        annex = create(
          :species_listing,
          :designation_id => eu_designation.id,
          :name => 'Annex A',
          :abbreviation => 'A'
        )
        addition = create(
          :change_type,
          :designation_id => eu_designation.id,
          :name => 'ADDITION'
        )
        listing_change2 = create(
          :listing_change,
          :taxon_concept_id => taxon_concept.id,
          :change_type_id => addition.id,
          :species_listing_id => annex.id,
          :effective_at => 1.week.ago,
          :event_id => eu_regulation.id
        )
        put :update,
          :listing_change => {
            :change_type_id => addition.id,
            :species_listing_id => annex.id,
            :effective_at => 1.week.ago
          },
          :id => listing_change2.id,
         :taxon_concept_id => taxon_concept.id,
          :designation_id => eu_designation.id,
          :redirect_to_eu_reg => "1"
        response.should redirect_to(
          admin_eu_regulation_listing_changes_url(eu_regulation)
        )
      end
    end
    it "renders edit when not successful" do
      put :update, :listing_change => { :effective_at => nil },
        :id => @listing_change.id,
        :taxon_concept_id => @taxon_concept.id,
        :designation_id => @designation.id
      response.should render_template('edit')
    end

    it "redirects to index page and removes annotation when fields cleared" do
      put :update,
        :id => @listing_change.id,
        :taxon_concept_id => @taxon_concept.id,
        :designation_id => @designation.id,
        :listing_change => {
          :annotation_attributes => {
            "short_note_en" => "", "short_note_es" => "",
            "short_note_fr" => "", "full_note_en" => "",
            "full_note_es" => "", "full_note_fr" => "",
            "id" => @annotation.id
          }
        }
      response.should redirect_to(
        admin_taxon_concept_designation_listing_changes_url(
          @taxon_concept, @designation)
      )
      @listing_change.reload.annotation.should be_nil
    end
  end

  describe "DELETE destroy" do
    before(:each) do
      @listing_change = create(
        :listing_change,
        :taxon_concept_id => @taxon_concept.id,
        :change_type_id => @addition.id,
        :species_listing_id => @appendix.id,
        :effective_at => 1.week.ago
      )
    end
    it "redirects after delete" do
      delete :destroy, :id => @listing_change.id,
        :taxon_concept_id => @taxon_concept.id,
        :designation_id => @designation.id
      response.should redirect_to(
        admin_taxon_concept_designation_listing_changes_url(@taxon_concept, @designation)
      )
    end
  end
  describe "Authorization for contributors" do
    login_contributor
    let!(:listing_change) {
      create(
        :listing_change,
        :taxon_concept_id => @taxon_concept.id,
        :change_type_id => @addition.id,
        :species_listing_id => @appendix.id,
        :effective_at => 1.week.ago
      )
    }
    describe "GET index" do
      it "renders the index template" do
        get :index, :taxon_concept_id => @taxon_concept.id,
          :designation_id => @designation.id
        response.should render_template("index")
      end
      it "renders the taxon_concepts_layout" do
        get :index, :taxon_concept_id => @taxon_concept.id,
          :designation_id => @designation.id
        response.should render_template('layouts/taxon_concepts')
      end
    end
    describe "DELETE destroy" do
      it "fails to delete and redirects" do
        @request.env['HTTP_REFERER'] = admin_taxon_concept_designation_listing_changes_url(@taxon_concept, @designation)
        delete :destroy, :id => listing_change.id,
          :taxon_concept_id => @taxon_concept.id,
          :designation_id => @designation.id
        response.should redirect_to(
          admin_taxon_concept_designation_listing_changes_url(@taxon_concept, @designation)
        )
        ListingChange.find(listing_change.id).should_not be_nil
      end
    end
  end
end
