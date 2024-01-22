require 'spec_helper'

describe Admin::ReferencesController do
  login_admin

  describe "index" do
    before(:each) do
      @reference1 = create(:reference, :citation => 'BB')
      @reference2 = create(:reference, :citation => 'AA')
    end

    describe "GET index" do
      it "assigns @references sorted by citation" do
        get :index
        expect(assigns(:references)).to eq([@reference2, @reference1])
      end
      it "renders the index template" do
        get :index
        expect(response).to render_template("index")
      end
    end
    describe "XHR GET index JSON" do
      it "renders json for dropdown" do
        get :index, :format => 'json', xhr: true
        expect(response.body).to have_json_size(2)
        expect(parse_json(response.body, "0/text")).to eq('AA')
      end
    end
  end

  describe "XHR POST create" do
    it "renders create when successful" do
      post :create, params: { reference: FactoryBot.attributes_for(:reference) }, xhr: true
      expect(response).to render_template("create")
    end
    it "renders new when not successful" do
      post :create, params: { reference: { :citation => nil } }, xhr: true
      expect(response).to render_template("new")
    end
  end

  describe "XHR PUT update JSON" do
    let(:reference) { create(:reference) }
    it "responds with 200 when successful" do
      put :update, :format => 'json', params: { :id => reference.id, :reference => { :citation => 'ZZ' } }, xhr: true
      expect(response).to be_success
    end
    it "responds with json when not successful" do
      put :update, :format => 'json', params: { :id => reference.id, :reference => { :citation => nil } }, xhr: true
      expect(JSON.parse(response.body)).to include('errors')
    end
  end

  describe "DELETE destroy" do
    let(:reference) { create(:reference) }
    it "redirects after delete" do
      delete :destroy, params: { :id => reference.id }
      expect(response).to redirect_to(admin_references_url)
    end
  end

end
