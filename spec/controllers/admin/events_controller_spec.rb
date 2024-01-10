require 'spec_helper'

describe Admin::EventsController do
  login_admin

  describe "index" do
    before(:each) do
      @event1 = create(:event, :name => 'BB')
      @event2 = create(:event, :name => 'AA', :designation_id => @event1.designation_id)
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
  end

  describe "XHR GET new" do
    it "renders the new template" do
      xhr :get, :new
      response.should render_template('new')
    end
    it "assigns the event variable" do
      xhr :get, :new
      assigns(:event).should_not be_nil
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

  describe "XHR GET edit" do
    let(:event) { create(:event) }
    it "renders the edit template" do
      xhr :get, :edit, :id => event.id
      response.should render_template('new')
    end
    it "assigns the hybrid_relationship variable" do
      xhr :get, :edit, :id => event.id
      assigns(:event).should_not be_nil
    end
  end

  describe "XHR PUT update JSON" do
    let(:event) { create(:event) }
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
    let(:event) { create(:event) }
    it "redirects after delete" do
      delete :destroy, :id => event.id
      response.should redirect_to(admin_events_url)
    end
  end

end
