require 'spec_helper'

describe Admin::TagsController do
  login_admin

  describe "GET index" do
    it "renders the index template" do
      get :index
      response.should render_template("index")
      response.should render_template("layouts/admin")
    end
  end

  describe "XHR POST create" do
    it "renders create when successful" do
      xhr :post, :create,
        preset_tag: { name: "Test Tag", model: "TaxonConcept" }
      response.should render_template("create")
    end
    it "renders new when not successful" do
      xhr :post, :create, preset_tag: {}
      response.should render_template("new")
    end
  end

  describe "XHR PUT update" do
    let(:preset_tag) { create(:preset_tag) }
    context "when JSON" do
      it "responds with 200 when successful" do
        xhr :put, :update, :format => 'json', :id => preset_tag.id,
          :preset_tag => {}
        response.should be_success
      end
      it "responds with json error when not successful" do
        xhr :put, :update, :format => 'json', :id => preset_tag.id,
          :preset_tag => { :model => 'FakeCategory' }
        JSON.parse(response.body).should include('errors')
      end
    end
  end

  describe "DELETE destroy" do
    let(:preset_tag) { create(:preset_tag) }
    it "redirects after delete" do
      delete :destroy, :id => preset_tag.id
      response.should redirect_to(admin_tags_url)
    end
  end
end
