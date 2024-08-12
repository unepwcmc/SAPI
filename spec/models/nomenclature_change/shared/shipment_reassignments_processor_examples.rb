shared_context 'shipment_reassignments_processor_examples' do
  let(:reassignment) do
    create(:nomenclature_change_reassignment,
      input: input,
      reassignable_type: 'Trade::Shipment'
    )
  end
  let!(:reassignment_target) do
    create(:nomenclature_change_reassignment_target,
      reassignment: reassignment,
      output: output
    )
  end
  before(:each) do
    2.times { create(:shipment, taxon_concept: input_species) }
    processor.run
  end
  specify { expect(output_species1.shipments.count).to eq(2) }
  specify { expect(input_species.shipments).to be_empty }
end
