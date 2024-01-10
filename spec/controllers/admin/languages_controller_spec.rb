require 'spec_helper'

describe Admin::LanguagesController do
  login_admin

  describe "GET index" do
    it "assigns @languages sorted by iso_code1" do
      language1 = create(:language, :iso_code1 => 'BB', :iso_code3 => 'BBB')
      language2 = create(:language, :iso_code1 => 'AA', :iso_code3 => 'AAA')
      get :index
      assigns(:languages).should eq([language2, language1])
    end
    it "renders the index template" do
      get :index
      response.should render_template("index")
    end
  end

  describe "XHR POST create" do
    it "renders create when successful" do
      xhr :post, :create, language: FactoryGirl.attributes_for(:language)
      response.should render_template("create")
    end
    it "renders new when not successful" do
      xhr :post, :create, language: {}
      response.should render_template("new")
    end
  end

  describe "XHR PUT update" do
    let(:language) { create(:language) }
    it "responds with 200 when successful" do
      xhr :put, :update, :format => 'json', :id => language.id, :language => { :iso_code1 => 'ZZ' }
      response.should be_success
    end
    it "responds with json when not successful" do
      xhr :put, :update, :format => 'json', :id => language.id, :language => { :iso_code1 => 'zzz' }
      JSON.parse(response.body).should include('errors')
    end
  end

  describe "DELETE destroy" do
    let(:language) { create(:language) }
    it "redirects after delete" do
      delete :destroy, :id => language.id
      response.should redirect_to(admin_languages_url)
    end
  end

end
