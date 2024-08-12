shared_context 'legislation_reassignments_processor_examples' do
  let(:poland) do
    create(
      :geo_entity,
      geo_entity_type_id: country_geo_entity_type.id,
      iso_code2: 'PL'
    )
  end
  let(:portugal) do
    create(
      :geo_entity,
      geo_entity_type_id: country_geo_entity_type.id,
      iso_code2: 'PT'
    )
  end
  before(:each) do
    lc1_annotation = create(:annotation)
    original_lc1 = create_cites_III_addition(
      taxon_concept: output_species1,
      annotation: lc1_annotation,
      effective_at: '2013-01-01'
    )
    create(
      :listing_distribution,
      geo_entity: poland,
      listing_change: original_lc1,
      is_party: true
    )
    create(
      :listing_distribution,
      geo_entity: portugal,
      listing_change: original_lc1,
      is_party: false
    )
    lc1 = create_cites_III_addition(
      taxon_concept: input_species,
      annotation: lc1_annotation,
      effective_at: '2013-01-01'
    )
    lc1_exc = create_cites_III_exception(
      parent_id: lc1.id,
      taxon_concept: create_cites_eu_subspecies(parent: input_species),
      effective_at: '2013-01-01'
    )
    create(
      :listing_distribution,
      geo_entity: poland,
      listing_change: lc1,
      is_party: true
    )
    create(
      :listing_distribution,
      geo_entity: poland,
      listing_change: lc1,
      is_party: false
    )
    lc2 = create_cites_III_addition(
      taxon_concept: input_species,
      effective_at: '2013-01-02'
    )
    create(
      :listing_distribution,
      geo_entity: portugal,
      listing_change: lc2,
      is_party: true
    )
    quota = create(:quota, taxon_concept: input_species, geo_entity: poland)
    quota.terms << create(:term)
    quota.sources << create(:source)
    quota.purposes << create(:purpose)
    quota = create(:quota, taxon_concept: input_species, geo_entity: portugal)

    2.times { create(:cites_suspension, taxon_concept: input_species) }

    create(:nomenclature_change_reassignment_target,
      reassignment: create(
        :nomenclature_change_legislation_reassignment,
        input: input,
        reassignable_type: 'ListingChange'
      ),
      output: output
    )
    create(:nomenclature_change_reassignment_target,
      reassignment: create(
        :nomenclature_change_legislation_reassignment,
        input: input,
        reassignable_type: 'CitesSuspension'
      ),
      output: output
    )
    create(:nomenclature_change_reassignment_target,
      reassignment: create(
        :nomenclature_change_legislation_reassignment,
        input: input,
        reassignable_type: 'Quota'
      ),
      output: output
    )
    processor.run
  end
  specify { expect(output_species1.listing_changes.count).to eq(2) }
  specify do
    expect(
      output_species1.listing_changes.
      find_by(effective_at: '2013-01-01', change_type_id: cites_addition.id)
    ).not_to be_nil
  end
  specify do
    expect(
      output_species1.listing_changes.
      find_by(effective_at: '2013-01-01', change_type_id: cites_addition.id).
      party_listing_distribution.geo_entity
    ).to eq(poland)
  end
  specify do
    expect(
      output_species1.listing_changes.
      find_by(effective_at: '2013-01-01', change_type_id: cites_addition.id).
      listing_distributions.count
    ).to eq(2)
  end
  specify do
    expect(
      output_species1.listing_changes.
      find_by(effective_at: '2013-01-01', change_type_id: cites_addition.id).
      annotation
    ).not_to be_nil
  end
  specify do
    expect(
      output_species1.listing_changes.
      find_by(effective_at: '2013-01-01', change_type_id: cites_addition.id).
      exclusions
    ).not_to be_empty
  end
  specify do
    expect(
      output_species1.listing_changes.
      find_by(effective_at: '2013-01-02', change_type_id: cites_addition.id)
    ).not_to be_nil
  end
  specify do
    expect(
      output_species1.listing_changes.
      find_by(effective_at: '2013-01-02', change_type_id: cites_addition.id).
      party_listing_distribution.geo_entity
    ).to eq(portugal)
  end
  specify { expect(output_species1.quotas.count).to eq(2) }
  specify do
    expect(
      output_species1.quotas.
      find_by(geo_entity_id: poland.id)
    ).not_to be_nil
  end
  specify do
    expect(
      output_species1.quotas.
      find_by(geo_entity_id: poland.id).
      terms
    ).not_to be_empty
  end
  specify do
    expect(
      output_species1.quotas.
      find_by(geo_entity_id: poland.id).
      sources
    ).not_to be_empty
  end
  specify do
    expect(
      output_species1.quotas.
      find_by(geo_entity_id: poland.id).
      purposes
    ).not_to be_empty
  end
  specify { expect(output_species1.cites_suspensions.count).to eq(2) }
end
