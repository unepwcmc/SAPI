require 'spec_helper'

describe Admin::DocumentBatchesController, sidekiq: :inline do
  login_admin
  let(:event) { create(:event) }
  before(:each) { create(:language, iso_code1: 'EN') }

  describe "GET new" do
    context "when no event" do
      let(:document) { create(:document) }
      it "renders the new template" do
        get :new
        response.should render_template('new')
      end
    end
    context "when event" do
      let(:document) { create(:document, event_id: event.id) }
      it "renders the new template" do
        get :new
        response.should render_template('new')
      end
    end
  end

  describe "POST create" do
    let(:document_attrs) {
      { 'type' => 'Document::Proposal' }
    }
    let(:files) {
      [Rack::Test::UploadedFile.new(File.join(Rails.root, 'spec', 'support', 'annual_report_upload_exporter.csv'))]
    }

    context "when no event" do
      let(:document) { create(:document) }

      it "creates a new Document" do
        expect {
          post :create, document_batch: {
            date: Date.today, documents_attributes: { "0" => document_attrs }, files: files
          }
        }.to change(Document, :count).by(1)
      end

      it "redirects to index when successful" do
        post :create, document_batch: {
          date: Date.today, documents_attributes: { "0" => document_attrs }, files: files
        }
        response.should redirect_to(admin_documents_url)
      end

      it "does not create a new Document" do
        expect {
          post :create, document_batch: {
            date: nil, documents_attributes: { "0" => document_attrs }, files: files
          }
        }.to change(Document, :count).by(0)
      end

      it "renders new when not successful" do
        post :create, document_batch: {
          date: nil, documents_attributes: { "0" => document_attrs }, files: files
        }
        response.should render_template('new')
      end
    end

    context "when event" do
      let(:document) { create(:document, event_id: event.id) }

      it "redirects to index when successful" do
        post :create, event_id: event.id, document_batch: {
          date: Date.today, documents_attributes: { "0" => document_attrs }, files: files
        }
        response.should redirect_to(admin_event_documents_url(event))
      end

      it "renders new when not successful" do
        post :create, event_id: event.id, document_batch: {
          date: nil, documents_attributes: { "0" => document_attrs }, files: files
        }
        response.should render_template('new')
      end
    end
  end

end
