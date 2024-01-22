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
        expect(assigns(:events)).to eq([@event2, @event1])
      end
      it "renders the index template" do
        get :index
        expect(response).to render_template("index")
      end
    end
  end

  describe "XHR GET new" do
    it "renders the new template" do
      get :new, xhr: true
      expect(response).to render_template('new')
    end
    it "assigns the event variable" do
      get :new, xhr: true
      expect(assigns(:event)).not_to be_nil
    end
  end

  describe "XHR POST create" do
    it "renders create when successful" do
      post :create, params: { event: FactoryGirl.attributes_for(:event) }, xhr: true
      expect(response).to render_template("create")
    end
    it "renders new when not successful" do
      post :create, params: { event: { :name => nil } }, xhr: true
      expect(response).to render_template("new")
    end
  end

  describe "XHR GET edit" do
    let(:event) { create(:event) }
    it "renders the edit template" do
      get :edit, params: { :id => event.id }, xhr: true
      expect(response).to render_template('new')
    end
    it "assigns the hybrid_relationship variable" do
      get :edit, params: { :id => event.id }, xhr: true
      expect(assigns(:event)).not_to be_nil
    end
  end

  describe "XHR PUT update JSON" do
    let(:event) { create(:event) }
    it "responds with 200 when successful" do
      put :update, :format => 'json', params: { :id => event.id, :event => { :name => 'ZZ' } }, xhr: true
      expect(response).to be_success
    end
    it "responds with json when not successful" do
      put :update, :format => 'json', params: { :id => event.id, :event => { :name => nil } }, xhr: true
      expect(JSON.parse(response.body)).to include('errors')
    end
  end

  describe "DELETE destroy" do
    let(:event) { create(:event) }
    it "redirects after delete" do
      delete :destroy, params: { :id => event.id }
      expect(response).to redirect_to(admin_events_url)
    end
  end

end
