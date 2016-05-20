require 'spec_helper'

describe Admin::EventDocumentsController, sidekiq: :inline do
  login_admin
  let(:event){ create(:event, published_at: DateTime.new(2014,12,25)) }

  describe "reorder" do
    before(:each) do
      @document1 = create(:document, event: event, sort_index: 2)
      @document2 = create(:document, event: event, sort_index: 1)
      DocumentSearch.refresh
    end

    describe "GET reorder" do
      it "assigns @documents sorted by sort index" do
        get :reorder, event_id: event.id
        assigns(:documents).should eq([@document2, @document1])
      end
    end
  end

end
