require 'spec_helper'

describe Admin::EuOpinionsController do
  login_admin

  before do
    @taxon_concept = create(:taxon_concept)
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
    it "assigns @geo_entities (country and territory) with two objects" do
      territory = create(:geo_entity, :geo_entity_type_id => territory_geo_entity_type.id)
      country = create(:geo_entity)
      get :new, :taxon_concept_id => @taxon_concept.id
      assigns(:geo_entities).size.should == 2
    end
  end

  describe "POST create" do
    context "when successful" do
      before do
        @eu_decision_type = create(:eu_decision_type)
      end
      it "redirects to the EU Opinions index" do
        post :create, :eu_opinion => {
            :eu_decision_type_id => @eu_decision_type.id,
            :start_date => Date.today,
            :geo_entity_id => create(
              :geo_entity, :geo_entity_type_id => country_geo_entity_type.id
            )
          },
          :taxon_concept_id => @taxon_concept.id
          response.should redirect_to(admin_taxon_concept_eu_opinions_url(@taxon_concept.id))
      end
    end

    context "when not successful" do
      it "renders new" do
        post :create, :eu_opinion => {},
          :taxon_concept_id => @taxon_concept.id
        response.should render_template("new")
      end
    end
  end

  describe "GET edit" do
    before(:each) do
      @eu_opinion = create(
        :eu_opinion,
        :taxon_concept_id => @taxon_concept.id
      )
    end
    it "renders the edit template" do
      get :edit, :id => @eu_opinion.id, :taxon_concept_id => @taxon_concept.id
      response.should render_template('edit')
    end
    it "assigns @geo_entities" do
      territory = create(:geo_entity, :geo_entity_type_id => territory_geo_entity_type.id)
      get :edit, :id => @eu_opinion.id, :taxon_concept_id => @taxon_concept.id
      assigns(:geo_entities).should include(territory)
    end
  end

  describe "PUT update" do
    before(:each) do
      @eu_opinion = create(
        :eu_opinion,
        :taxon_concept_id => @taxon_concept.id
      )
      @eu_decision_type = create(:eu_decision_type)
    end

    context "when successful" do
      it "renders taxon_concepts EU Opinions page" do
        put :update, :eu_opinion => {
            :eu_decision_type_id => @eu_decision_type.id
          },
          :id => @eu_opinion.id,
          :taxon_concept_id => @taxon_concept.id
        response.should redirect_to(
          admin_taxon_concept_eu_opinions_url(@taxon_concept)
        )
      end
    end

    context "when not successful" do
      it "renders new" do
        put :update, :eu_opinion => {
            :eu_decision_type_id => nil
          },
          :id => @eu_opinion.id,
          :taxon_concept_id => @taxon_concept.id
        response.should render_template('new')
      end
    end
  end

  describe "DELETE destroy" do
    before(:each) do
      @eu_opinion = create(
        :eu_opinion,
        :taxon_concept_id => @taxon_concept.id
      )
    end
    it "redirects after delete" do
      delete :destroy, :id => @eu_opinion.id,
        :taxon_concept_id => @taxon_concept.id
      response.should redirect_to(
        admin_taxon_concept_eu_opinions_url(@taxon_concept)
      )
    end
  end
end
