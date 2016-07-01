shared_context 'shipment_reassignments_processor_examples' do
  let(:reassignment) {
    create(:nomenclature_change_reassignment,
      input: input,
      reassignable_type: 'Trade::Shipment'
    )
  }
  let!(:reassignment_target) {
    create(:nomenclature_change_reassignment_target,
      reassignment: reassignment,
      output: output
    )
  }
  before(:each) do
    2.times { create(:shipment, taxon_concept: input_species) }
    processor.run
  end
  specify { expect(output_species1.shipments.count).to eq(2) }
  specify { expect(input_species.shipments).to be_empty }
end
