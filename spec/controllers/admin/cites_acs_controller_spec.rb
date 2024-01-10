require 'spec_helper'

describe Admin::CitesAcsController do
  login_admin

  describe "index" do
    before(:each) do
      @cites_ac1 = create_cites_ac(:name => 'Ac1')
      @cites_ac2 = create_cites_ac(:name => 'Ac2')
    end

    describe "GET index" do
      it "assigns @cites_acs sorted by name" do
        get :index
        assigns(:cites_acs).should eq([@cites_ac1, @cites_ac2])
      end
      it "renders the index template" do
        get :index
        response.should render_template("index")
      end
    end
  end

end
