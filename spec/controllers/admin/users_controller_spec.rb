require 'spec_helper'

describe Admin::UsersController do
  login_admin

  describe "index" do
    describe "GET index" do
      it "renders the index template" do
        get :index
        response.should render_template("index")
      end
    end
  end

  describe "XHR POST create" do
    it "renders create when successful" do
      xhr :post, :create, user: FactoryGirl.attributes_for(:user)
      response.should render_template("create")
    end
    it "renders new when not successful" do
      xhr :post, :create, user: { :name => nil }
      response.should render_template("new")
    end
  end

  describe "XHR GET edit" do
    let(:user) { create(:user) }
    it "renders the edit template" do
      xhr :get, :edit, :id => user.id
      response.should render_template('new')
    end
    it "assigns the hybrid_relationship variable" do
      xhr :get, :edit, :id => user.id
      assigns(:user).should_not be_nil
    end
  end

  describe "XHR PUT update JS" do
    let(:user) { create(:user) }
    it "responds with 200 when successful" do
      xhr :put, :update, :format => 'js', :id => user.id, :user => { :name => 'ZZ' }
      response.should be_success
      response.should render_template('create')
    end
    it "responds with template new when not successful" do
      xhr :put, :update, :format => 'js', :id => user.id, :user => { :name => nil }
      response.should render_template('new')
    end
  end

  describe "DELETE destroy" do
    let(:user) { create(:user) }
    it "redirects after delete" do
      delete :destroy, :id => user.id
      response.should redirect_to(admin_users_url)
    end
  end

end
