require 'spec_helper'

describe Admin::UsersController do
  login_admin

  describe "index" do
    describe "GET index" do
      it "renders the index template" do
        get :index
        expect(response).to render_template("index")
      end
    end
  end

  describe "XHR POST create" do
    it "renders create when successful" do
      xhr :post, :create, user: FactoryGirl.attributes_for(:user)
      expect(response).to render_template("create")
    end
    it "renders new when not successful" do
      xhr :post, :create, user: { :name => nil }
      expect(response).to render_template("new")
    end
  end

  describe "XHR GET edit" do
    let(:user) { create(:user) }
    it "renders the edit template" do
      xhr :get, :edit, :id => user.id
      expect(response).to render_template('new')
    end
    it "assigns the hybrid_relationship variable" do
      xhr :get, :edit, :id => user.id
      expect(assigns(:user)).not_to be_nil
    end
  end

  describe "XHR PUT update JS" do
    let(:user) { create(:user) }
    it "responds with 200 when successful" do
      xhr :put, :update, :format => 'js', :id => user.id, :user => { :name => 'ZZ' }
      expect(response).to be_success
      expect(response).to render_template('create')
    end
    it "responds with template new when not successful" do
      xhr :put, :update, :format => 'js', :id => user.id, :user => { :name => nil }
      expect(response).to render_template('new')
    end
  end

  describe "DELETE destroy" do
    let(:user) { create(:user) }
    it "redirects after delete" do
      delete :destroy, :id => user.id
      expect(response).to redirect_to(admin_users_url)
    end
  end

end
