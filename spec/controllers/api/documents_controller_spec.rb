require 'spec_helper'

describe Api::V1::DocumentsController, :type => :controller do
  context "GET index" do
    before(:each) do
      @taxon_concept = create(:taxon_concept)
      document = create(:proposal, event: create(:cites_cop, designation: cites))
      citation = create(:document_citation, document_id: document.id)
      citation_taxon_concept = create(:document_citation_taxon_concept,
        document_citation_id: citation.id, taxon_concept_id: @taxon_concept.id)
    end
    it "returns documents" do
      get :index, taxon_concept_id: @taxon_concept.id
      response.body.should have_json_size(1).at_path('cites_cop_docs')
    end
  end
end
