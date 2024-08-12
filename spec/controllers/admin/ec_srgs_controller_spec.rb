require 'spec_helper'

describe Admin::EcSrgsController do
  login_admin

  describe "index" do
    before(:each) do
      @cites_srg1 = create_ec_srg(name: 'S1')
      @cites_srg2 = create_ec_srg(name: 'S2')
    end

    describe "GET index" do
      it "assigns @ec_srgs sorted by name" do
        get :index
        expect(assigns(:ec_srgs).sort).to eq([@cites_srg1, @cites_srg2].sort)
      end
      it "renders the index template" do
        get :index
        expect(response).to render_template("index")
      end
    end
  end

end
