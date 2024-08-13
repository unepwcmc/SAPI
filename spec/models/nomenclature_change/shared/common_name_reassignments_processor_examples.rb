shared_context 'common_name_reassignments_processor_examples' do
  let(:reassignment) do
    create(
      :nomenclature_change_reassignment,
      input: input,
      reassignable_type: 'TaxonCommon'
    )
  end
  let!(:reassignment_target) do
    create(
      :nomenclature_change_reassignment_target,
      reassignment: reassignment,
      output: output
    )
  end
  before(:each) do
    2.times { create(:taxon_common, taxon_concept: input_species) }
    processor.run
  end
  specify { expect(output_species1.common_names.count).to eq(2) }
end
