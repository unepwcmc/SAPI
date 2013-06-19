require 'spec_helper'
describe Admin::TaxonRelationshipsController do
  let!(:equal_relationship_type){
    create(
      :taxon_relationship_type,
      :name => TaxonRelationshipType::EQUAL_TO,
      :is_intertaxonomic => true,
      :is_bidirectional => true
    )
  }
  let(:taxon_concept){ create(:taxon_concept) }
  describe "GET index" do
    let(:taxon_relationship){
      create(:taxon_relationship, :taxon_concept_id => taxon_concept.id)
    }
    it "assigns @taxon_relationships" do
      get :index, :taxon_concept_id => taxon_concept.id, :type => taxon_relationship.taxon_relationship_type.name
      assigns(:taxon_relationships).should eq([taxon_relationship])
      assigns(:taxon_concept)
    end
    it "renders the index template" do
      get :index, :taxon_concept_id => taxon_concept.id
      response.should render_template("index")
    end
    it "renders the taxon_concepts_layout" do
      get :index, :taxon_concept_id => taxon_concept.id
      response.should render_template('layouts/taxon_concepts')
    end
  end

  describe "XHR POST create" do
    let(:taxon_relationship_attributes){ build_attributes(:taxon_relationship) }
    before do
      TaxonRelationshipType.stub(:find).and_return(equal_relationship_type)
    end
    it "renders create when successful" do
      xhr :post, :create, :taxon_relationship => taxon_relationship_attributes,
        :taxon_concept_id => taxon_concept.id
      response.should render_template("create")
    end
    it "renders new when not successful" do
      taxon_relationship = create(:taxon_relationship, taxon_relationship_attributes)
      xhr :post, :create, taxon_relationship: taxon_relationship_attributes,
        :taxon_concept_id => taxon_relationship.taxon_concept_id
      response.should render_template("new")
    end
  end

end
