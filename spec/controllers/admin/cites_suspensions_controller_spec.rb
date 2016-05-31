require 'spec_helper'

describe Admin::CitesSuspensionsController do
  login_admin

  before do
    @taxon_concept = create(:taxon_concept)
  end

  describe "GET index" do
    it "renders the index template" do
      get :index
      response.should render_template("index")
    end
    it "assigns @cites_suspensions" do
      get :index
      assigns(:cites_suspensions)
    end
  end

  describe "GET new" do
    it "renders the new template" do
      get :new
      response.should render_template('new')
    end
    it "assigns @geo_entities (country and territory) with two objects" do
      geo_entity_type_t = create(:geo_entity_type, :name => "TERRITORY")
      territory = create(:geo_entity, :geo_entity_type_id => geo_entity_type_t.id)
      country = create(:geo_entity)
      get :new
      assigns(:geo_entities).size.should == 2
    end
  end

  describe "POST create" do
    context "when successful" do
      it "renders index" do
        post :create,
          :cites_suspension => {
            :start_notification_id => create_cites_suspension_notification.id
          }
        response.should redirect_to(
          admin_cites_suspensions_url
        )
      end
    end
    it "renders new when not successful" do
      post :create, :cites_suspension => {}
      response.should render_template("new")
    end
  end

  describe "GET edit" do
    before(:each) do
      @cites_suspension = create(
        :cites_suspension,
        :start_notification => create_cites_suspension_notification
      )
    end
    it "renders the edit template" do
      get :edit, :id => @cites_suspension.id
      response.should render_template('edit')
    end
    it "assigns @geo_entities (country and territory) with two objects" do
      geo_entity_type_t = create(:geo_entity_type, :name => "TERRITORY")
      territory = create(:geo_entity, :geo_entity_type_id => geo_entity_type_t.id)
      country = create(:geo_entity)
      get :new, :id => @cites_suspension.id
      assigns(:geo_entities).size.should == 2
    end
  end

  describe "PUT update" do
    before(:each) do
      @cites_suspension = create(
        :cites_suspension,
        :start_notification => create_cites_suspension_notification
      )
    end

    context "when successful" do
      it "redirects to taxon_concepts cites suspensions page" do
        put :update,
          :cites_suspension => {
            :publication_date => 1.week.ago
          },
          :id => @cites_suspension.id
        response.should redirect_to(
          admin_cites_suspensions_url
        )
      end
    end

    it "renders edit when not successful" do
      put :update,
        :cites_suspension => {
          :start_notification_id => nil
        },
        :id => @cites_suspension.id
      response.should render_template('edit')
    end
  end

  describe "DELETE destroy" do
    before(:each) do
      @cites_suspension = create(
        :cites_suspension,
        :start_notification => create_cites_suspension_notification
      )
    end
    it "redirects after delete" do
      delete :destroy, :id => @cites_suspension.id
      response.should redirect_to(
        admin_cites_suspensions_url
      )
    end
  end
end
