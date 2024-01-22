require 'spec_helper'

describe Admin::TaxonomiesController do
  login_admin

  describe "index" do
    before(:each) do
      @taxonomy1 = create(:taxonomy, :name => 'BB')
      @taxonomy2 = create(:taxonomy, :name => 'AA')
    end

    describe "GET index" do
      it "assigns @taxonomies sorted by name" do
        get :index
        expect(assigns(:taxonomies)).to eq([@taxonomy2, @taxonomy1])
      end
      it "renders the index template" do
        get :index
        expect(response).to render_template("index")
      end
    end
    describe "XHR GET index JSON" do
      it "renders json for dropdown" do
        xhr :get, :index, :format => 'json'
        expect(response.body).to have_json_size(2)
        expect(parse_json(response.body, "0/text")).to eq('AA')
      end
    end
  end

  describe "XHR POST create" do
    it "renders create when successful" do
      xhr :post, :create, taxonomy: FactoryGirl.attributes_for(:taxonomy)
      expect(response).to render_template("create")
    end
    it "renders new when not successful" do
      xhr :post, :create, taxonomy: { :name => nil }
      expect(response).to render_template("new")
    end
  end

  describe "XHR PUT update JSON" do
    let(:taxonomy) { create(:taxonomy) }
    it "responds with 200 when successful" do
      xhr :put, :update, :format => 'json', :id => taxonomy.id, :taxonomy => { :name => 'ZZ' }
      expect(response).to be_success
    end
    it "responds with json when not successful" do
      xhr :put, :update, :format => 'json', :id => taxonomy.id, :taxonomy => { :name => nil }
      expect(JSON.parse(response.body)).to include('errors')
    end
  end

  describe "DELETE destroy" do
    let(:taxonomy) { create(:taxonomy) }
    it "redirects after delete" do
      delete :destroy, params: { :id => taxonomy.id }
      expect(response).to redirect_to(admin_taxonomies_url)
    end
  end

  describe "Authorization for contributors" do
    login_contributor
    describe "GET index" do
      it "redirects to admin root" do
        get :index
        expect(response).to redirect_to admin_root_path
      end
    end
    describe "DELETE destroy" do
      let(:taxonomy) { create(:taxonomy) }
      it "fails to delete and redirects to admin_root_path" do
        delete :destroy, params: { :id => taxonomy.id }
        expect(response).to redirect_to(admin_root_path)
        expect(Taxonomy.find(taxonomy.id)).not_to be_nil
      end
    end
  end
end
