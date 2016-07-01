shared_context 'output_reference_reassignments_processor_examples' do
  before(:each) do
    create(:nomenclature_change_output_reassignment,
      output: output,
      reassignable_type: 'TaxonConceptReference'
    )
    2.times { create(:taxon_concept_reference, taxon_concept: old_output_subspecies) }
    output_processor.run
    processor.run
  end
  specify { expect(new_output_species.taxon_concept_references.count).to eq(2) }
  specify { expect(old_output_subspecies.taxon_concept_references).to be_empty }
end
