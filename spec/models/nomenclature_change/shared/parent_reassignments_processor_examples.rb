shared_context 'parent_reassignments_processor_examples' do
  let(:input_species_child){
    create_cites_eu_subspecies(parent: input_species)
  }
  let(:reassignment){
    create(:nomenclature_change_parent_reassignment,
      input: input,
      reassignable_id: input_species_child.id
    )
  }
  let!(:reassignment_target){
    create(:nomenclature_change_reassignment_target,
      reassignment: reassignment,
      output: output
    )
  }
  before(:each) do
    processor.run
  end
  specify{ expect(input_species_child.reload.parent).to eq(output_species1) }
  specify{ expect(input_species.children.count).to eq(0) }
end
