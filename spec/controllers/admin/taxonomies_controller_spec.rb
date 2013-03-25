require 'spec_helper'
describe Admin::TaxonomiesController do

  describe "index" do
    before(:each) do
      @taxonomy1 = create(:taxonomy, :name => 'BB')
      @taxonomy2 = create(:taxonomy, :name => 'AA')
    end

    describe "GET index" do
      it "assigns @taxonomies sorted by name" do
        get :index
        assigns(:taxonomies).should eq([@taxonomy2, @taxonomy1])
      end
      it "renders the index template" do
        get :index
        response.should render_template("index")
      end
    end
    describe "XHR GET index JSON" do
      it "renders json for dropdown" do
        xhr :get, :index, :format => 'json'
        response.body.should have_json_size(2)
        parse_json(response.body, "0/text").should == 'AA'
      end
    end
  end

  describe "XHR POST create" do
    it "renders create when successful" do
      xhr :post, :create, taxonomy: FactoryGirl.attributes_for(:taxonomy)
      response.should render_template("create")
    end
    it "renders new when not successful" do
      xhr :post, :create, taxonomy: { :name => nil }
      response.should render_template("new")
    end
  end

  describe "XHR PUT update JSON" do
    let(:taxonomy){ create(:taxonomy) }
    it "responds with 200 when successful" do
      xhr :put, :update, :format => 'json', :id => taxonomy.id, :taxonomy => { :name => 'ZZ' }
      response.should be_success
    end
    it "responds with json when not successful" do
      xhr :put, :update, :format => 'json', :id => taxonomy.id, :taxonomy => { :name => nil }
      JSON.parse(response.body).should include('errors')
    end
  end

  describe "DELETE destroy" do
    let(:taxonomy){ create(:taxonomy) }
    it "redirects after delete" do
      delete :destroy, :id => taxonomy.id
      response.should redirect_to(admin_taxonomies_url)
    end
  end

end
