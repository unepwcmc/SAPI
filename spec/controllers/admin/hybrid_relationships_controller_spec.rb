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
      xhr :get, :new, :taxon_concept_id => taxon_concept.id
      response.should render_template('new')
    end
    it "assigns the hybrid_relationship variable" do
      xhr :get, :new, :taxon_concept_id => taxon_concept.id
      assigns(:hybrid_relationship).should_not be_nil
    end
  end

  describe "XHR POST create" do
    it "renders create when successful" do
      xhr :post, :create,
        :taxon_concept_id => taxon_concept.id,
        :taxon_relationship => {
          other_taxon_concept_id: hybrid.id
        }
      response.should render_template("create")
    end
    it "renders new when not successful" do
      xhr :post, :create,
        :taxon_concept_id => taxon_concept.id,
        :taxon_relationship => {
          other_taxon_concept_id: nil
        }
      response.should render_template("new")
    end
  end

  describe "XHR GET edit" do
    it "renders the edit template" do
      xhr :get, :edit, :taxon_concept_id => taxon_concept.id,
        :id => hybrid_relationship.id
      response.should render_template('new')
    end
    it "assigns the hybrid_relationship variable" do
      xhr :get, :edit, :taxon_concept_id => taxon_concept.id,
        :id => hybrid_relationship.id
      assigns(:hybrid_relationship).should_not be_nil
    end
  end

  describe "XHR PUT update" do
    it "responds with 200 when successful" do
      xhr :put, :update, :format => 'js',
        :taxon_concept_id => taxon_concept.id,
        :id => hybrid_relationship.id,
        :taxon_relationship => {
          other_taxon_concept_id: hybrid.id
        }
      response.should render_template("create")
    end
    it "responds with json when not successful" do
      xhr :put, :update, :format => 'js',
        :taxon_concept_id => taxon_concept.id,
        :id => hybrid_relationship.id,
        :taxon_relationship => {
          other_taxon_concept_id: nil
        }
      response.should render_template('new')
    end
  end

  describe "DELETE destroy" do
    it "redirects after delete" do
      delete :destroy,
        :taxon_concept_id => taxon_concept.id,
        :id => hybrid_relationship.id
      response.should redirect_to(
        admin_taxon_concept_names_url(hybrid_relationship.taxon_concept)
      )
    end
  end

end
