require 'spec_helper'
describe DocumentSearch do
  describe :results do
    context "when searching by taxon concept" do
      let(:tc){ create_cites_eu_species }
      let(:document_with_tc_citation){
        create(:proposal, is_public: true, event: create(:cites_cop, designation: cites))
      }
      let(:citation){ create(:document_citation, document_id: document_with_tc_citation.id) }
      let!(:tc_citation){
        create(
          :document_citation_taxon_concept,
          document_citation_id: citation.id,
          taxon_concept_id: tc.id
        )
      }
      subject { DocumentSearch.new({'taxon_concepts_ids' => [tc.id]}, 'admin').results }
      specify { subject.should include(document_with_tc_citation) }
      
      context "when documents without tc citations present" do
        let!(:document_without_tc_citation){
          create(:proposal, is_public: true, event: document_with_tc_citation.event)
        }
        specify { subject.should_not include(document_without_tc_citation) }
      end
    end
  end
end
