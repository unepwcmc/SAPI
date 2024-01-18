require 'spec_helper'

describe Admin::EuSuspensionRegulationsController do
  login_admin

  describe "index" do
    before(:each) do
      @eu_suspension_regulation1 = create_eu_suspension_regulation(:name => 'BB', :is_current => true)
      @eu_suspension_regulation2 = create_eu_suspension_regulation(:name => 'AA', :is_current => true)
    end

    describe "GET index" do
      it "assigns @eu_suspension_regulations sorted by effective_at" do
        get :index
        expect(assigns(:eu_suspension_regulations)).to eq([@eu_suspension_regulation2, @eu_suspension_regulation1])
      end
      it "renders the index template" do
        get :index
        expect(response).to render_template("index")
      end
    end
  end

  describe "XHR POST activate" do
    let(:eu_suspension_regulation) { create_eu_suspension_regulation(:is_current => true) }
    it "renders create when successful" do
      xhr :post, :activate, :format => 'js', :id => eu_suspension_regulation.id
      expect(response).to render_template("create")
    end
  end

end
