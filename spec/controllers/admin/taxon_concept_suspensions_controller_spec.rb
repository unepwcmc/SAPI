require 'spec_helper'

describe Admin::TaxonConceptSuspensionsController do
  before do
    @taxon_concept = create(:taxon_concept)
    @suspension = create(:suspension, :taxon_concept => @taxon_concept)
  end

  describe "GET index" do
    it "renders the index template" do
      get :index, :taxon_concept_id => @taxon_concept.id
      response.should render_template("index")
    end
    it "renders the taxon_concepts_layout" do
      get :index, :taxon_concept_id => @taxon_concept.id
      response.should render_template('layouts/taxon_concepts')
    end
  end

  describe "GET new" do
    it "renders the new template" do
      get :new, :taxon_concept_id => @taxon_concept.id
      response.should render_template('new')
    end
  end

  describe "POST create" do
    context "when successful" do
      it "renders index" do
        post :create, :suspension => {
            :publication_date => "22/03/2013",
            :is_current => 1
          },
          :taxon_concept_id => @taxon_concept.id
        response.should redirect_to(
          admin_taxon_concept_suspensions_url(@taxon_concept)
        )
      end
    end
    it "renders new when not successful" do
      post :create, :suspension => {},
        :taxon_concept_id => @taxon_concept.id
      response.should render_template('new')
    end
  end

  describe "GET edit" do
    it "renders the edit template" do
      get :edit, :id => @suspension.id, :taxon_concept_id => @taxon_concept.id
      response.should render_template('edit')
    end
  end

  describe "PUT update" do
    context "when successful" do
      it "renders taxon_concepts suspensions page" do
        put :update, :suspension => {
            :publication_date => 1.week.ago
          },
          :id => @suspension.id,
          :taxon_concept_id => @taxon_concept.id
        response.should redirect_to(
          admin_taxon_concept_suspensions_url(@taxon_concept)
        )
      end
    end

    it "renders new when not successful" do
      put :update, :taxon_concept_suspension => {
          :publication_date => nil
        },
        :id => @suspension.id,
        :taxon_concept_id => @taxon_concept.id
      response.should redirect_to(
        admin_taxon_concept_suspensions_url(@taxon_concept)
      )
    end
  end

  describe "DELETE destroy" do
    it "redirects after delete" do
      delete :destroy, :id => @suspension.id,
        :taxon_concept_id => @taxon_concept.id
      response.should redirect_to(
        admin_taxon_concept_suspensions_url(@taxon_concept)
      )
    end
  end
end
