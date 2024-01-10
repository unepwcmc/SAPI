require 'spec_helper'

describe Admin::CitesPcsController do
  login_admin

  describe "index" do
    before(:each) do
      @cites_pc1 = create_cites_pc(:name => 'Pc1')
      @cites_pc2 = create_cites_pc(:name => 'Pc2')
    end

    describe "GET index" do
      it "assigns @cites_pcs sorted by name" do
        get :index
        assigns(:cites_pcs).should eq([@cites_pc1, @cites_pc2])
      end
      it "renders the index template" do
        get :index
        response.should render_template("index")
      end
    end
  end

end
