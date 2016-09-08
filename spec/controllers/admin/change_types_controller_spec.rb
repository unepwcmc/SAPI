require 'spec_helper'

describe Admin::ChangeTypesController do
  login_admin

  describe "GET index" do
    it "assigns @change_types sorted by designation and name" do
      designation1 = create(:designation, :name => 'BB', :taxonomy => create(:taxonomy))
      designation2 = create(:designation, :name => 'AA', :taxonomy => create(:taxonomy))
      change_type2_1 = create(:change_type, :designation => designation2, :name => 'ADD')
      change_type2_2 = create(:change_type, :designation => designation2, :name => 'DEL')
      change_type1 = create(:change_type, :designation => designation1, :name => 'ADD')
      get :index
      assigns(:change_types).should eq([change_type1, change_type2_1, change_type2_2])
    end
    it "renders the index template" do
      get :index
      response.should render_template("index")
    end
  end

  describe "XHR POST create" do
    it "renders create when successful" do
      xhr :post, :create, change_type: build_attributes(:change_type)
      response.should render_template("create")
    end
    it "renders new when not successful" do
      xhr :post, :create, change_type: {}
      response.should render_template("new")
    end
  end

  describe "XHR PUT update" do
    let(:change_type) { create(:change_type) }
    it "responds with 200 when successful" do
      xhr :put, :update, :format => 'json', :id => change_type.id, :change_type => { :name => 'ZZ' }
      response.should be_success
    end
    it "responds with json when not successful" do
      xhr :put, :update, :format => 'json', :id => change_type.id, :change_type => { :name => nil }
      JSON.parse(response.body).should include('errors')
    end
  end

  describe "DELETE destroy" do
    let(:change_type) { create(:change_type) }
    it "redirects after delete" do
      delete :destroy, :id => change_type.id
      response.should redirect_to(admin_change_types_url)
    end
  end

end
