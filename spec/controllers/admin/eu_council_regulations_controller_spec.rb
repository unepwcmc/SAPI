require 'spec_helper'

describe Admin::EuCouncilRegulationsController do
  login_admin

  describe "index" do
    before(:each) do
      @eu_regulation1 = create_eu_council_regulation(:name => 'BB')
      @eu_regulation2 = create_eu_council_regulation(:name => 'AA')
    end

    describe "GET index" do
      it "assigns @eu_regulations sorted by effective_at" do
        get :index
        assigns(:eu_council_regulations).should eq([@eu_regulation2, @eu_regulation1])
      end
      it "renders the index template" do
        get :index
        response.should render_template("index")
      end
    end
  end

end
