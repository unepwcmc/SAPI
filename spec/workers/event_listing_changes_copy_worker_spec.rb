require 'spec_helper'

describe EventListingChangesCopyWorker do
  let(:prev_eu_regulation) do
    create_eu_regulation(
      name: 'REGULATION 1.0',
      designation: eu,
      is_current: true
    )
  end
  let(:eu_regulation) do
    create_eu_regulation(
      name: 'REGULATION 2.0',
      listing_changes_event_id: prev_eu_regulation.id,
      designation: eu,
      is_current: true
    )
  end
  let(:species) do
    create_cites_eu_species
  end
  let(:subspecies) do
    create_cites_eu_subspecies(parent: species)
  end
  let!(:listing_change) do
    create_eu_A_addition(
      event_id: prev_eu_regulation.id,
      taxon_concept_id: species.id
    )
  end

  context 'when copy into non-current regulation' do
    let(:eu_regulation) do
      create_eu_regulation(
        name: 'REGULATION 2.0',
        listing_changes_event_id: prev_eu_regulation.id,
        designation: eu,
        is_current: false
      )
    end
    before { EventListingChangesCopyWorker.new.perform(prev_eu_regulation.id, eu_regulation.id) }
    specify { expect(eu_regulation.listing_changes.reload.count).to eq(1) }
    specify { expect(eu_regulation.listing_changes.first.is_current).to be_falsey }
  end

  context 'when copy into current regulation' do
    before { EventListingChangesCopyWorker.new.perform(prev_eu_regulation.id, eu_regulation.id) }
    specify { expect(eu_regulation.listing_changes.reload.count).to eq(1) }
    specify { expect(eu_regulation.listing_changes.first.is_current).to be_truthy }
  end

  context 'when exclusion' do
    let!(:taxonomic_exclusion) do
      create_eu_A_exception(
        parent_id: listing_change.id,
        taxon_concept_id: subspecies.id
      )
    end
    let!(:geographic_exclusion) do
      create_eu_A_exception(
        parent_id: listing_change.id,
        taxon_concept_id: species.id
      )
    end
    let!(:exclusion_distribution) do
      create(:listing_distribution, listing_change_id: geographic_exclusion.id)
    end

    before { EventListingChangesCopyWorker.new.perform(prev_eu_regulation.id, eu_regulation.id) }
    specify { expect(eu_regulation.listing_changes.reload.count).to eq(1) }
    specify { expect(eu_regulation.listing_changes.first.exclusions.count).to eq(2) }
    specify { expect(eu_regulation.listing_changes.first.taxonomic_exclusions.count).to eq(1) }
    specify { expect(eu_regulation.listing_changes.first.geographic_exclusions.count).to eq(1) }
  end
end
