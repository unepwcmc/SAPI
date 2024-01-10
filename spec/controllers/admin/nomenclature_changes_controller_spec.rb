require 'spec_helper'

describe Admin::NomenclatureChangesController do
  login_admin

  describe "GET index" do
    it "assigns @nomenclature_changes sorted by designation and name" do
      nomenclature_change1 = create(:nomenclature_change)
      nomenclature_change2 = create(:nomenclature_change)
      get :index
      assigns(:collection).should eq([nomenclature_change2, nomenclature_change1])
    end
    it "renders the index template" do
      get :index
      response.should render_template("index")
    end
  end

  describe "DELETE destroy" do
    let(:nomenclature_change) { create(:nomenclature_change) }
    it "redirects after delete" do
      delete :destroy, :id => nomenclature_change.id
      response.should redirect_to(admin_nomenclature_changes_url)
    end
  end

end
