require 'spec_helper'

describe Api::V1::DocumentsController, :type => :controller do

  before(:each) do
    @taxon_concept = create(:taxon_concept)
    document = create(:proposal, is_public: true, event: create(:cites_cop, designation: cites))
    citation = create(:document_citation, document_id: document.id)
    create(:document_citation_taxon_concept, document_citation_id: citation.id,
      taxon_concept_id: @taxon_concept.id)
    @document2 = create(:proposal, event: create(:cites_cop, designation: cites))
    citation2 = create(:document_citation, document_id: @document2.id)
    create(:document_citation_taxon_concept, document_citation_id: citation2.id,
      taxon_concept_id: @taxon_concept.id)
  end

  context "GET index returns all documents" do
    def get_all_documents
      get :index, taxon_concept_id: @taxon_concept.id
      response.body.should have_json_size(2).at_path('cites_cop_docs')
    end
    context "GET index contributor" do
      login_contributor

      it "returns all documents" do
        get_all_documents
      end
    end

    context "GET index manager" do
      login_admin

      it "returns all documents" do
        get_all_documents
      end
    end
  end

  context "GET index returns only public documents" do
    def get_public_documents
      get :index, taxon_concept_id: @taxon_concept.id
      response.body.should have_json_size(1).at_path('cites_cop_docs')
    end
    context "GET index api user " do
      login_api_user

      it "returns only public documents" do
        get_public_documents
      end
    end
    context "GET index no user" do |variable|
      it "returns only public documents" do
        get_public_documents
      end
    end
  end

  context "show action fails" do
    login_api_user
    it "should return 403 status when permission denied" do
      get :show, id: @document2.id
      expect(response.status).to eq(403)
    end
  end
end
