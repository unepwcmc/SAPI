require 'spec_helper'

describe Admin::DocumentsController do
  login_admin
  let(:event){ create(:event) }

  describe "index" do
    before(:each) do
      @document1 = create(:document, :title => 'BB')
      @document2 = create(:document, :title => 'AA')
    end

    describe "GET index" do
      it "assigns @documents sorted by name" do
        get :index
        assigns(:documents).should eq([@document2, @document1])
      end
      context "when no event" do
        it "renders the index template" do
          get :index
          response.should render_template("index")
        end
      end
      context "when event" do
        it "renders the event/documents/index template" do
          get :index, event_id: event.id
          response.should render_template('admin/event_documents/index')
        end
      end
    end
  end

  describe "XHR GET edit" do
    let(:document){ create(:document) }
    it "renders the edit template" do
      xhr :get, :edit, id: document.id
      response.should render_template('new')
    end
  end

  describe "XHR PUT update" do
    context "when no event" do
      let(:document){ create(:document) }
      it "redirects to index when successful" do
        put :update, id: document.id, document: { date: Date.today }
        response.should redirect_to(admin_documents_url)
        flash[:notice].should_not be_nil
      end
      it "renders new when not successful" do
        put :update, id: document.id, document: { date: nil }
        response.should render_template('new')
      end
    end
    context "when event" do
      let(:document){ create(:document, event_id: event.id) }
      it "redirects to index when successful" do
        put :update, id: document.id, event_id: event.id, document: { date: Date.today }
        response.should redirect_to(admin_event_documents_url(event))
        flash[:notice].should_not be_nil
      end
      it "renders new when not successful" do
        put :update, id: document.id, event_id: event.id, document: { date: nil }
        response.should render_template('new')
      end
    end
  end

  describe "DELETE destroy" do
    let(:document){ create(:document) }
    it "redirects after delete" do
      delete :destroy, id: document.id
      response.should redirect_to(admin_documents_url)
    end
  end

end
