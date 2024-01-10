require 'spec_helper'

describe Admin::TaxonEuSuspensionsController do
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
      it "redirects to the EU suspensions index" do
        post :create,
          :eu_suspension => {
            :eu_decision_type_id => @eu_decision_type.id,
            :start_date => Date.new(2013, 1, 1),
            :geo_entity_id => create(
              :geo_entity, :geo_entity_type_id => country_geo_entity_type.id
            )
          },
          :taxon_concept_id => @taxon_concept.id
        response.should redirect_to(admin_taxon_concept_eu_suspensions_url(@taxon_concept.id))
      end
    end

    context "when not successful" do
      it "renders new" do
        post :create, :eu_suspension => {},
          :taxon_concept_id => @taxon_concept.id
        response.should render_template("new")
      end
    end
  end

  describe "GET edit" do
    before(:each) do
      @eu_suspension = create(
        :eu_suspension,
        :taxon_concept_id => @taxon_concept.id
      )
    end
    it "renders the edit template" do
      get :edit, :id => @eu_suspension.id, :taxon_concept_id => @taxon_concept.id
      response.should render_template('edit')
    end
    it "assigns @geo_entities" do
      territory = create(:geo_entity, :geo_entity_type_id => territory_geo_entity_type.id)
      get :edit, :id => @eu_suspension.id, :taxon_concept_id => @taxon_concept.id
      assigns(:geo_entities).should include(territory)
    end
  end

  describe "PUT update" do
    before(:each) do
      @eu_suspension = create(
        :eu_suspension,
        taxon_concept_id: @taxon_concept.id
      )
      @srg_history = create(:srg_history)
    end

    context "when successful" do
      context "when eu_decision_type is present" do
        it "renders taxon_concepts EU suspensions page" do
          put :update,
            eu_suspension: {
              eu_decision_type_id: create(:eu_decision_type),
              geo_entity_id: create(
                :geo_entity, :geo_entity_type_id => country_geo_entity_type.id
              )
            },
            id: @eu_suspension.id,
            taxon_concept_id: @taxon_concept.id
          response.should redirect_to(
            admin_taxon_concept_eu_suspensions_url(@taxon_concept)
          )
        end
      end
      context "when eu_decision_type is not present" do
        it "renders taxon_concepts EU suspensions page" do
          put :update,
            eu_suspension: {
              eu_decision_type_id: nil,
              srg_history_id: @srg_history.id,
              geo_entity_id: create(
                :geo_entity, :geo_entity_type_id => country_geo_entity_type.id
              )
            },
            id: @eu_suspension.id,
            taxon_concept_id: @taxon_concept.id
          response.should redirect_to(
            admin_taxon_concept_eu_suspensions_url(@taxon_concept)
          )
        end
      end
    end

    context "when not successful" do
      context "when eu_decision_type is present" do
        it "renders new" do
          put :update,
            eu_suspension: {
              eu_decision_type_id: create(:eu_decision_type),
              geo_entity_id: nil
            },
            id: @eu_suspension.id,
            taxon_concept_id: @taxon_concept.id
          response.should render_template('new')
        end
      end
      context "when eu_decision_type is not present" do
        it "renders new" do
          put :update,
            eu_suspension: {
              eu_decision_type_id: nil,
              srg_history_id: @srg_history.id,
              geo_entity_id: nil
            },
            id: @eu_suspension.id,
            taxon_concept_id: @taxon_concept.id
          response.should render_template('new')
        end
      end
    end

    context "when both eu_decision_type and srg_history are empty" do
      it "renders new" do
        put :update,
          eu_suspension: {
            eu_decision_type_id: nil,
            srg_history_id: nil,
            start_date: nil
          },
          id: @eu_suspension.id,
          taxon_concept_id: @taxon_concept.id
        response.should render_template('new')
      end
    end
  end

  describe "DELETE destroy" do
    before(:each) do
      @eu_suspension = create(
        :eu_suspension,
        :taxon_concept_id => @taxon_concept.id
      )
    end
    it "redirects after delete" do
      delete :destroy, :id => @eu_suspension.id,
        :taxon_concept_id => @taxon_concept.id
      response.should redirect_to(
        admin_taxon_concept_eu_suspensions_url(@taxon_concept)
      )
    end
  end

  describe "Authorization for contributors" do
    login_contributor
    let!(:eu_suspension) {
      create(
        :eu_suspension,
        :taxon_concept_id => @taxon_concept.id
      )
    }
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
    describe "DELETE destroy" do
      it "fails to delete and redirects" do
        @request.env['HTTP_REFERER'] = admin_taxon_concept_eu_suspensions_url(@taxon_concept)
        delete :destroy, :id => eu_suspension.id,
          :taxon_concept_id => @taxon_concept.id
        response.should redirect_to(
          admin_taxon_concept_eu_suspensions_url(@taxon_concept)
        )
        EuSuspension.find(eu_suspension.id).should_not be_nil
      end
    end
  end
end
