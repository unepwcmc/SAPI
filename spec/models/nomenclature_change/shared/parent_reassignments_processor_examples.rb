shared_context 'parent_reassignments_processor_examples' do
  let(:input_species_child) {
    create_cites_eu_subspecies(parent: input_species)
  }
  let(:reassignment) {
    create(:nomenclature_change_parent_reassignment,
      input: input,
      reassignable_id: input_species_child.id
    )
  }
  let!(:reassignment_target) {
    create(:nomenclature_change_reassignment_target,
      reassignment: reassignment,
      output: output
    )
  }
  before(:each) do
    synonym_relationship_type
    processor.run
    input_species_child.reload
  end
  specify { expect(input_species_child.parent).to eq(input_species) }
  specify { expect(input_species_child.name_status).to eq('S') }
  specify { expect(input_species.children.count).to eq(0) }
  specify do
    old_subspecies = input_species_child.reload
    new_subspecies = output.taxon_concept.children.first
    expect(old_subspecies.accepted_names).to include(new_subspecies)
  end
end
