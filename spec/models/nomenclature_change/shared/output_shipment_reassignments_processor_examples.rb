shared_context 'output_shipment_reassignments_processor_examples' do
  before(:each) do
    create(:nomenclature_change_output_reassignment,
      output: output,
      reassignable_type: 'Trade::Shipment'
    )
    2.times { create(:shipment, taxon_concept: old_output_subspecies) }
    output_processor.run
    processor.run
  end
  specify { expect(new_output_species.shipments.count).to eq(2) }
  specify { expect(old_output_subspecies.shipments).to be_empty }
end
