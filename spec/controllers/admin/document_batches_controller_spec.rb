require 'spec_helper'

describe Admin::DocumentBatchesController do
  login_admin
  let(:event){ create(:event) }
  before(:each){ create(:language, iso_code1: 'EN') }

  describe "GET new" do
    context "when no event" do
      let(:document){ create(:document) }
      it "renders the new template" do
        get :new
        response.should render_template('new')
      end
    end
    context "when event" do
      let(:document){ create(:document, event_id: event.id) }
      it "renders the new template" do
        get :new
        response.should render_template('new')
      end
    end
  end

  describe "POST create" do
    context "when no event" do
      let(:document){ create(:document) }
      it "redirects to index when successful" do
        post :create, document_batch: {
          date: Date.today, documents_attributes: { 0 => build_attributes(:document) }
        }
        response.should redirect_to(admin_documents_url)
      end
      # it "renders new when not successful" do
      #   post :create, document_batch: {
      #     date: nil, documents_attributes: { 0 => build_attributes(:document) }
      #   }
      #   response.should render_template('new')
      # end
    end
    context "when event" do
      let(:document){ create(:document, event_id: event.id) }
      it "redirects to index when successful" do
        post :create, event_id: event.id, document_batch: {
          date: Date.today, documents_attributes: { 0 => build_attributes(:document) }
        }
        response.should redirect_to(admin_event_documents_url(event))
      end
      # it "renders new when not successful" do
      #   post :create, event_id: event.id, document_batch: {
      #     date: nil, documents_attributes: { 0 => build_attributes(:document) }
      #   }
      #   response.should render_template('new')
      # end
    end
  end

end
