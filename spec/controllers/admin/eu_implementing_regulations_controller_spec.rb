require 'spec_helper'

describe Admin::EuImplementingRegulationsController do
  login_admin

  describe "index" do
    before(:each) do
      @eu_regulation1 = create_eu_implementing_regulation(:name => 'BB')
      @eu_regulation2 = create_eu_implementing_regulation(:name => 'AA')
    end

    describe "GET index" do
      it "assigns @eu_regulations sorted by effective_at" do
        get :index
        expect(assigns(:eu_implementing_regulations)).to eq([@eu_regulation2, @eu_regulation1])
      end
      it "renders the index template" do
        get :index
        expect(response).to render_template("index")
      end
    end
  end

end
