shared_context 'document_reassignments_constructor_examples' do
  context "when previously no reassignments in place" do
    context "when no document citations" do
      specify { expect(input.document_citation_reassignments.size).to eq(0) }
    end
    context "when document citations" do
      let(:input_species) {
        s = create_cites_eu_species
        2.times { create(:document_citation_taxon_concept, taxon_concept: s) }
        s
      }
      specify { expect(input.document_citation_reassignments.size).to eq(2) }
    end
  end
end
