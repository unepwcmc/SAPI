require 'spec_helper'

describe Admin::TaxonCitesSuspensionsController do
  login_admin

  before do
    @taxon_concept = create(:taxon_concept)
    @cites_suspension = create(
      :cites_suspension,
      :taxon_concept => @taxon_concept,
      :start_notification => create_cites_suspension_notification
    )
  end

  describe "GET index" do
    it "renders the index template" do
      get :index, :taxon_concept_id => @taxon_concept.id
      response.should render_template("index")
    end
    it "renders the taxon_concepts_layout" do
      get :index, :taxon_concept_id => @taxon_concept.id
      response.should render_template('layouts/taxon_concepts')
    end
  end

  describe "GET new" do
    it "renders the new template" do
      get :new, :taxon_concept_id => @taxon_concept.id
      response.should render_template('new')
    end
  end

  describe "POST create" do
    context "when successful" do
      it "renders index" do
        post :create,
          :cites_suspension => {
            :start_notification_id => create_cites_suspension_notification.id
          },
          :taxon_concept_id => @taxon_concept.id
        response.should redirect_to(
          admin_taxon_concept_cites_suspensions_url(@taxon_concept)
        )
      end
    end
    it "renders new when not successful" do
      post :create, :cites_suspension => {},
        :taxon_concept_id => @taxon_concept.id
      response.should render_template('new')
    end
  end

  describe "GET edit" do
    it "renders the edit template" do
      get :edit, :id => @cites_suspension.id, :taxon_concept_id => @taxon_concept.id
      response.should render_template('edit')
    end
  end

  describe "PUT update" do
    context "when successful" do
      it "renders taxon_concepts cites suspensions page" do
        put :update,
          :cites_suspension => {
            :publication_date => 1.week.ago
          },
          :id => @cites_suspension.id,
          :taxon_concept_id => @taxon_concept.id
        response.should redirect_to(
          admin_taxon_concept_cites_suspensions_url(@taxon_concept)
        )
      end
    end

    it "renders edit when not successful" do
      put :update,
        :cites_suspension => {
          :start_notification_id => nil
        },
        :id => @cites_suspension.id,
        :taxon_concept_id => @taxon_concept.id
      response.should render_template('edit')
    end
  end

  describe "DELETE destroy" do
    it "redirects after delete" do
      delete :destroy, :id => @cites_suspension.id,
        :taxon_concept_id => @taxon_concept.id
      response.should redirect_to(
        admin_taxon_concept_cites_suspensions_url(@taxon_concept)
      )
    end
  end

  describe "Authorization for contributors" do
    login_contributor

    describe "GET index" do
      it "renders the index template" do
        get :index, :taxon_concept_id => @taxon_concept.id
        response.should render_template("index")
      end
      it "renders the taxon_concepts_layout" do
        get :index, :taxon_concept_id => @taxon_concept.id
        response.should render_template('layouts/taxon_concepts')
      end
    end
    describe "DELETE destroy" do
      it "fails to delete and redirects" do
        @request.env['HTTP_REFERER'] = admin_taxon_concept_cites_suspensions_url(@taxon_concept)
        delete :destroy, :id => @cites_suspension.id,
          :taxon_concept_id => @taxon_concept.id
        response.should redirect_to(
          admin_taxon_concept_cites_suspensions_url(@taxon_concept)
        )
        CitesSuspension.find(@cites_suspension.id).should_not be_nil
      end
    end
  end
end
