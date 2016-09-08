shared_context 'output_legislation_reassignments_processor_examples' do
  let(:poland) {
    create(
      :geo_entity,
      geo_entity_type_id: country_geo_entity_type.id,
      iso_code2: 'PL'
    )
  }
  let(:portugal) {
    create(
      :geo_entity,
      geo_entity_type_id: country_geo_entity_type.id,
      iso_code2: 'PT'
    )
  }
  before(:each) do
    lc1_annotation = create(:annotation)
    lc1 = create_cites_III_addition(
      taxon_concept: old_output_subspecies,
      annotation: lc1_annotation,
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
      taxon_concept: old_output_subspecies,
      effective_at: '2013-01-02'
    )
    create(
      :listing_distribution,
      geo_entity: portugal,
      listing_change: lc2,
      is_party: true
    )
    quota = create(:quota, taxon_concept: old_output_subspecies, geo_entity: poland)
    quota.terms << create(:term)
    quota.sources << create(:source)
    quota.purposes << create(:purpose)
    quota = create(:quota, taxon_concept: old_output_subspecies, geo_entity: portugal)

    2.times { create(:cites_suspension, taxon_concept: old_output_subspecies) }
    create(
      :nomenclature_change_output_legislation_reassignment,
      output: output,
      reassignable_type: 'ListingChange'
    )
    create(
      :nomenclature_change_output_legislation_reassignment,
      output: output,
      reassignable_type: 'CitesSuspension'
    )
    create(
      :nomenclature_change_output_legislation_reassignment,
      output: output,
      reassignable_type: 'Quota'
    )
    output_processor.run
    processor.run
  end
  specify { expect(new_output_species.listing_changes.count).to eq(2) }
  specify {
    expect(
      new_output_species.listing_changes.
      find_by_effective_at_and_change_type_id('2013-01-01', cites_addition.id)
    ).not_to be_nil
  }
  specify {
    expect(
      new_output_species.listing_changes.
      find_by_effective_at_and_change_type_id('2013-01-01', cites_addition.id).
      party_listing_distribution.geo_entity
    ).to eq(poland)
  }
  specify {
    expect(
      new_output_species.listing_changes.
      find_by_effective_at_and_change_type_id('2013-01-01', cites_addition.id).
      listing_distributions
    ).to_not be_empty
  }
  specify {
    expect(
      new_output_species.listing_changes.
      find_by_effective_at_and_change_type_id('2013-01-01', cites_addition.id).
      annotation
    ).not_to be_nil
  }
  specify {
    expect(
      new_output_species.listing_changes.
      find_by_effective_at_and_change_type_id('2013-01-02', cites_addition.id)
    ).not_to be_nil
  }
  specify {
    expect(
      new_output_species.listing_changes.
      find_by_effective_at_and_change_type_id('2013-01-02', cites_addition.id).
      party_listing_distribution.geo_entity
    ).to eq(portugal)
  }
  specify { expect(new_output_species.quotas.count).to eq(2) }
  specify {
    expect(
      new_output_species.quotas.
      find_by_geo_entity_id(poland.id)
    ).not_to be_nil
  }
  specify {
    expect(
      new_output_species.quotas.
      find_by_geo_entity_id(poland.id).
      terms
    ).not_to be_empty
  }
  specify {
    expect(
      new_output_species.quotas.
      find_by_geo_entity_id(poland.id).
      sources
    ).not_to be_empty
  }
  specify {
    expect(
      new_output_species.quotas.
      find_by_geo_entity_id(poland.id).
      purposes
    ).not_to be_empty
  }
  specify { expect(new_output_species.cites_suspensions.count).to eq(2) }
  specify { expect(old_output_subspecies.listing_changes).to be_empty }
  specify { expect(old_output_subspecies.quotas).to be_empty }
  specify { expect(old_output_subspecies.cites_suspensions).to be_empty }
end
