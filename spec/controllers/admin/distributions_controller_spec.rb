require 'spec_helper'

describe Admin::DistributionsController do
  before do
    @taxon_concept = create(:taxon_concept)
  end
  describe "XHR GET 'new'" do
    it "returns http success and renders the new template" do
      xhr :get, :new, :taxon_concept_id => @taxon_concept.id
      response.should be_success
      response.should render_template('new')
    end
    it "assigns the distribution variable" do
      xhr :get, :new, :taxon_concept_id => @taxon_concept.id
      assigns(:distribution).should_not be_nil
      assigns(:tags).should_not be_nil
      assigns(:geo_entities).should_not be_nil
    end
  end

  describe "XHR POST 'create'" do
    let(:geo_entity) { create(:geo_entity) }
    it "renders create when successful" do
      xhr :post, :create,
        :taxon_concept_id => @taxon_concept.id,
        :distribution => {
          :geo_entity_id => geo_entity.id
        },
        :reference => {}
      response.should render_template("create")
    end
  end

  describe "XHR GET edit" do
    let(:distribution) { create(:distribution, :taxon_concept_id => @taxon_concept.id) }
    it "renders the edit template" do
      xhr :get, :edit, :taxon_concept_id => @taxon_concept.id,
        :id => distribution.id
      response.should render_template('new')
    end
    it "assigns the distribution variable" do
      xhr :get, :edit, :taxon_concept_id => @taxon_concept.id,
        :id => distribution.id
      assigns(:distribution).should_not be_nil
    end
  end

  describe "XHR PUT update" do
    let(:distribution) { create(:distribution, :taxon_concept_id => @taxon_concept.id) }
    let(:geo_entity) { create(:geo_entity) }
    it "responds with 200 when successful" do
      xhr :put, :update, :format => 'json',
        :taxon_concept_id => @taxon_concept.id,
        :id => distribution.id,
        :distribution => {
          :geo_entity_id => geo_entity.id
        }
      response.should be_success
    end
  end

  describe "DELETE destroy" do
    let(:distribution) { create(:distribution, :taxon_concept_id => @taxon_concept.id) }
    it "redirects after delete" do
      delete :destroy,
        :taxon_concept_id => @taxon_concept.id,
        :id => distribution.id
      response.should redirect_to(
        edit_admin_taxon_concept_url(distribution.taxon_concept)
      )
    end
  end

end
