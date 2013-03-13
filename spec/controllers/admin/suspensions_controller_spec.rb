require 'spec_helper'

describe Admin::SuspensionsController do
  before do
    @taxon_concept = create(:taxon_concept)
  end

  describe "GET index" do
    it "renders the index template" do
      get :index
      response.should render_template("index")
    end
    it "assigns @suspensions" do
      get :index
      assigns(:suspensions)
    end
  end

  describe "GET new" do
    it "renders the new template" do
      get :new
      response.should render_template('new')
    end
  end

  describe "POST create" do
    context "when successful" do
      it "renders index" do
        post :create, :suspension => {
            :publication_date => "22/03/2013",
            :is_current => 1
          }
        response.should redirect_to(
          admin_suspensions_url
        )
      end
    end
    it "renders new when not successful" do
      post :create, :suspension => {}
      response.should render_template("new")
    end
  end

  describe "GET edit" do
    before(:each) do
      @suspension = create( :suspension)
    end
    it "renders the edit template" do
      get :edit, :id => @suspension.id
      response.should render_template('edit')
    end
  end

  describe "PUT update" do
    before(:each) do
      @suspension = create(:suspension)
    end

    context "when successful" do
      it "renders taxon_concepts suspensions page" do
        put :update, :suspension => {
            :publication_date => 1.week.ago
          },
          :id => @suspension.id
        response.should redirect_to(
          admin_suspensions_url
        )
      end
    end

    it "renders new when not successful" do
      put :update, :suspension => {
          :publication_date => nil
        },
        :id => @suspension.id
      response.should render_template('new')
    end
  end

  describe "DELETE destroy" do
    before(:each) do
      @suspension = create(:suspension)
    end
    it "redirects after delete" do
      delete :destroy, :id => @suspension.id
      response.should redirect_to(
        admin_suspensions_url
      )
    end
  end
end
