shared_context 'output_common_name_reassignments_processor_examples' do
  before(:each) do
    create(:nomenclature_change_output_reassignment,
      output: output,
      reassignable_type: 'TaxonCommon'
    )
    2.times { create(:taxon_common, taxon_concept: old_output_subspecies) }
    output_processor.run
    processor.run
  end
  specify { expect(new_output_species.common_names.count).to eq(2) }
  specify { expect(old_output_subspecies.common_names).to be_empty }
end
