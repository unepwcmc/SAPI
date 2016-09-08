require 'spec_helper'

describe Admin::InstrumentsController do
  login_admin

  describe "GET index" do
    before(:each) do
      @instrument1 = create(:instrument, :name => 'BB', :designation => create(:designation))
      @instrument2 = create(:instrument, :name => 'AA', :designation => create(:designation))
    end
    describe "GET index" do
      it "assigns @instruments sorted by name" do
        get :index
        assigns(:instruments).should eq([@instrument2, @instrument1])
      end
      it "renders the index template" do
        get :index
        response.should render_template("index")
      end
    end
    describe "XHR GET index JSON" do
      it "renders json for dropdown" do
        xhr :get, :index, :format => 'json'
        response.body.should have_json_size(2)
        parse_json(response.body, "0/text").should == 'AA'
      end
    end

  end

  describe "XHR POST create" do
    it "renders create when successful" do
      xhr :post, :create, instrument: build_attributes(:instrument)
      response.should render_template("create")
    end
    it "renders new when not successful" do
      xhr :post, :create, instrument: {}
      response.should render_template("new")
    end
  end

  describe "XHR PUT update" do
    let(:instrument) { create(:instrument) }
    it "responds with 200 when successful" do
      xhr :put, :update, :format => 'json', :id => instrument.id, :instrument => { :name => 'ZZ' }
      response.should be_success
    end
    it "responds with json when not successful" do
      xhr :put, :update, :format => 'json', :id => instrument.id, :instrument => { :name => nil }
      JSON.parse(response.body).should include('errors')
    end
  end

  describe "DELETE destroy" do
    let(:instrument) { create(:instrument) }
    it "redirects after delete" do
      delete :destroy, :id => instrument.id
      flash[:notice].should_not be_nil
      flash[:alert].should be_nil
      response.should redirect_to(admin_instruments_url)
    end
    let(:instrument2) { create(:instrument) }
    let!(:taxon_instrument) { create(:taxon_instrument, :instrument_id => instrument2.id) }
    it "fails to delete instrument because there are dependent objects" do
      delete :destroy, :id => instrument2.id
      flash[:notice].should be_nil
      flash[:alert].should_not be_nil
      instrument2.reload.should_not be_nil
    end
  end

end
