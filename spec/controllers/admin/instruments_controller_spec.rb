require 'spec_helper'

describe Admin::InstrumentsController do
  login_admin

  describe "GET index" do
    before(:each) do
      @instrument1 = create(:instrument, name: 'BB', designation: create(:designation))
      @instrument2 = create(:instrument, name: 'AA', designation: create(:designation))
    end
    describe "GET index" do
      it "assigns @instruments sorted by name" do
        get :index
        expect(assigns(:instruments)).to eq([@instrument2, @instrument1])
      end
      it "renders the index template" do
        get :index
        expect(response).to render_template("index")
      end
    end
    describe "XHR GET index JSON" do
      it "renders json for dropdown" do
        get :index, format: 'json', xhr: true
        expect(response.body).to have_json_size(2)
        expect(parse_json(response.body, "0/text")).to eq('AA')
      end
    end

  end

  describe "XHR POST create" do
    it "renders create when successful" do
      post :create, params: { instrument: build_attributes(:instrument) }, xhr: true
      expect(response).to render_template("create")
    end
    it "renders new when not successful" do
      post :create, params: { instrument: { dummy: 'test' } }, xhr: true
      expect(response).to render_template("new")
    end
  end

  describe "XHR PUT update" do
    let(:instrument) { create(:instrument) }
    it "responds with 200 when successful" do
      put :update, format: 'json', params: { id: instrument.id, instrument: { name: 'ZZ' } }, xhr: true
      expect(response).to be_successful
    end
    it "responds with json when not successful" do
      put :update, format: 'json', params: { id: instrument.id, instrument: { name: nil } }, xhr: true
      expect(JSON.parse(response.body)).to include('errors')
    end
  end

  describe "DELETE destroy" do
    let(:instrument) { create(:instrument) }
    it "redirects after delete" do
      delete :destroy, params: { id: instrument.id }
      expect(flash[:notice]).not_to be_nil
      expect(flash[:alert]).to be_nil
      expect(response).to redirect_to(admin_instruments_url)
    end
    let(:instrument2) { create(:instrument) }
    let!(:taxon_instrument) { create(:taxon_instrument, instrument_id: instrument2.id) }
    it "fails to delete instrument because there are dependent objects" do
      delete :destroy, params: { id: instrument2.id }
      expect(flash[:notice]).to be_nil
      expect(flash[:alert]).not_to be_nil
      expect(instrument2.reload).not_to be_nil
    end
  end

end
