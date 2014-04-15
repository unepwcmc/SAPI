require 'spec_helper'

describe Admin::EuHashAnnotationsController do
  login_admin

  describe "index" do
    before(:each) do
      reg1 = create_eu_regulation(:name => 'Regulation1')
      reg2 = create_eu_regulation(:name => 'Regulation2')
      @annotation1 = create(
        :annotation,
        :parent_symbol => 'Reg2', :symbol => '#1', :event_id => reg2.id
      )
      @annotation2 = create(
        :annotation,
        :parent_symbol => 'Reg1', :symbol => '#1', :event_id => reg1.id
      )
    end

    describe "GET index" do
      it "assigns @annotations sorted by parent_symbol and symbol" do
        get :index
        assigns(:annotations).should eq([@annotation2, @annotation1])
      end
      it "renders the index template" do
        get :index
        response.should render_template("index")
      end
    end
  end

end
