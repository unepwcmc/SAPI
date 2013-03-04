require 'spec_helper'

describe Admin::TaxonConceptReferencesController do
  before do
    @taxon_concept = create(:taxon_concept)
    @reference = create(:reference)
  end

  describe "XHR GET 'new'" do
    it "returns http success and renders the new template" do
      xhr :get, :new, {:taxon_concept_id => @taxon_concept.id, :format => 'js'}
      response.should be_success
      response.should render_template('new')
    end
  end

  describe "DELETE destroy" do
    let(:taxon_concept_reference) { create(:taxon_concept_reference, :taxon_concept_id => @taxon_concept.id, :reference_id => @reference.id) }
    it "redirects after delete" do
      delete :destroy,
        :taxon_concept_id => @taxon_concept.id,
        :id => taxon_concept_reference.id
      response.should redirect_to(
        edit_admin_taxon_concept_url(taxon_concept_reference.taxon_concept)
      )
    end
  end
end
