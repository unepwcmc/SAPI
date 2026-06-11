require 'spec_helper'

describe Api::V1::DocumentsController,
  skip_database_cleaner: true,
  skip_bootstrap_user: true do
  before(:all) do
    ensure_download_zips_table!
  end

  before(:each) do
    allow_any_instance_of(User).to receive(:sync_with_captive_breeding_db)
  end

  before(:each) do
    @taxon_concept = create_cites_eu_species
    @subspecies = create_cites_eu_subspecies(parent: @taxon_concept)
    @document = create(:proposal, is_public: true, event: create_cites_cop)
    citation = create(:document_citation, document_id: @document.id)
    create(
      :document_citation_taxon_concept, document_citation_id: citation.id,
      taxon_concept_id: @taxon_concept.id
    )
    @subspecies_document = create(
      :proposal, is_public: true,
      event: create_cites_cop
    )
    subspecies_citation = create(:document_citation, document_id: @subspecies_document.id)
    create(
      :document_citation_taxon_concept, document_citation_id: subspecies_citation.id,
      taxon_concept_id: @subspecies.id
    )
    @document2 = create(:proposal, event: create_cites_cop)
    citation2 = create(:document_citation, document_id: @document2.id)
    create(
      :document_citation_taxon_concept, document_citation_id: citation2.id,
      taxon_concept_id: @taxon_concept.id
    )
    @document3 = create(:proposal, is_public: true, event: nil)
    citation3 = create(:document_citation, document_id: @document3.id)
    create(
      :document_citation_taxon_concept, document_citation_id: citation3.id,
      taxon_concept_id: @taxon_concept.id
    )
    DocumentSearch.refresh_citations_and_documents
  end

  context 'GET index returns all documents' do
    def get_all_documents
      get :index, params: { taxon_concept_id: @taxon_concept.id }
      expect(response.body).to have_json_size(4).at_path('documents')
    end
    context 'GET index contributor' do
      login_contributor

      it 'returns all documents' do
        get_all_documents
      end
    end

    context 'GET index manager' do
      login_admin

      it 'returns all documents' do
        get_all_documents
      end
    end
  end

  context 'GET index returns only public documents' do
    def get_public_documents
      get :index, params: { taxon_concept_id: @taxon_concept.id }
      expect(response.body).to have_json_size(3).at_path('documents')
    end
    context 'GET index api user ' do
      login_api_user

      it 'returns only public documents' do
        get_public_documents
      end
    end
    context 'GET index no user' do |variable|
      it 'returns only public documents' do
        get_public_documents
      end
    end
  end

  context 'GET index returns only public documents for secretariat role' do
    def get_public_documents
      get :index, params: { taxon_concept_id: @taxon_concept.id }
      expect(response.body).to have_json_size(3).at_path('documents')
    end
    context 'GET index api user ' do
      login_secretariat_user

      it 'returns only public documents' do
        get_public_documents
      end
    end
  end

  context 'show action fails' do
    login_api_user
    it 'should return 403 status when permission denied' do
      get :show, params: { id: @document2.id }
      expect(response).to have_http_status(403)
    end
  end

  context 'GET should retrieve documents with no event_type' do
    it 'returns documents with no event_type' do
      get :index, params: { event_type: 'Other' }
      expect(response.body).to have_json_size(1).at_path('documents')
    end
  end

  context 'download documents' do
    def parsed_response
      JSON.parse(response.body)
    end

    it 'returns 422 when no ids are provided' do
      get :download_zip, params: { ids: '' }

      expect(response).to have_http_status(:unprocessable_entity)
    end

    it 'returns 404 when any selected document row is missing' do
      get :download_zip, params: { ids: "#{@document.id},999999999" }

      expect(response).to have_http_status(:not_found)
    end

    it 'returns 404 when all selected files are missing' do
      @document.file.purge
      @document2.file.purge

      get :download_zip, params: { ids: "#{@document.id},#{@document2.id}" }

      expect(response).to have_http_status(:not_found)
    end

    it 'creates a pending download zip request and returns its JSON state' do
      expect do
        get :download_zip, params: { ids: "#{@document.id},#{@document2.id}" }
      end.to change(DownloadZip, :count).by(1)

      expect(response).to have_http_status(:accepted)
      expect(parsed_response).to include(
        'status' => DownloadZip::PENDING,
        'error_message' => nil,
        'processing_at' => nil,
        'completed_at' => nil,
        'download_url' => nil
      )
      expect(parsed_response['id']).to be_present
    end

    it 'reuses the same download zip request for the same ids in a different order' do
      get :download_zip, params: { ids: "#{@document.id},#{@document2.id}" }
      first_response = parsed_response

      expect do
        get :download_zip, params: { ids: "#{@document2.id},#{@document.id}" }
      end.not_to change(DownloadZip, :count)

      expect(parsed_response['id']).to eq(first_response['id'])
    end

    it 'does not collapse a partially missing selection into the attached-only selection' do
      @document.file.purge

      get :download_zip, params: { ids: "#{@document.id},#{@document2.id}" }
      mixed_selection_id = parsed_response['id']

      get :download_zip, params: { ids: @document2.id.to_s }

      expect(parsed_response['id']).not_to eq(mixed_selection_id)
      expect(DownloadZip.count).to eq(2)
    end

    context 'cascading documents logic' do
      it 'should get subspecies documents' do
        get :index, params: { taxon_concepts_ids: [ @taxon_concept.id ] }
        expect(response.body).to have_json_size(3).at_path('documents')
      end
    end
  end
end
