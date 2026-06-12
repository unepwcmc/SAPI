require 'spec_helper'

RSpec.describe Api::V1::DocumentsController, type: :controller do
  before(:each) do
    DownloadZip.find_each do |download_zip|
      download_zip.zip_file.purge if download_zip.zip_file.attached?
    end
    DownloadZip.delete_all
  end

  def parsed_response
    JSON.parse(response.body)
  end

  let(:first_document) do
    create(:proposal, is_public: true, event: nil, designation: nil)
  end
  let(:second_document) do
    create(:proposal, is_public: true, event: nil, designation: nil)
  end
  let(:private_document) do
    create(:proposal, is_public: false, event: nil, designation: nil)
  end

  describe 'GET download_zip' do
    it 'returns 422 when no ids are provided' do
      get :download_zip, params: { ids: '' }

      expect(response).to have_http_status(:unprocessable_entity)
    end

    it 'returns 404 when any selected document row is missing' do
      get :download_zip, params: { ids: "#{first_document.id},999999999" }

      expect(response).to have_http_status(:not_found)
    end

    it 'returns 404 when all selected files are missing' do
      first_document.file.purge
      second_document.file.purge

      get :download_zip, params: { ids: "#{first_document.id},#{second_document.id}" }

      expect(response).to have_http_status(:not_found)
    end

    it 'creates a pending download zip request and returns its JSON state' do
      expect do
        get :download_zip, params: { ids: "#{first_document.id},#{second_document.id}" }
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
      get :download_zip, params: { ids: "#{first_document.id},#{second_document.id}" }
      first_response = parsed_response

      expect do
        get :download_zip, params: { ids: "#{second_document.id},#{first_document.id}" }
      end.not_to change(DownloadZip, :count)

      expect(parsed_response['id']).to eq(first_response['id'])
    end

    it 'does not collapse a partially missing selection into the attached-only selection' do
      first_document.file.purge

      get :download_zip, params: { ids: "#{first_document.id},#{second_document.id}" }
      mixed_selection_id = parsed_response['id']

      get :download_zip, params: { ids: second_document.id.to_s }

      expect(parsed_response['id']).not_to eq(mixed_selection_id)
      expect(DownloadZip.count).to eq(2)
    end

    it 'returns 404 when an anonymous user selects a public and a private document' do
      get :download_zip, params: { ids: "#{first_document.id},#{private_document.id}" }

      expect(response).to have_http_status(:not_found)
    end

    it 'returns 404 when an anonymous user selects only private documents' do
      get :download_zip, params: { ids: private_document.id.to_s }

      expect(response).to have_http_status(:not_found)
    end

    context 'when signed in as an API user' do
      login_api_user

      it 'returns 404 when a public and private document are requested together' do
        get :download_zip, params: { ids: "#{first_document.id},#{private_document.id}" }

        expect(response).to have_http_status(:not_found)
      end
    end

    context 'when signed in as an e-library viewer' do
      login_elibrary_viewer

      it 'allows a public and private document to be downloaded together' do
        get :download_zip, params: { ids: "#{first_document.id},#{private_document.id}" }

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
    end
  end
end
