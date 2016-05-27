require 'spec_helper'
describe DocumentSearch, sidekiq: :inline do
  describe :results do
    context "when searching by taxon concept" do
      let(:tc){ create_cites_eu_species }
      before(:each) do
        @document_with_tc_citation = create(
          :proposal, is_public: true,
          event: create(:cites_cop, designation: cites)
        )
        citation = create(
          :document_citation, document_id: @document_with_tc_citation.id
        )
        create(
          :document_citation_taxon_concept,
          document_citation_id: citation.id,
          taxon_concept_id: tc.id
        )
        @document_without_tc_citation = create(
          :proposal, is_public: true, event: @document_with_tc_citation.event
        )
        DocumentSearch.refresh
      end
      subject { DocumentSearch.new({'taxon_concepts_ids' => [tc.id]}, 'admin').results }
      specify { subject.map(&:id).should include(@document_with_tc_citation.id) }
      specify { subject.map(&:id).should_not include(@document_without_tc_citation.id) }
    end
  end

  describe :needs_refreshing? do
    before(:each) do
      @d = nil
      Timecop.travel(Time.now - (DocumentSearch::REFRESH_INTERVAL + 1).minutes) do
        @d = create(:proposal)
        DocumentSearch.refresh
      end
    end
    context "when no changes in last #{DocumentSearch::REFRESH_INTERVAL} minutes" do
      specify { expect(DocumentSearch.needs_refreshing?).to be_false }
    end
    context "when document created in last #{DocumentSearch::REFRESH_INTERVAL} minutes" do
      specify do
        Timecop.travel(Time.now - (DocumentSearch::REFRESH_INTERVAL - 1).minutes) do
          create(:proposal)
        end
        expect(DocumentSearch.needs_refreshing?).to be_true
      end
    end
    context "when document destroyed in last #{DocumentSearch::REFRESH_INTERVAL} minutes" do
      specify do
        Timecop.travel(Time.now - (DocumentSearch::REFRESH_INTERVAL - 1).minutes) do
          @d.destroy
        end
        expect(DocumentSearch.needs_refreshing?).to be_true
      end
    end
    context "when document updated in last #{DocumentSearch::REFRESH_INTERVAL} minutes" do
      specify do
        Timecop.travel(Time.now - (DocumentSearch::REFRESH_INTERVAL - 1).minutes) do
          @d.update_attributes(is_public: true)
        end
        expect(DocumentSearch.needs_refreshing?).to be_true
      end
    end
  end
end
