shared_context 'distribution_reassignments_processor_examples' do
  let(:reassignment){
    create(:nomenclature_change_distribution_reassignment,
      input: input,
      reassignable_type: 'Distribution'
    )
  }
  let!(:reassignment_target){
    create(:nomenclature_change_reassignment_target,
      reassignment: reassignment,
      output: output
    )
  }
  let(:poland){
    create(
      :geo_entity,
      geo_entity_type_id: country_geo_entity_type.id,
      iso_code2: 'PL'
    )
  }
  before(:each) do
    original_d = create(
      :distribution,
      taxon_concept: output_species1,
      geo_entity: poland
    )
    original_d.distribution_references.create(reference_id: create(:reference).id)
    create(:preset_tag, model: 'Distribution', name: 'extinct')
    d = create(
      :distribution,
      taxon_concept: input_species,
      geo_entity: poland,
      tag_list: ['extinct']
    )
    d.distribution_references.create(reference_id: create(:reference).id)
    create(:distribution, taxon_concept: input_species)
    processor.run
  end
  specify{ expect(output_species1.distributions.count).to eq(2) }
  specify{ expect(output_species1.distributions.find_by_geo_entity_id(poland.id)).not_to be_nil }
  specify{ expect(output_species1.distributions.find_by_geo_entity_id(poland.id).tag_list).to eq(['extinct']) }
  specify{ expect(output_species1.distributions.find_by_geo_entity_id(poland.id).distribution_references.count).to eq(2) }
end
