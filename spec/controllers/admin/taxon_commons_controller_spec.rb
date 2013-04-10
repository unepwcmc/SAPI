require 'spec_helper'

describe Admin::TaxonCommonsController do
  before do
    @taxon_concept = create(:taxon_concept)
    @common_name = create(:common_name)
  end

  describe "XHR GET 'new'" do
    it "returns http success and renders the new template" do
      xhr :get, :new, {:taxon_concept_id => @taxon_concept.id, :format => 'js'}
      response.should be_success
      response.should render_template('new')
    end
  end

  describe "DELETE destroy" do
    let(:taxon_common) {
      create(
        :taxon_common,
        :taxon_concept_id => @taxon_concept.id,
        :common_name_id => @common_name.id
      )
    }
    it "redirects after delete" do
      delete :destroy,
        :taxon_concept_id => @taxon_concept.id,
        :id => taxon_common.id
      response.should redirect_to(
        edit_admin_taxon_concept_url(@taxon_concept)
      )
    end
  end
end
