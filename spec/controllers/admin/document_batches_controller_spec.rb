require 'spec_helper'

describe Admin::DocumentBatchesController, sidekiq: :inline do
  login_admin
  let(:event) { create(:event) }
  before(:each) { create(:language, iso_code1: 'EN') }

  describe 'GET new' do
    context 'when no event' do
      let(:document) { create(:document) }
      it 'renders the new template' do
        get :new
        expect(response).to render_template('new')
      end
    end
    context 'when event' do
      let(:document) { create(:document, event_id: event.id) }
      it 'renders the new template' do
        get :new
        expect(response).to render_template('new')
      end
    end
  end

  describe 'POST create' do
    let(:document_attrs) do
      { 'type' => 'Document::Proposal' }
    end
    let(:files) do
      [ Rack::Test::UploadedFile.new(Rails.root.join('spec/support/annual_report_upload_exporter.csv').to_s) ]
    end

    context 'when no event' do
      let(:document) { create(:document) }

      it 'creates a new Document' do
        expect do
          post :create, params: { document_batch: {
            date: Time.zone.today, documents_attributes: { '0' => document_attrs }, files: files
          } }
        end.to change(Document, :count).by(1)
      end

      it 'redirects to index when successful' do
        post :create, params: { document_batch: {
          date: Time.zone.today, documents_attributes: { '0' => document_attrs }, files: files
        } }
        expect(response).to redirect_to(admin_documents_url)
      end

      it 'does not create a new Document' do
        expect do
          post :create, params: { document_batch: {
            date: nil, documents_attributes: { '0' => document_attrs }, files: files
          } }
        end.to change(Document, :count).by(0)
      end

      it 'renders new when not successful' do
        post :create, params: { document_batch: {
          date: nil, documents_attributes: { '0' => document_attrs }, files: files
        } }
        expect(response).to render_template('new')
      end
    end

    context 'when event' do
      let(:document) { create(:document, event_id: event.id) }

      it 'redirects to index when successful' do
        post :create, params: { event_id: event.id, document_batch: {
          date: Time.zone.today, documents_attributes: { '0' => document_attrs }, files: files
        } }
        expect(response).to redirect_to(admin_event_documents_url(event))
      end

      it 'renders new when not successful' do
        post :create, params: { event_id: event.id, document_batch: {
          date: nil, documents_attributes: { '0' => document_attrs }, files: files
        } }
        expect(response).to render_template('new')
      end
    end
  end
end
