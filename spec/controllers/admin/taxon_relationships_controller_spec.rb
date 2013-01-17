describe Admin::TaxonRelationshipsController do
  describe "GET index" do
    it "assigns @taxon_relationships" do
      TaxonRelationship.delete_all
      taxon_relationship = create(:taxon_relationship)
      get :index
      assigns(:taxon_relationships).should eq([taxon_relationship])
    end
    it "renders the index template" do
      get :index
      response.should render_template("index")
    end
  end

  describe "XHR POST create" do
    it "renders create when successful" do
      xhr :post, :create, taxon_relationship: FactoryGirl.attributes_for(:taxon_relationship)
      response.should render_template("create")
    end
    it "renders new when not successful" do
      xhr :post, :create, taxon_relationship: {}
      response.should render_template("new")
    end
  end

end
