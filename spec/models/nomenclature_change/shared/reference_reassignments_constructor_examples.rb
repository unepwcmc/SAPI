shared_context 'reference_reassignments_constructor_examples' do
  context "when previously no reassignments in place" do
    context "when no references" do
      specify { expect(input.reassignments.size).to eq(0) }
    end
    context "when references" do
      let(:input_species) {
        s = create_cites_eu_species
        2.times { create(:taxon_concept_reference, taxon_concept: s) }
        s
      }
      specify { expect(input.reassignments.size).to eq(1) }
    end
  end
  context "when previously reassignments in place" do
    let(:input) {
      i = create(:nomenclature_change_input, nomenclature_change: nc, taxon_concept: input_species)
      create(:nomenclature_change_reassignment, input: i)
      i
    }
    specify { expect(input.reassignments).to eq(@old_reassignments) }
  end
end
