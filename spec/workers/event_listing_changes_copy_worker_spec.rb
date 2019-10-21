require 'spec_helper'

describe EventListingChangesCopyWorker do
  let(:prev_eu_regulation) {
    create_eu_regulation(
      :name => 'REGULATION 1.0',
      :designation => eu,
      :is_current => true
    )
  }
  let(:eu_regulation) {
    create_eu_regulation(
      :name => 'REGULATION 2.0',
      :listing_changes_event_id => prev_eu_regulation.id,
      :designation => eu,
      :is_current => true
    )
  }
  let(:species) {
    create_cites_eu_species
  }
  let(:subspecies) {
    create_cites_eu_subspecies(parent: species)
  }
  let!(:listing_change) {
    create_eu_A_addition(
      :event_id => prev_eu_regulation.id,
      :taxon_concept_id => species.id
    )
  }

  context "when copy into non-current regulation" do
    let(:eu_regulation) {
      create_eu_regulation(
        :name => 'REGULATION 2.0',
        :listing_changes_event_id => prev_eu_regulation.id,
        :designation => eu,
        :is_current => false
      )
    }
    before { EventListingChangesCopyWorker.new.perform(prev_eu_regulation.id, eu_regulation.id) }
    specify { eu_regulation.listing_changes.reload.count.should == 1 }
    specify { eu_regulation.listing_changes.first.is_current.should be_falsey }
  end

  context "when copy into current regulation" do
    before { EventListingChangesCopyWorker.new.perform(prev_eu_regulation.id, eu_regulation.id) }
    specify { eu_regulation.listing_changes.reload.count.should == 1 }
    specify { eu_regulation.listing_changes.first.is_current.should be_truthy }
  end

  context "when exclusion" do
    let!(:taxonomic_exclusion) {
      create_eu_A_exception(
        :parent_id => listing_change.id,
        :taxon_concept_id => subspecies.id
      )
    }
    let!(:geographic_exclusion) {
      create_eu_A_exception(
        :parent_id => listing_change.id,
        :taxon_concept_id => species.id
      )
    }
    let!(:exclusion_distribution) {
      create(:listing_distribution, listing_change_id: geographic_exclusion.id)
    }

    before { EventListingChangesCopyWorker.new.perform(prev_eu_regulation.id, eu_regulation.id) }
    specify { eu_regulation.listing_changes.reload.count.should == 1 }
    specify { eu_regulation.listing_changes.first.exclusions.count.should == 2 }
    specify { eu_regulation.listing_changes.first.taxonomic_exclusions.count.should == 1 }
    specify { eu_regulation.listing_changes.first.geographic_exclusions.count.should == 1 }
  end

end
