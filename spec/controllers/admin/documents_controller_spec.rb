require 'spec_helper'

describe Admin::DocumentsController, sidekiq: :inline do
  let(:event) { create(:event, published_at: DateTime.new(2014, 12, 25)) }
  let(:event2) { create(:event, published_at: DateTime.new(2015, 12, 12)) }
  let(:taxon_concept) { create(:taxon_concept) }
  let(:geo_entity) { create(:geo_entity) }
  let(:proposal_outcome) { create(:proposal_outcome) }
  let(:review_phase) { create(:review_phase) }
  let(:process_stage) { create(:process_stage) }

  describe "index" do
    before(:each) do
      @document1 = create(:document, :title => 'BB hello world', event: event)
      @document2 = create(:document, :title => 'AA goodbye world', event: event)
      @public_document = create(:document, :title => 'DD public document', event: event, is_public: true)
      create(:document_citation, :document_id => @document1.id, :taxon_concepts => [taxon_concept])
      create(:document_citation, :document_id => @document2.id, :geo_entities => [geo_entity])
      create(:document_citation, :document_id => @public_document.id, :taxon_concepts => [taxon_concept])
    end

    describe "GET index" do
      login_admin
      before(:each) do
        @document3 = create(:document, :title => 'CC no event!', date: DateTime.new(2014, 01, 01))
        DocumentSearch.refresh_citations_and_documents
      end

      it "assigns @documents sorted by time of creation" do
        get :index
        assigns(:documents).should eq([@document3, @public_document, @document2, @document1])
      end

      context "search" do
        it "runs a full text search on title" do
          get :index, 'title_query' => 'good'
          assigns(:documents).should eq([@document2])
        end
        it "retrieves documents inclusive of the given start date" do
          get :index, "document_date_start" => '25/12/2014'
          assigns(:documents).should eq([@public_document, @document2, @document1])
        end
        it "retrieves documents inclusive of the given end date" do
          get :index, "document_date_end" => '01/01/2014'
          assigns(:documents).should eq([@document3])
        end
        it "retrieves documents after the given date" do
          get :index, "document_date_start" => '10/01/2014'
          assigns(:documents).should eq([@public_document, @document2, @document1])
        end
        it "retrieves documents before the given date" do
          get :index, "document_date_end" => '10/01/2014'
          assigns(:documents).should eq([@document3])
        end
        it "ignores invalid dates" do
          get :index, "document_date_start" => '34/24/12', "document_date_end" => '34/24/12'
          assigns(:documents).should eq([@document3, @public_document, @document2, @document1])
        end
        it "retrieves documents for taxon concept" do
          get :index, "taxon_concepts_ids" => taxon_concept.id
          assigns(:documents).should eq([@public_document, @document1])
        end
        it "retrieves documents for geo entity" do
          get :index, "geo_entities_ids" => [geo_entity.id]
          assigns(:documents).should eq([@document2])
        end
        context 'by proposal outcome' do
          before(:each) do
            @document3 = create(:proposal, event: create_cites_cop(published_at: DateTime.new(2014, 01, 01)))
            create(:proposal_details, document_id: @document3.id, proposal_outcome_id: proposal_outcome.id)
            DocumentSearch.refresh_citations_and_documents
          end
          it "retrieves documents for tag" do
            get :index, "document_tags_ids" => [proposal_outcome.id]
            assigns(:documents).map(&:id).should eq([@document3].map(&:id))
          end
        end
        context 'by document tags' do
          before(:each) do
            @document3 = create(:review_of_significant_trade, event: create_ec_srg(published_at: DateTime.new(2014, 01, 01)))
            create(:review_details, document_id: @document3.id, review_phase_id: review_phase.id, process_stage_id: process_stage.id)
            DocumentSearch.refresh_citations_and_documents
          end
          it "retrieves documents for review_phase tag" do
            get :index, "document_tags_ids" => [review_phase.id]
            assigns(:documents).map(&:id).should eq([@document3].map(&:id))
          end
          it "retrieves documents for process_stage tag" do
            get :index, "document_tags_ids" => [process_stage.id]
            assigns(:documents).map(&:id).should eq([@document3].map(&:id))
          end
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
          get :index, events_ids: [event.id]
          response.should render_template('admin/event_documents/index')
        end
        it "assigns @documents for event, sorted by title" do
          @document3 = create(:document, title: 'CC hello world', event: event2)
          DocumentSearch.refresh_citations_and_documents
          get :index, events_ids: [event.id, event2.id]
          assigns(:documents).should eq([@document3, @document2, @document1, @public_document])
        end
      end
      context "when secretariat is logged in" do
        login_secretariat_user
        it "returns only public documents" do
          get :index
          assigns(:documents).should eq([@public_document])
        end
      end
    end
  end

  describe "GET edit" do
    login_admin
    let(:document_tags) { [create(:document_tag)] }
    let(:document) { create(:document, tags: document_tags) }

    it "renders the edit template" do
      get :edit, id: document.id
      response.should render_template('new')
    end
  end

  describe "PUT update" do
    login_admin
    context "when no event" do
      let(:document) { create(:document) }
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
      let(:document) { create(:document, event_id: event.id) }
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

    context "with nested review_details attributes" do
      let(:document) { create(:review_of_significant_trade) }
      let(:review_phase) { create(:review_phase) }
      let(:process_stage) { create(:process_stage) }
      let(:recommended_category) { "A wonderful category" }

      it "assign review phase to Review" do
        put :update, id: document.id, document: {
          date: Date.today, review_details_attributes: { review_phase_id: review_phase.id }
        }
        response.should redirect_to(admin_documents_url)

        expect(document.reload.review_details.review_phase_id).to eq(review_phase.id)
      end

      it "assign process stage to Review" do
        put :update, id: document.id, document: {
          date: Date.today, review_details_attributes: { process_stage_id: process_stage.id }
        }
        response.should redirect_to(admin_documents_url)

        expect(document.reload.review_details.process_stage_id).to eq(process_stage.id)
      end

      it "assign recommended category to Review" do
        put :update, id: document.id, document: {
          date: Date.today, review_details_attributes: { recommended_category: recommended_category }
        }
        response.should redirect_to(admin_documents_url)

        expect(document.reload.review_details.recommended_category).to eq(recommended_category)
      end
    end

    context "with nested proposal_details attributes" do
      let(:document) { create(:proposal) }
      let(:proposal_outcome) { create(:document_tag, type: 'DocumentTag::ProposalOutcome') }

      it "assign outcome to Proposal" do
        put :update, id: document.id, document: {
          date: Date.today, proposal_details_attributes: { proposal_outcome_id: proposal_outcome.id }
        }
        response.should redirect_to(admin_documents_url)

        expect(document.reload.proposal_details.proposal_outcome_id).to eq(proposal_outcome.id)
      end
    end

  end

  describe "DELETE destroy" do
    login_admin
    let(:poland) {
      create(:geo_entity,
        :name_en => 'Poland', :iso_code2 => 'PL',
        :geo_entity_type => country_geo_entity_type
      )
    }
    let(:document) {
      document = create(:document)
      document.citations << DocumentCitation.new(geo_entity_ids: [poland.id])
      document
    }
    it "redirects after delete" do
      delete :destroy, id: document.id
      response.should redirect_to(admin_documents_url)
    end
  end

  describe "XHR GET JSON autocomplete" do
    login_admin
    let!(:document) {
      create(:document,
        :title => 'Title',
        :event_id => event.id
      )
    }
    let!(:document2) { create(:document, :title => 'Title2') }

    context "When no event specified" do
      it "returns properly formatted json" do
        xhr :get, :autocomplete, :format => 'json',
          :title => 'tit'
        response.body.should have_json_size(2)
        parse_json(response.body, "0/title").should == 'Title'
        parse_json(response.body, "1/title").should == 'Title2'
      end
    end

    context "When an event is specified" do
      it "returns properly formatted json" do
        xhr :get, :autocomplete, :format => 'json',
          :title => 'tit', :event_id => event.id
        response.body.should have_json_size(1)
        parse_json(response.body, "0/title").should == 'Title'
      end
    end
  end

end
