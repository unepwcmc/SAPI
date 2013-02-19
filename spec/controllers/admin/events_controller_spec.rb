require 'spec_helper'
describe Admin::EventsController do

  describe "index" do
    before(:each) do
      @event1 = create(:event, :name => 'BB')
      @event2 = create(:event, :name => 'AA')
    end

    describe "GET index" do
      it "assigns @events sorted by name" do
        get :index
        assigns(:events).should eq([@event2, @event1])
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
      xhr :post, :create, event: FactoryGirl.attributes_for(:event)
      response.should render_template("create")
    end
    it "renders new when not successful" do
      xhr :post, :create, event: { :name => nil }
      response.should render_template("new")
    end
  end

  describe "XHR PUT update JSON" do
    let(:event){ create(:event) }
    it "responds with 200 when successful" do
      xhr :put, :update, :format => 'json', :id => event.id, :event => { :name => 'ZZ' }
      response.should be_success
    end
    it "responds with json when not successful" do
      xhr :put, :update, :format => 'json', :id => event.id, :event => { :name => nil }
      JSON.parse(response.body).should include('errors')
    end
  end

  describe "DELETE destroy" do
    let(:event){ create(:event) }
    it "redirects after delete" do
      delete :destroy, :id => event.id
      response.should redirect_to(admin_events_url)
    end
  end

end
