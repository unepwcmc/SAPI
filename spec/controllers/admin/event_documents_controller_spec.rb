require 'spec_helper'

describe Admin::EventDocumentsController, sidekiq: :inline do
  login_admin
  let(:event) { create(:event, published_at: DateTime.new(2014, 12, 25)) }

  describe "ordering" do
    before(:each) do
      @document1 = create(:document, event: event, sort_index: 2)
      @document2 = create(:document, event: event, sort_index: 1)
      DocumentSearch.refresh_citations_and_documents
    end

    describe "GET show_order" do
      it "assigns @documents sorted by sort index" do
        get :show_order, event_id: event.id
        expect(assigns(:documents)).to eq([@document2, @document1])
      end
    end

    describe "POST update_order" do
      it "updates sort index for collection of documents" do
        post :update_order, event_id: event.id, documents: {
          "#{@document1.id}" => '1',
          "#{@document2.id}" => '2'
        }
        expect(@document1.reload.sort_index).to eq(1)
        expect(@document2.reload.sort_index).to eq(2)
      end
    end

  end

end
