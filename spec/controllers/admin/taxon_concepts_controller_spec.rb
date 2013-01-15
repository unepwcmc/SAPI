describe Admin::TaxonConceptsController do
  describe "GET index" do
    it "renders the index template" do
      get :index
      response.should render_template("index")
    end
  end

  describe "XHR POST create" do
    let(:taxon_concept){ build(:taxon_concept) }
    it "renders create when successful" do
      xhr :post, :create,
        taxon_concept: taxon_concept.attributes.except(
          'id', 'data', 'listing', 'created_at', 'updated_at',
          'notes', 'full_name', 'lft', 'rgt'
        )
      response.should render_template("create")
    end
    it "renders new when not successful" do
      xhr :post, :create, taxon_concept: {}
      response.should render_template("new")
    end
  end

  describe "XHR PUT update" do
    let(:taxon_concept){ create(:taxon_concept) }
    context "when JSON" do
      it "responds with 200 when successful" do
        xhr :put, :update, :format => 'json', :id => taxon_concept.id,
          :taxon_concept => { }
        response.should be_success
      end
      it "responds with json error when not successful" do
        xhr :put, :update, :format => 'json', :id => taxon_concept.id,
          :taxon_concept => { :designation_id => nil }
        JSON.parse(response.body).should include('errors')
      end
    end
    context "when HTML" do
      it "redirects to edit when successful" do
        put :update, :id => taxon_concept.id,
          :taxon_commons_attributes => FactoryGirl.attributes_for(:common_name)
        response.should redirect_to(edit_admin_taxon_concept_url(taxon_concept))
      end
      it "renders edit when not successful" do
        put :update, :id => taxon_concept.id,
          :taxon_concept => { :designation_id => nil }
        response.should render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    let(:taxon_concept){ create(:taxon_concept) }
    it "redirects after delete" do
      delete :destroy, :id => taxon_concept.id
      response.should redirect_to(admin_taxon_concepts_url)
    end
  end

end
