shared_context 'legislation_reassignments_processor_examples' do
  let(:reassignment){
    create(:nomenclature_change_legislation_reassignment,
      :input => input,
      :reassignable_type => 'ListingChange'
    )
  }
  let!(:reassignment_target){
    create(:nomenclature_change_reassignment_target,
      :reassignment => reassignment,
      :output => output
    )
  }
  before(:each) do
    create_cites_I_addition(:taxon_concept => input_species)
    create_cites_II_addition(:taxon_concept => input_species)
    processor.run
  end
  specify{ expect(output_species1.listing_changes.count).to eq(2) }
end
