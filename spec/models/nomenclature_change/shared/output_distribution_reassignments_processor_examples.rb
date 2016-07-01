shared_context 'output_distribution_reassignments_processor_examples' do
  let(:poland) {
    create(
      :geo_entity,
      geo_entity_type_id: country_geo_entity_type.id,
      iso_code2: 'PL'
    )
  }
  before(:each) do
    create(:preset_tag, model: 'Distribution', name: 'extinct')
    d = create(
      :distribution,
      taxon_concept: old_output_subspecies,
      geo_entity: poland,
      tag_list: ['extinct']
    )
    d.distribution_references.create(reference_id: create(:reference).id)
    create(:distribution, taxon_concept: old_output_subspecies)
    create(:nomenclature_change_output_distribution_reassignment,
      output: output,
      reassignable_type: 'Distribution'
    )
    output_processor.run
    processor.run
  end
  specify { expect(new_output_species.distributions.reload.count).to eq(2) }
  specify { expect(new_output_species.distributions.find_by_geo_entity_id(poland.id)).not_to be_nil }
  specify { expect(new_output_species.distributions.find_by_geo_entity_id(poland.id).tag_list).to eq(['extinct']) }
  specify { expect(new_output_species.distributions.find_by_geo_entity_id(poland.id).distribution_references.count).to eq(1) }
  specify { expect(old_output_subspecies.distributions).to be_empty }
end
