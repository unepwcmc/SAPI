shared_context 'document_reassignments_constructor_examples' do
  context "when previously no reassignments in place" do
    context "when no document citations" do
      specify { expect(input.document_citation_reassignments.size).to eq(0) }
    end
    context "when document citations" do
      let(:input_species) {
        s = create_cites_eu_species
        ge = create(:geo_entity)
        create(:distribution, taxon_concept: s, geo_entity: ge)
        2.times { create(:document_citation, taxon_concepts: [s], geo_entities: [ge])}
        s
      }
      specify { expect(input.document_citation_reassignments.size).to eq(2) }
    end
  end
end
