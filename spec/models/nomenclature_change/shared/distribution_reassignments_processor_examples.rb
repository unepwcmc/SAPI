shared_context 'distribution_reassignments_processor_examples' do
  let(:reassignment) {
    create(:nomenclature_change_distribution_reassignment,
      input: input,
      reassignable_type: 'Distribution'
    )
  }
  let!(:reassignment_target) {
    create(:nomenclature_change_reassignment_target,
      reassignment: reassignment,
      output: output
    )
  }
  let(:poland) {
    create(
      :geo_entity,
      geo_entity_type_id: country_geo_entity_type.id,
      iso_code2: 'PL'
    )
  }
  let(:italy) {
    create(
      :geo_entity,
      geo_entity_type_id: country_geo_entity_type.id,
      iso_code2: 'IT'
    )
  }
  let(:united_kingdom) {
    create(
      :geo_entity,
      geo_entity_type_id: country_geo_entity_type.id,
      iso_code2: 'UK'
    )
  }
  before(:each) do
    original_d = create(
      :distribution,
      taxon_concept: output_species1,
      geo_entity: poland
    )
    original_d2 = create(
      :distribution,
      taxon_concept: output_species1,
      geo_entity: italy,
      tag_list: ['reintroduced']
    )
    original_d3 = create(
      :distribution,
      taxon_concept: output_species1,
      geo_entity: united_kingdom,
      tag_list: ['introduced']
    )
    original_d.distribution_references.create(reference_id: create(:reference).id)
    create(:preset_tag, model: 'Distribution', name: 'extinct')
    d = create(
      :distribution,
      taxon_concept: input_species,
      geo_entity: poland,
      tag_list: ['extinct']
    )
    d2 = create(
      :distribution,
      taxon_concept: input_species,
      geo_entity: italy,
      tag_list: ['extinct']
    )
    d3 = create(
      :distribution,
      taxon_concept: input_species,
      geo_entity: united_kingdom
    )
    d.distribution_references.create(reference_id: create(:reference).id)
    create(:distribution, taxon_concept: input_species)
    processor.run
  end
  specify { expect(output_species1.distributions.count).to eq(4) }
  specify { expect(output_species1.distributions.find_by_geo_entity_id(poland.id)).not_to be_nil }
  specify { expect(output_species1.distributions.find_by_geo_entity_id(poland.id).tag_list).to eq([]) }
  specify { expect(output_species1.distributions.find_by_geo_entity_id(italy.id).tag_list).to match_array(['extinct', 'reintroduced']) }
  specify { expect(output_species1.distributions.find_by_geo_entity_id(united_kingdom.id).tag_list).to eq([]) }
  specify { expect(output_species1.distributions.find_by_geo_entity_id(poland.id).distribution_references.count).to eq(2) }
end
