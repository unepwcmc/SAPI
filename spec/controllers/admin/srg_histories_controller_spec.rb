require 'spec_helper'

describe Admin::SrgHistoriesController do
  login_admin

  describe "GET index" do
    it "renders the index template" do
      get :index
      response.should render_template("index")
    end
  end

  describe "POST create" do
    context "when successful" do
      before do
        @srg_history = create(:srg_history)
      end

      it "renders the create js template" do
        post :create, srg_history: { name: 'test' }, format: :js

        response.should render_template("create")
      end
    end

    context "when not successful" do
      it "renders new" do
        post :create, srg_history: {}, format: :js

        response.should render_template("new")
      end
    end
  end

  describe "PUT update" do
    before(:each) do
      @srg_history = create(:srg_history)
    end

    context "when successful" do
      it "renders the create js template" do
        put :update, id: @srg_history.id, format: :js

        response.should render_template("create")
      end
    end

    context "when not successful" do
      it "renders new" do
        put :update,
          srg_history: { name: nil },
          id: @srg_history.id,
          format: :js

        response.should render_template('new')
      end
    end
  end

  describe "DELETE destroy" do
    before(:each) do
      @srg_history = create(:srg_history)
    end

    it "redirects after delete" do
      delete :destroy, id: @srg_history.id

      response.should redirect_to(admin_srg_histories_url)
    end
  end
end
