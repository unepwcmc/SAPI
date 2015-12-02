require 'spec_helper'

describe Api::V1::DocumentsController, :type => :controller do

  before(:each) do
    @taxon_concept = create(:taxon_concept)
    @document = create(:proposal, is_public: true, event: create(:cites_cop, designation: cites))
    citation = create(:document_citation, document_id: @document.id)
    create(:document_citation_taxon_concept, document_citation_id: citation.id,
      taxon_concept_id: @taxon_concept.id)
    @document2 = create(:proposal, event: create(:cites_cop, designation: cites))
    citation2 = create(:document_citation, document_id: @document2.id)
    create(:document_citation_taxon_concept, document_citation_id: citation2.id,
      taxon_concept_id: @taxon_concept.id)
    DocumentSearch.refresh
  end

  context "GET index returns all documents" do
    def get_all_documents
      get :index, taxon_concept_id: @taxon_concept.id
      response.body.should have_json_size(2).at_path('cites_cop/docs')
      response.body.should have_json_path('cites_cop/excluded_docs')
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
      response.body.should have_json_size(1).at_path('cites_cop/docs')
      response.body.should have_json_path('cites_cop/excluded_docs')
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

  context "download documents" do
    context "single document selected" do
      it "should return 404 if file is missing" do
        File.stub!(:exists?).and_return(false)
        get :download_zip, ids: @document2.id
        expect(response.status).to eq(404)
      end
      it "should return zip file if file is found" do
        controller.stub!(:render)
        File.stub!(:exists?).and_return(true)
        get :download_zip, ids: @document2.id
        response.headers['Content-Type'].should eq 'application/zip'
      end
    end

    context "multiple documents selected" do
      it "should return 404 if all files are missing" do
        File.stub!(:exists?).and_return(false)
        get :download_zip, ids: "#{@document.id},#{@document2.id}"
        expect(response.status).to eq(404)
      end

      it "should return zip file if at least a file is found" do
        File.stub!(:exists?).and_return(false, true)
        get :download_zip, ids: "#{@document.id},#{@document2.id}"
        response.headers['Content-Type'].should eq 'application/zip'
      end
    end
  end
end
