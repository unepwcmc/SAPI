require 'spec_helper'
describe Admin::TaxonRelationshipsController do
  before do
    @taxon_concept = create(:taxon_concept)
  end
  describe "GET index" do
    it "assigns @taxon_relationships" do
      TaxonRelationship.delete_all
      taxon_relationship = create(:taxon_relationship, :taxon_concept_id => @taxon_concept.id)
      get :index, :taxon_concept_id => @taxon_concept.id, :type => taxon_relationship.taxon_relationship_type.name
      assigns(:taxon_relationships).should eq([taxon_relationship])
      assigns(:taxon_concept)
    end
    it "renders the index template" do
      get :index, :taxon_concept_id => @taxon_concept.id
      response.should render_template("index")
    end
  end

  describe "XHR POST create" do
    before do
      @taxon_relationship_type = create(:taxon_relationship_type)
      TaxonRelationshipType.stub(:find).and_return(@taxon_relationship_type)
    end
    it "renders create when successful" do
      xhr :post, :create, taxon_relationship: build_attributes(:taxon_relationship), :taxon_concept_id => @taxon_concept.id
      response.should render_template("create")
    end
    it "renders new when not successful" do
      taxon_relationship_attributes = build_attributes(:taxon_relationship)
      taxon_relationship = create(:taxon_relationship, taxon_relationship_attributes)
      xhr :post, :create, taxon_relationship: taxon_relationship_attributes, :taxon_concept_id => taxon_relationship.taxon_concept_id
      response.should render_template("new")
    end
  end

end
