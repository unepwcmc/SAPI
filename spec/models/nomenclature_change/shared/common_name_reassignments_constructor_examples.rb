shared_context 'common_name_reassignments_constructor_examples' do
  context 'when previously no reassignments in place' do
    context 'when no common names' do
      specify { expect(input.reassignments.size).to eq(0) }
    end
    context 'when common names' do
      let(:input_species) do
        s = create_cites_eu_species
        2.times { create(:taxon_common, taxon_concept: s) }
        s
      end
      specify { expect(input.reassignments.size).to eq(1) }
    end
  end
  context 'when previously reassignments in place' do
    let(:input) do
      i = create(:nomenclature_change_input, nomenclature_change: nc, taxon_concept: input_species)
      create(:nomenclature_change_reassignment, input: i)
      i
    end
    specify { expect(input.reassignments).to eq(@old_reassignments) }
  end
end
