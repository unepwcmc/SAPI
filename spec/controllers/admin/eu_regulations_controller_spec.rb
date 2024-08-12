require 'spec_helper'

describe Admin::EuRegulationsController do
  login_admin

  describe "index" do
    before(:each) do
      @eu_regulation1 = create_eu_regulation(name: 'BB')
      @eu_regulation2 = create_eu_regulation(name: 'AA')
    end

    describe "GET index" do
      it "assigns @eu_regulations sorted by effective_at" do
        get :index
        expect(assigns(:eu_regulations)).to eq([@eu_regulation2, @eu_regulation1])
      end
      it "renders the index template" do
        get :index
        expect(response).to render_template("index")
      end
    end
  end

  describe "XHR POST activate" do
    let(:eu_regulation) { create_eu_regulation }
    it "renders create when successful" do
      post :activate, format: 'js', params: { id: eu_regulation.id }, xhr: true
      expect(response).to render_template("create")
    end
  end

end
