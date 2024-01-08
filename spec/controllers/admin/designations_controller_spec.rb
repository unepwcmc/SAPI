require 'spec_helper'

describe Admin::DesignationsController do
  login_admin

  describe "GET index" do
    before(:each) do
      @designation1 = create(:designation, :name => 'BB', :taxonomy => create(:taxonomy))
      @designation2 = create(:designation, :name => 'AA', :taxonomy => create(:taxonomy))
    end
    describe "GET index" do
      it "assigns @designations sorted by name" do
        get :index
        expect(assigns(:designations)).to eq([@designation2, @designation1])
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
      xhr :post, :create, designation: build_attributes(:designation)
      expect(response).to render_template("create")
    end
    it "renders new when not successful" do
      xhr :post, :create, designation: {}
      expect(response).to render_template("new")
    end
  end

  describe "XHR PUT update" do
    let(:designation) { create(:designation) }
    it "responds with 200 when successful" do
      xhr :put, :update, :format => 'json', :id => designation.id, :designation => { :name => 'ZZ' }
      expect(response).to be_success
    end
    it "responds with json when not successful" do
      xhr :put, :update, :format => 'json', :id => designation.id, :designation => { :name => nil }
      expect(JSON.parse(response.body)).to include('errors')
    end
  end

  describe "DELETE destroy" do
    let(:designation) { create(:designation) }
    it "redirects after delete" do
      delete :destroy, :id => designation.id
      expect(response).to redirect_to(admin_designations_url)
    end
  end

end
