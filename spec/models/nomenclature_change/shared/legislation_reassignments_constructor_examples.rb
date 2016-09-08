shared_context 'legislation_reassignments_constructor_examples' do
  context "when previously no reassignments in place" do
    context "when no CITES listings" do
      specify { expect(input.legislation_reassignments.size).to eq(0) }
    end
    context "when CITES listings" do
      let(:input_species) {
        s = create_cites_eu_species
        create_cites_I_addition(taxon_concept: s)
        create_cites_II_addition(taxon_concept: s)
        s
      }
      specify { expect(input.legislation_reassignments.size).to eq(1) }
    end
  end
  context "when previously reassignments in place" do
    let(:input) {
      i = create(:nomenclature_change_input, nomenclature_change: nc, taxon_concept: input_species)
      create(:nomenclature_change_legislation_reassignment, input: i)
      i
    }
    specify { expect(input.legislation_reassignments).to eq(@old_reassignments) }
  end
end
