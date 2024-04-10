require 'spec_helper'

describe Admin::HybridRelationshipsController do
  login_admin

  before(:each) { hybrid_relationship_type }
  let(:taxon_concept) { create(:taxon_concept) }
  let(:hybrid) { create(:taxon_concept, :name_status => 'H') }
  let(:hybrid_relationship) {
    create(:taxon_relationship,
      :taxon_relationship_type_id => hybrid_relationship_type.id,
      :taxon_concept => taxon_concept,
      :other_taxon_concept => hybrid
    )
  }
  describe "XHR GET new" do
    it "renders the new template" do
      get :new, params: { :taxon_concept_id => taxon_concept.id }, xhr: true
      expect(response).to render_template('new')
    end
    it "assigns the hybrid_relationship variable" do
      get :new, params: { :taxon_concept_id => taxon_concept.id }, xhr: true
      expect(assigns(:hybrid_relationship)).not_to be_nil
    end
  end

  describe "XHR POST create" do
    it "renders create when successful" do
      post :create, xhr: true,
        params: {
          :taxon_concept_id => taxon_concept.id,
          :taxon_relationship => {
            other_taxon_concept_id: hybrid.id
          }
        }
      expect(response).to render_template("create")
    end
    it "renders new when not successful" do
      post :create, xhr: true, params: {
          :taxon_concept_id => taxon_concept.id,
          :taxon_relationship => {
            other_taxon_concept_id: nil
          }
        }
      expect(response).to render_template("new")
    end
  end

  describe "XHR GET edit" do
    it "renders the edit template" do
      get :edit, params: { :taxon_concept_id => taxon_concept.id, :id => hybrid_relationship.id }, xhr: true
      expect(response).to render_template('new')
    end
    it "assigns the hybrid_relationship variable" do
      get :edit, params: { :taxon_concept_id => taxon_concept.id, :id => hybrid_relationship.id }, xhr: true
      expect(assigns(:hybrid_relationship)).not_to be_nil
    end
  end

  describe "XHR PUT update" do
    it "responds with 200 when successful" do
      put :update, :format => 'js', xhr: true, params: {
          :taxon_concept_id => taxon_concept.id,
          :id => hybrid_relationship.id,
          :taxon_relationship => {
            other_taxon_concept_id: hybrid.id
          }
        }
      expect(response).to render_template("create")
    end
    it "responds with json when not successful" do
      put :update, :format => 'js', xhr: true, params: {
          :taxon_concept_id => taxon_concept.id,
          :id => hybrid_relationship.id,
          :taxon_relationship => {
            other_taxon_concept_id: nil
          }
        }
      expect(response).to render_template('new')
    end
  end

  describe "DELETE destroy" do
    it "redirects after delete" do
      delete :destroy, params: { :taxon_concept_id => taxon_concept.id, :id => hybrid_relationship.id }
      expect(response).to redirect_to(
        admin_taxon_concept_names_url(hybrid_relationship.taxon_concept)
      )
    end
  end

end
