require 'spec_helper'

describe Admin::DocumentsController do
  login_admin
  let(:event){ create(:event) }

  describe "index" do
    before(:each) do
      @document1 = create(:document, :title => 'BB hello world', event: event, date: DateTime.new(2014,12,25))
      @document2 = create(:document, :title => 'AA goodbye world', event: event, date: DateTime.new(2014,01,01))
    end

    describe "GET index" do
      it "assigns @documents sorted by time of creation" do
        @document3 = create(:document, :title => 'CC no event!')
        get :index
        assigns(:documents).should eq([@document3, @document2, @document1])
      end
      context "search" do
        it "runs a full text search on title" do
          get :index, 'document-title' => 'good'
          assigns(:documents).should eq([@document2])
        end

        it "retrieves documents inclusive of the given start date" do
          get :index, "document-date-start" => '25/12/2014'
          assigns(:documents).should eq([@document1])
        end

        it "retrieves documents inclusive of the given end date" do
          get :index, "document-date-end" => '01/01/2014'
          assigns(:documents).should eq([@document2])
        end

        it "retrieves documents after the given date" do
          get :index, "document-date-start" => '10/01/2014'
          assigns(:documents).should eq([@document1])
        end

        it "retrieves documents before the given date" do
          get :index, "document-date-end" => '10/01/2014'
          assigns(:documents).should eq([@document2])
        end

        it "ignores invalid dates" do
          get :index, "document-date-start" => '34/24/12', "document-date-end" => '34/24/12'
          assigns(:documents).should eq([@document2, @document1])
        end
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
        it "assigns @documents for event, sorted by title" do
          get :index, event_id: event.id
          assigns(:documents).should eq([@document2, @document1])
        end
      end
    end
  end

  describe "GET edit" do
    let(:document_tags){ [create(:document_tag)] }
    let(:document){ create(:document, tags: document_tags) }

    it "renders the edit template" do
      get :edit, id: document.id
      response.should render_template('new')
    end

    it "loads the Document's tags" do
      get :edit, id: document.id
      expect(assigns(:tags)).to match_array(document_tags)
    end
  end

  describe "PUT update" do
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

    context "with nested tag attributes" do
      let(:document){ create(:document) }
      let(:tag){ create(:document_tag) }

      it "adds existing tags to the Document" do
        put :update, id: document.id, document: { date: Date.today, tag_ids: [tag.id] }
        response.should redirect_to(admin_documents_url)

        expect(document.reload.tags).to eq([tag])
      end
    end
  end

  describe "DELETE destroy" do
    let(:poland){
      create(:geo_entity,
        :name_en => 'Poland', :iso_code2 => 'PL',
        :geo_entity_type => country_geo_entity_type
      )
    }
    let(:document){
      document = create(:document)
      document.citations << DocumentCitation.new(geo_entity_ids: [poland.id])
      document
    }
    it "redirects after delete" do
      delete :destroy, id: document.id
      response.should redirect_to(admin_documents_url)
    end
  end

end
