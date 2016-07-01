shared_context 'common_name_reassignments_processor_examples' do
  let(:reassignment) {
    create(:nomenclature_change_reassignment,
      input: input,
      reassignable_type: 'TaxonCommon'
    )
  }
  let!(:reassignment_target) {
    create(:nomenclature_change_reassignment_target,
      reassignment: reassignment,
      output: output
    )
  }
  before(:each) do
    2.times { create(:taxon_common, taxon_concept: input_species) }
    processor.run
  end
  specify { expect(output_species1.common_names.count).to eq(2) }
end
