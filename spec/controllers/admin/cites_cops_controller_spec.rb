require 'spec_helper'
describe Admin::CitesCopsController do

  describe "index" do
    before(:each) do
      @cites_cop1 = create(:cites_cop, :name => 'CoP2')
      @cites_cop2 = create(:cites_cop, :name => 'CoP1')
    end

    describe "GET index" do
      it "assigns @cites_cops sorted by effective_at" do
        get :index
        assigns(:cites_cops).should eq([@cites_cop2, @cites_cop1])
      end
      it "renders the index template" do
        get :index
        response.should render_template("index")
      end
    end
  end

end
