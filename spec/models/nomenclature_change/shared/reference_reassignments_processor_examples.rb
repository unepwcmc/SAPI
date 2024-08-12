shared_context 'reference_reassignments_processor_examples' do
  let(:reassignment) do
    create(:nomenclature_change_reassignment,
      input: input,
      reassignable_type: 'TaxonConceptReference'
    )
  end
  let!(:reassignment_target) do
    create(:nomenclature_change_reassignment_target,
      reassignment: reassignment,
      output: output
    )
  end
  before(:each) do
    2.times { create(:taxon_concept_reference, taxon_concept: input_species) }
    processor.run
  end
  specify { expect(output_species1.taxon_concept_references.count).to eq(2) }
end
