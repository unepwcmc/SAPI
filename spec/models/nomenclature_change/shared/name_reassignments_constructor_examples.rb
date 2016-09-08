shared_context 'name_reassignments_constructor_examples' do
  context "when previously no reassignments in place" do
    context "when no names" do
      specify { expect(input.name_reassignments.size).to eq(0) }
    end
    context "when names" do
      let(:input_species) {
        s = create_cites_eu_species
        2.times do
          create(:taxon_relationship,
            taxon_concept: s,
            other_taxon_concept: create_cites_eu_species(name_status: 'S'),
            taxon_relationship_type: synonym_relationship_type
          )
        end
        s
      }
      specify { expect(input.name_reassignments.size).to eq(2) }
    end
  end
  context "when previously reassignments in place" do
    let(:input) {
      i = create(:nomenclature_change_input, nomenclature_change: nc, taxon_concept: input_species)
      create(:nomenclature_change_name_reassignment, input: i)
      i
    }
    specify { expect(input.name_reassignments).to eq(@old_reassignments) }
  end
end
