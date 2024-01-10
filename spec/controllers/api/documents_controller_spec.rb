require 'spec_helper'

describe Api::V1::DocumentsController, type: :controller do

  before(:each) do
    @taxon_concept = create_cites_eu_species
    @subspecies = create_cites_eu_subspecies(parent: @taxon_concept)
    @document = create(:proposal, is_public: true, event: create_cites_cop)
    citation = create(:document_citation, document_id: @document.id)
    create(:document_citation_taxon_concept, document_citation_id: citation.id,
      taxon_concept_id: @taxon_concept.id)
    @subspecies_document = create(:proposal, is_public: true,
      event: create_cites_cop)
    subspecies_citation = create(:document_citation, document_id: @subspecies_document.id)
    create(:document_citation_taxon_concept, document_citation_id: subspecies_citation.id,
      taxon_concept_id: @subspecies.id)
    @document2 = create(:proposal, event: create_cites_cop)
    citation2 = create(:document_citation, document_id: @document2.id)
    create(:document_citation_taxon_concept, document_citation_id: citation2.id,
      taxon_concept_id: @taxon_concept.id)
    @document3 = create(:proposal, is_public: true, event: nil)
    citation3 = create(:document_citation, document_id: @document3.id)
    create(:document_citation_taxon_concept, document_citation_id: citation3.id,
      taxon_concept_id: @taxon_concept.id)
    DocumentSearch.refresh_citations_and_documents
  end

  context "GET index returns all documents" do
    def get_all_documents
      get :index, taxon_concept_id: @taxon_concept.id
      response.body.should have_json_size(4).at_path('documents')
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
      response.body.should have_json_size(3).at_path('documents')
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

  context "GET index returns only public documents for secretariat role" do
    def get_public_documents
      get :index, taxon_concept_id: @taxon_concept.id
      response.body.should have_json_size(3).at_path('documents')
    end
    context "GET index api user " do
      login_secretariat_user

      it "returns only public documents" do
        get_public_documents
      end
    end
  end

  context "show action fails" do
    login_api_user
    it "should return 403 status when permission denied" do
      controller.should_receive(:render_403) { controller.render nothing: true }
      get :show, id: @document2.id
    end
  end

  context "GET should retrieve documents with no event_type" do
    it "returns documents with no event_type" do
      get :index, event_type: "Other"
      response.body.should have_json_size(1).at_path('documents')
    end
  end

  context "download documents" do
    context "single document selected" do
      it "should return 404 if file is missing" do
        expect(File).to receive(:exists?).and_return(false)
        controller.should_receive(:render_404) { controller.render nothing: true }
        get :download_zip, ids: @document2.id
      end
      it "should return zip file if file is found" do
        allow(controller).to receive(:render)
        expect(File).to receive(:exists?).and_return(true)
        get :download_zip, ids: @document2.id
        response.headers['Content-Type'].should eq 'application/zip'
      end
    end

    context "multiple documents selected" do
      it "should return 404 if all files are missing" do
        expect(File).to receive(:exists?).and_return(false, false)
        controller.should_receive(:render_404) { controller.render nothing: true }
        get :download_zip, ids: "#{@document.id},#{@document2.id}"
      end

      it "should return zip file if at least a file is found" do
        expect(File).to receive(:exists?).and_return(false, true)
        get :download_zip, ids: "#{@document.id},#{@document2.id}"
        response.headers['Content-Type'].should eq 'application/zip'
      end
    end

    context "cascading documents logic" do
      it "should get subspecies documents" do
        get :index, taxon_concepts_ids: [@taxon_concept.id]
        response.body.should have_json_size(3).at_path('documents')
      end
    end
  end
end
