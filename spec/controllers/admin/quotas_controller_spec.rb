require 'spec_helper'

describe Admin::QuotasController do
  before do
    @taxon_concept = create(:taxon_concept)
    @unit = create(:unit)
    @geo_entity = create(:geo_entity)
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
        post :create, :quota => {
            :quota => 1,
            :unit_id => @unit.id,
            :publication_date => 1.week.ago,
            :geo_entity_id => @geo_entity.id
          },
          :taxon_concept_id => @taxon_concept.id
        response.should redirect_to(
          admin_taxon_concept_quotas_url(@taxon_concept)
        )
      end
    end
    it "renders new when not successful" do
      post :create, :quota => {},
        :taxon_concept_id => @taxon_concept.id
      response.should render_template("new")
    end
  end

  describe "GET edit" do
    before(:each) do
      @quota = create(
        :quota,
        :unit_id => @unit.id,
        :taxon_concept_id => @taxon_concept.id,
        :geo_entity_id => @geo_entity.id
      )
    end
    it "renders the edit template" do
      get :edit, :id => @quota.id, :taxon_concept_id => @taxon_concept.id
      response.should render_template('edit')
    end
  end

  describe "PUT update" do
    before(:each) do
      @quota = create(
        :quota,
        :unit_id => @unit.id,
        :taxon_concept_id => @taxon_concept.id,
        :geo_entity_id => @geo_entity.id
      )
    end

    context "when successful" do
      it "renders taxon_concepts quotas page" do
        put :update, :quota => {
            :publication_date => 1.week.ago
          },
          :id => @quota.id,
          :taxon_concept_id => @taxon_concept.id
        response.should redirect_to(
          admin_taxon_concept_quotas_url(@taxon_concept)
        )
      end
    end

    it "renders new when not successful" do
      put :update, :quota => {
          :publication_date => nil
        },
        :id => @quota.id,
        :taxon_concept_id => @taxon_concept.id
      response.should render_template('new')
    end
  end

  describe "DELETE destroy" do
    before(:each) do
      @quota = create(
        :quota,
        :unit_id => @unit.id,
        :taxon_concept_id => @taxon_concept.id,
        :geo_entity_id => @geo_entity.id
      )
    end
    it "redirects after delete" do
      delete :destroy, :id => @quota.id,
        :taxon_concept_id => @taxon_concept.id
      response.should redirect_to(
        admin_taxon_concept_quotas_url(@taxon_concept)
      )
    end
  end
end
