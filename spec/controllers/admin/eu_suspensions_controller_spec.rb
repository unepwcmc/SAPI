require 'spec_helper'

describe Admin::EuSuspensionsController do
  login_admin

  before do
    @taxon_concept = create(:taxon_concept)
    @designation = create(:designation, :name => "EU", :taxonomy => @taxon_concept.taxonomy)
    @eu_suspension_regulation = create(:eu_suspension_regulation, :designation_id => @designation.id, :is_current => true)
  end

  describe "GET index" do
    it "renders the index template" do
      get :index, :eu_suspension_regulation_id => @eu_suspension_regulation
      response.should render_template("index")
    end
    it "renders the admin layout" do
      get :index, :eu_suspension_regulation_id => @eu_suspension_regulation
      response.should render_template('layouts/admin')
    end
  end

  describe "DELETE destroy" do
    before(:each) do
      @eu_suspension = create(
        :eu_suspension,
        :taxon_concept_id => @taxon_concept.id,
        :start_event_id => @eu_suspension_regulation.id
      )
    end
    it "redirects after delete" do
      delete :destroy, :id => @eu_suspension.id,
        :eu_suspension_regulation_id => @eu_suspension_regulation.id
      response.should redirect_to(
        admin_eu_suspension_regulation_eu_suspensions_url(@eu_suspension_regulation)
      )
    end
  end
end
