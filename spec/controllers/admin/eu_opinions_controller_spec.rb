require 'spec_helper'

describe Admin::EuOpinionsController do
  login_admin

  before do
    @taxon_concept = create(:taxon_concept)
    @eu_regulation = create(:ec_srg)
  end

  describe "GET index" do
    it "renders the index template" do
      get :index, taxon_concept_id: @taxon_concept.id
      response.should render_template("index")
    end
    it "renders the taxon_concepts_layout" do
      get :index, taxon_concept_id: @taxon_concept.id
      response.should render_template('layouts/taxon_concepts')
    end
  end

  describe "GET new" do
    it "renders the new template" do
      get :new, taxon_concept_id: @taxon_concept.id
      response.should render_template('new')
    end
    it "assigns @geo_entities (country and territory) with two objects" do
      create(:geo_entity, :geo_entity_type_id => territory_geo_entity_type.id)
      create(:geo_entity)
      get :new, taxon_concept_id: @taxon_concept.id
      assigns(:geo_entities).size.should == 2
    end
  end

  describe "POST create" do
    context "when successful" do
      before do
        @eu_decision_type = create(:eu_decision_type)
        @srg_history = create(:srg_history)
      end
      context "when intersessional document is present" do
        before do
          @document = create(:commission_note)
        end
        it "redirects to the EU Opinions index" do
          post :create,
            eu_opinion: {
              eu_decision_type_id: @eu_decision_type.id,
              srg_history_id: @srg_history.id,
              start_date: Date.today,
              document_id: @document.id,
              geo_entity_id: create(
                :geo_entity, geo_entity_type_id: country_geo_entity_type.id
              )
            },
            taxon_concept_id: @taxon_concept.id
          response.should redirect_to(admin_taxon_concept_eu_opinions_url(@taxon_concept))
        end
      end
      context "when event is present" do
        it "redirects to the EU Opinions index" do
          post :create,
            eu_opinion: {
              eu_decision_type_id: @eu_decision_type.id,
              srg_history_id: @srg_history.id,
              start_date: Date.today,
              start_event_id: @eu_regulation.id,
              geo_entity_id: create(
                :geo_entity, geo_entity_type_id: country_geo_entity_type.id
              )
            },
            taxon_concept_id: @taxon_concept.id
          response.should redirect_to(admin_taxon_concept_eu_opinions_url(@taxon_concept))
        end
      end
    end

    context "when not successful" do
      it "renders new" do
        post :create, eu_opinion: {},
          taxon_concept_id: @taxon_concept.id
        response.should render_template("new")
      end
    end
  end

  describe "GET edit" do
    before(:each) do
      @eu_opinion = create(
        :eu_opinion,
        taxon_concept_id: @taxon_concept.id,
        start_event_id: @eu_regulation.id
      )
    end
    it "renders the edit template" do
      get :edit, id: @eu_opinion.id, taxon_concept_id: @taxon_concept.id, start_event_id: @eu_regulation.id
      response.should render_template('edit')
    end
    it "assigns @geo_entities" do
      territory = create(:geo_entity, geo_entity_type_id: territory_geo_entity_type.id)
      get :edit, id: @eu_opinion.id, taxon_concept_id: @taxon_concept.id, start_event_id: @eu_regulation.id
      assigns(:geo_entities).should include(territory)
    end
  end

  describe "PUT update" do
    before(:each) do
      @eu_opinion = create(
        :eu_opinion,
        taxon_concept_id: @taxon_concept.id,
        start_event_id: @eu_regulation.id
      )
      @eu_decision_type = create(:eu_decision_type)
      @srg_history = create(:srg_history)
      @document = create(:commission_note)
    end

    context "when successful" do
      context "when eu decision type is present" do
        it "renders taxon_concepts EU Opinions page" do
          put :update,
            eu_opinion: {
              eu_decision_type_id: @eu_decision_type.id,
              start_event_id: @eu_regulation.id
            },
            id: @eu_opinion.id,
            taxon_concept_id: @taxon_concept.id
          response.should redirect_to(
            admin_taxon_concept_eu_opinions_url(@taxon_concept)
          )
        end
      end

      context "when eu decision type is not present" do
        it "renders taxon_concepts EU Opinions page" do
          put :update,
          eu_opinion: {
            eu_decision_type_id: nil,
            srg_history_id: @srg_history.id,
            start_event_id: @eu_regulation.id
          },
          id: @eu_opinion.id,
          taxon_concept_id: @taxon_concept.id
          response.should redirect_to(
            admin_taxon_concept_eu_opinions_url(@taxon_concept)
          )
        end
      end

      context "when event is present" do
        it "renders taxon_concepts EU Opinions page" do
          put :update,
            eu_opinion: {
              eu_decision_type_id: @eu_decision_type.id,
              start_event_id: @eu_regulation.id
            },
            id: @eu_opinion.id,
            taxon_concept_id: @taxon_concept.id
          response.should redirect_to(
            admin_taxon_concept_eu_opinions_url(@taxon_concept)
          )
        end
      end

      context "when event is not present" do
        it "renders taxon_concepts EU Opinions page" do
          put :update,
            eu_opinion: {
              eu_decision_type_id: @eu_decision_type.id,
              start_event_id: nil,
              document_id: @document.id
            },
            id: @eu_opinion.id,
            taxon_concept_id: @taxon_concept.id
          response.should redirect_to(
            admin_taxon_concept_eu_opinions_url(@taxon_concept)
          )
        end
      end
    end

    context "when not successful" do
      context "when eu decision type is present" do
        it "renders new" do
          put :update,
            eu_opinion: {
              eu_decision_type_id: @eu_decision_type.id,
              start_event_id: @eu_regulation.id,
              start_date: nil
            },
            id: @eu_opinion.id,
            taxon_concept_id: @taxon_concept.id
          response.should render_template('new')
        end
      end

      context "when eu decision type is not present" do
        it "renders new" do
          put :update,
            eu_opinion: {
              eu_decision_type_id: nil,
              srg_history_id: @srg_history.id,
              start_event_id: @eu_regulation.id,
              start_date: nil
            },
            id: @eu_opinion.id,
            taxon_concept_id: @taxon_concept.id
          response.should render_template('new')
        end
      end
    end

    context "when both eu_decision_type and srg_history are empty" do
      it "renders new" do
        put :update,
          eu_opinion: {
            eu_decision_type_id: nil,
            srg_history_id: nil,
            start_date: nil
          },
          id: @eu_opinion.id,
          taxon_concept_id: @taxon_concept.id
        response.should render_template('new')
      end
    end

    context "when event is present" do
      it "renders new" do
        put :update,
          eu_opinion: {
            eu_decision_type_id: @eu_decision_type.id,
            start_event_id: @eu_regulation.id,
            start_date: nil
          },
          id: @eu_opinion.id,
          taxon_concept_id: @taxon_concept.id
        response.should render_template('new')
      end
    end

    context "when event is not present" do
      it "renders new" do
        put :update,
          eu_opinion: {
            eu_decision_type_id: @eu_decision_type.id,
            start_event_id: nil,
            document_id: @document.id,
            start_date: nil
          },
          id: @eu_opinion.id,
          taxon_concept_id: @taxon_concept.id
        response.should render_template('new')
      end
    end

    context "when both event and intersessional doc are empty" do
      it "renders new" do
        put :update,
          eu_opinion: {
            eu_decision_type_id: @eu_decision_type.id,
            start_event_id: nil,
            document_id: nil,
            start_date: nil
          },
          id: @eu_opinion.id,
          taxon_concept_id: @taxon_concept.id
        response.should render_template('new')
      end
    end

    context "when both event and intersessional doc are present" do
      it "renders new" do
        put :update,
          eu_opinion: {
            eu_decision_type_id: @eu_decision_type.id,
            start_event_id: @eu_regulation.id,
            document_id: @document.id,
            start_date: nil
          },
          id: @eu_opinion.id,
          taxon_concept_id: @taxon_concept.id
        response.should render_template('new')
      end
    end
  end

  describe "DELETE destroy" do
    before(:each) do
      @eu_opinion = create(
        :eu_opinion,
        taxon_concept_id: @taxon_concept.id,
        start_event_id: @eu_regulation.id
      )
    end
    it "redirects after delete" do
      delete :destroy, id: @eu_opinion.id,
        taxon_concept_id: @taxon_concept.id, start_event_id: @eu_regulation.id
      response.should redirect_to(
        admin_taxon_concept_eu_opinions_url(@taxon_concept)
      )
    end
  end
end
