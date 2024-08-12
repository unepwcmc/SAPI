require 'spec_helper'

describe Admin::TagsController do
  login_admin

  describe "GET index" do
    it "renders the index template" do
      get :index
      expect(response).to render_template("index")
      expect(response).to render_template("layouts/admin")
    end
  end

  describe "XHR POST create" do
    it "renders create when successful" do
      post :create, params: { tag: { name: "Test Tag", model: "TaxonConcept" } }, xhr: true
      expect(response).to render_template("create")
    end
    it "renders new when not successful" do
      post :create, params: { tag: { dummy: 'test' } }, xhr: true
      expect(response).to render_template("new")
    end
  end

  describe "XHR PUT update" do
    let(:preset_tag) { create(:preset_tag) }
    context "when JSON" do
      it "responds with 200 when successful" do
        put :update, format: 'json', params: { id: preset_tag.id, tag: { dummy: 'test' } }, xhr: true
        expect(response).to be_successful
      end
      it "responds with json error when not successful" do
        put :update, format: 'json', params: { id: preset_tag.id, tag: { model: 'FakeCategory' } }, xhr: true
        expect(JSON.parse(response.body)).to include('errors')
      end
    end
  end

  describe "DELETE destroy" do
    let(:preset_tag) { create(:preset_tag) }
    it "redirects after delete" do
      delete :destroy, params: { id: preset_tag.id }
      expect(response).to redirect_to(admin_tags_url)
    end
  end
end
