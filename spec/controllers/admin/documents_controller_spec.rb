require 'spec_helper'

describe Admin::DocumentsController, sidekiq: :inline do
  let(:event) { create(:event, published_at: DateTime.new(2014, 12, 25)) }
  let(:event2) { create(:event, published_at: DateTime.new(2015, 12, 12)) }
  let(:taxon_concept) { create(:taxon_concept) }
  let(:taxon_concept2) { create(:taxon_concept) }
  let(:geo_entity) { create(:geo_entity) }
  let(:proposal_outcome) { create(:proposal_outcome) }
  let(:review_phase) { create(:review_phase) }
  let(:process_stage) { create(:process_stage) }

  describe "index" do
    before(:each) do
      @document1 = create(:document, title: 'BB hello world', event: event)
      @document2 = create(:document, title: 'AA goodbye world', event: event)
      @public_document = create(:document, title: 'DD public document', event: event, is_public: true)
      create(:document_citation, document_id: @document1.id, taxon_concepts: [taxon_concept])
      create(:document_citation, document_id: @document2.id, geo_entities: [geo_entity])
      create(:document_citation, document_id: @public_document.id, taxon_concepts: [taxon_concept])
    end

    describe "GET index" do
      login_admin
      before(:each) do
        @document3 = create(:document, title: 'CC no event!', date: DateTime.new(2014, 01, 01))
        DocumentSearch.refresh_citations_and_documents
      end

      it "assigns @documents sorted by time of creation" do
        get :index
        expect(assigns(:documents)).to eq([@document3, @public_document, @document2, @document1])
      end

      context "search" do
        it "runs a full text search on title" do
          get :index, params: { 'title_query' => 'good' }
          expect(assigns(:documents)).to eq([@document2])
        end
        it "retrieves documents inclusive of the given start date" do
          get :index, params: { "document_date_start" => '25/12/2014' }
          expect(assigns(:documents)).to eq([@public_document, @document2, @document1])
        end
        it "retrieves documents inclusive of the given end date" do
          get :index, params: { "document_date_end" => '01/01/2014' }
          expect(assigns(:documents)).to eq([@document3])
        end
        it "retrieves documents after the given date" do
          get :index, params: { "document_date_start" => '10/01/2014' }
          expect(assigns(:documents)).to eq([@public_document, @document2, @document1])
        end
        it "retrieves documents before the given date" do
          get :index, params: { "document_date_end" => '10/01/2014' }
          expect(assigns(:documents)).to eq([@document3])
        end
        it "ignores invalid dates" do
          get :index, params: { "document_date_start" => '34/24/12', "document_date_end" => '34/24/12' }
          expect(assigns(:documents)).to eq([@document3, @public_document, @document2, @document1])
        end
        it "retrieves documents for taxon concept" do
          get :index, params: { "taxon_concepts_ids" => taxon_concept.id }
          expect(assigns(:documents)).to eq([@public_document, @document1])
        end
        it "retrieves documents for geo entity" do
          get :index, params: { "geo_entities_ids" => [geo_entity.id] }
          expect(assigns(:documents)).to eq([@document2])
        end
        context 'by proposal outcome' do
          before(:each) do
            @document3 = create(:proposal, event: create_cites_cop(published_at: DateTime.new(2014, 01, 01)))
            create(:proposal_details, document_id: @document3.id, proposal_outcome_id: proposal_outcome.id)
            DocumentSearch.refresh_citations_and_documents
          end
          it "retrieves documents for tag" do
            get :index, params: { "document_tags_ids" => [proposal_outcome.id] }
            expect(assigns(:documents).map(&:id)).to eq([@document3].map(&:id))
          end
        end
        context 'by document tags' do
          before(:each) do
            @document3 = create(:review_of_significant_trade, event: create_ec_srg(published_at: DateTime.new(2014, 01, 01)))
            create(:review_details, document_id: @document3.id, review_phase_id: review_phase.id, process_stage_id: process_stage.id)
            DocumentSearch.refresh_citations_and_documents
          end
          it "retrieves documents for review_phase tag" do
            get :index, params: { "document_tags_ids" => [review_phase.id] }
            expect(assigns(:documents).map(&:id)).to eq([@document3].map(&:id))
          end
          it "retrieves documents for process_stage tag" do
            get :index, params: { "document_tags_ids" => [process_stage.id] }
            expect(assigns(:documents).map(&:id)).to eq([@document3].map(&:id))
          end
        end
      end

      context "when no event" do
        it "renders the index template" do
          get :index
          expect(response).to render_template("index")
        end
      end

      context "when event" do
        it "renders the event/documents/index template" do
          get :index, params: { events_ids: [event.id] }
          expect(response).to render_template('admin/event_documents/index')
        end
        it "assigns @documents for event, sorted by title" do
          @document3 = create(:document, title: 'CC hello world', event: event2)
          DocumentSearch.refresh_citations_and_documents
          get :index, params: { events_ids: [event.id, event2.id] }
          expect(assigns(:documents)).to eq([@document3, @document2, @document1, @public_document])
        end
      end
      context "when secretariat is logged in" do
        login_secretariat_user
        it "returns only public documents" do
          get :index
          expect(assigns(:documents)).to eq([@public_document])
        end
      end
    end
  end

  describe "GET edit" do
    login_admin
    let(:document_tags) { [create(:document_tag)] }
    let(:document) { create(:document, tags: document_tags) }

    it "renders the edit template" do
      get :edit, params: { id: document.id }
      expect(response).to render_template('new')
    end
  end

  describe "PUT update" do
    login_admin
    context "when no event" do
      let(:document) { create(:document) }
      it "redirects to index when successful" do
        put :update, params: { id: document.id, document: { date: Date.today } }
        expect(response).to redirect_to(admin_documents_url)
        expect(flash[:notice]).not_to be_nil
      end
      it "renders new when not successful" do
        put :update, params: { id: document.id, document: { date: nil } }
        expect(response).to render_template('new')
      end
    end

    context "when event" do
      let(:document) { create(:document, event_id: event.id) }
      it "redirects to index when successful" do
        put :update, params: { id: document.id, event_id: event.id, document: { date: Date.today } }
        expect(response).to redirect_to(admin_event_documents_url(event))
        expect(flash[:notice]).not_to be_nil
      end
      it "renders new when not successful" do
        put :update, params: { id: document.id, event_id: event.id, document: { date: nil } }
        expect(response).to render_template('new')
      end
    end

    context "with nested review_details attributes" do
      let(:document) { create(:review_of_significant_trade) }
      let(:review_phase) { create(:review_phase) }
      let(:process_stage) { create(:process_stage) }
      let(:recommended_category) { "A wonderful category" }

      it "assign review phase to Review" do
        put :update, params: { id: document.id, document: {
          date: Date.today, review_details_attributes: { review_phase_id: review_phase.id }
        } }
        expect(response).to redirect_to(admin_documents_url)

        expect(document.reload.review_details.review_phase_id).to eq(review_phase.id)
      end

      it "assign process stage to Review" do
        put :update, params: { id: document.id, document: {
          date: Date.today, review_details_attributes: { process_stage_id: process_stage.id }
        } }
        expect(response).to redirect_to(admin_documents_url)

        expect(document.reload.review_details.process_stage_id).to eq(process_stage.id)
      end

      it "assign recommended category to Review" do
        put :update, params: { id: document.id, document: {
          date: Date.today, review_details_attributes: { recommended_category: recommended_category }
        } }
        expect(response).to redirect_to(admin_documents_url)

        expect(document.reload.review_details.recommended_category).to eq(recommended_category)
      end
    end

    context "with nested proposal_details attributes" do
      let(:document) { create(:proposal) }
      let(:proposal_outcome) { create(:document_tag, type: 'DocumentTag::ProposalOutcome') }

      it "assign outcome to Proposal" do
        put :update, params: { id: document.id, document: {
          date: Date.today, proposal_details_attributes: { proposal_outcome_id: proposal_outcome.id }
        } }
        expect(response).to redirect_to(admin_documents_url)

        expect(document.reload.proposal_details.proposal_outcome_id).to eq(proposal_outcome.id)
      end
    end

    context "with nested citations_attributes" do
      let(:document) { create(:proposal) }
      let(:proposal_outcome) { create(:document_tag, type: 'DocumentTag::ProposalOutcome') }

      it "assigns a taxon" do
        put :update, params: {
          id: document.id,
          document: {
            date: Date.today,
            citations_attributes: [
              {
                stringy_taxon_concept_ids: taxon_concept.id
              }
            ]
          }
        }

        expect(document.reload.citations.length).to eq(1)
        expect(document.reload.citations[0].taxon_concepts.length).to eq(1)
        expect(document.reload.citations[0].taxon_concepts[0].id).to eq(taxon_concept.id)
      end

      it "assigns multiple taxa" do
        put :update, params: {
          id: document.id,
          document: {
            date: Date.today,
            citations_attributes: [
              {
                stringy_taxon_concept_ids: "#{taxon_concept.id},#{taxon_concept2.id}"
              }
            ]
          }
        }

        expect(document.reload.citations.length).to eq(1)
        expect(document.reload.citations[0].taxon_concepts.length).to eq(2)
        expect([
          document.reload.citations[0].taxon_concepts[0].id,
          document.reload.citations[0].taxon_concepts[1].id
        ].sort!).to eq([
          taxon_concept.id,
          taxon_concept2.id
        ])
      end

      it "assigns a geo_entity_id" do
        put :update, params: {
          id: document.id,
          document: {
            date: Date.today,
            citations_attributes: [
              {
                geo_entity_ids: [geo_entity.id]
              }
            ]
          }
        }

        expect(document.reload.citations.length).to eq(1)
        expect(document.reload.citations[0].geo_entities.length).to eq(1)
        expect(document.reload.citations[0].geo_entities[0].id).to eq(geo_entity.id)
      end
    end
  end

  describe "DELETE destroy" do
    login_admin
    let(:poland) {
      create(:geo_entity,
        name_en: 'Poland', iso_code2: 'PL',
        geo_entity_type: country_geo_entity_type
      )
    }
    let(:document) {
      document = create(:document)
      document.citations << DocumentCitation.new(geo_entity_ids: [poland.id])
      document
    }
    it "redirects after delete" do
      delete :destroy, params: { id: document.id }
      expect(response).to redirect_to(admin_documents_url)
    end
  end

  describe "XHR GET JSON autocomplete" do
    login_admin
    let!(:document) {
      create(:document,
        title: 'Title',
        event_id: event.id
      )
    }
    let!(:document2) { create(:document, title: 'Title2') }

    context "When no event specified" do
      it "returns properly formatted json" do
        get :autocomplete, format: 'json', params: { title: 'tit' }, xhr: true
        expect(response.body).to have_json_size(2)
        expect(parse_json(response.body, "0/title")).to eq('Title')
        expect(parse_json(response.body, "1/title")).to eq('Title2')
      end
    end

    context "When an event is specified" do
      it "returns properly formatted json" do
        get :autocomplete, format: 'json', params: { title: 'tit', event_id: event.id }, xhr: true
        expect(response.body).to have_json_size(1)
        expect(parse_json(response.body, "0/title")).to eq('Title')
      end
    end
  end

end
