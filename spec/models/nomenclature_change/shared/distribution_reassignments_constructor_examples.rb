shared_context 'distribution_reassignments_constructor_examples' do
  context 'when previously no reassignments in place' do
    context 'when no distibutions' do
      specify { expect(input.distribution_reassignments.size).to eq(0) }
    end
    context 'when distributions' do
      let(:input_species) do
        s = create_cites_eu_species
        2.times { create(:distribution, taxon_concept: s) }
        s
      end
      specify { expect(input.distribution_reassignments.size).to eq(2) }
    end
  end
  context 'when previously reassignments in place' do
    let(:input) do
      i = create(:nomenclature_change_input, nomenclature_change: nc, taxon_concept: input_species)
      create(:nomenclature_change_distribution_reassignment, input: i)
      i
    end
    specify { expect(input.distribution_reassignments).to eq(@old_reassignments) }
  end
end
