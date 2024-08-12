require 'spec_helper'

describe Admin::LanguagesController do
  login_admin

  describe "GET index" do
    it "assigns @languages sorted by iso_code1" do
      language1 = create(:language, iso_code1: 'BB', iso_code3: 'BBB')
      language2 = create(:language, iso_code1: 'AA', iso_code3: 'AAA')
      get :index
      expect(assigns(:languages)).to eq([language2, language1])
    end
    it "renders the index template" do
      get :index
      expect(response).to render_template("index")
    end
  end

  describe "XHR POST create" do
    it "renders create when successful" do
      post :create, params: { language: FactoryBot.attributes_for(:language) }, xhr: true
      expect(response).to render_template("create")
    end
    it "renders new when not successful" do
      post :create, params: { language: { dummy: 'test' } }, xhr: true
      expect(response).to render_template("new")
    end
  end

  describe "XHR PUT update" do
    let(:language) { create(:language) }
    it "responds with 200 when successful" do
      put :update, format: 'json', params: { id: language.id, language: { iso_code1: 'ZZ' } }, xhr: true
      expect(response).to be_successful
    end
    it "responds with json when not successful" do
      put :update, format: 'json', params: { id: language.id, language: { iso_code1: 'zzz' } }, xhr: true
      expect(JSON.parse(response.body)).to include('errors')
    end
  end

  describe "DELETE destroy" do
    let(:language) { create(:language) }
    it "redirects after delete" do
      delete :destroy, params: { id: language.id }
      expect(response).to redirect_to(admin_languages_url)
    end
  end

end
