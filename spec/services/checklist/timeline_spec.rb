require 'spec_helper'

describe Checklist::Timeline do
  context "when deleted" do
    let(:tc) {
      tc = create_cites_eu_species
      create_cites_I_addition(
        :taxon_concept => tc,
        :effective_at => '1975-06-06',
        :is_current => false
      )
      create_cites_I_deletion(
        :taxon_concept => tc,
        :effective_at => '1975-06-07',
        :is_current => false
      )
      SapiModule::StoredProcedures.rebuild_cites_taxonomy_and_listings
      MTaxonConcept.find(tc.id)
    }
    let(:ttc) { Checklist::TimelinesForTaxonConcept.new(tc) }
    let(:subject) { ttc.timelines.first }

    specify { expect(subject.timeline_intervals.count).to eq(1) }
    specify { expect(subject.timeline_intervals.last.end_pos).to be < 1 }
    specify { expect(subject.timeline_events.count).to eq(2) }
  end

  context "when deleted from III multiple times" do
    let(:tc) {
      tc = create_cites_eu_species
      cnt1 = create(:geo_entity)
      cnt2 = create(:geo_entity)
      lc1 = create_cites_III_addition(
        :taxon_concept => tc,
        :effective_at => '1975-06-06',
        :is_current => false
      )
      create(
        :listing_distribution,
        :geo_entity => cnt1,
        :listing_change => lc1,
        :is_party => true
      )
      lc2 = create_cites_III_addition(
        :taxon_concept => tc,
        :effective_at => '1975-06-06',
        :is_current => false
      )
      create(
        :listing_distribution,
        :geo_entity => cnt2,
        :listing_change => lc2,
        :is_party => true
      )
      lc3 = create_cites_III_deletion(
        :taxon_concept => tc,
        :effective_at => '1975-06-07',
        :is_current => false
      )
      create(
        :listing_distribution,
        :geo_entity => cnt1,
        :listing_change => lc3,
        :is_party => true
      )
      lc4 = create_cites_III_deletion(
        :taxon_concept => tc,
        :effective_at => '1975-06-08',
        :is_current => false
      )
      create(
        :listing_distribution,
        :geo_entity => cnt2,
        :listing_change => lc4,
        :is_party => true
      )
      SapiModule::StoredProcedures.rebuild_cites_taxonomy_and_listings
      MTaxonConcept.find(tc.id)
    }
    let(:ttc) { Checklist::TimelinesForTaxonConcept.new(tc) }
    let(:subject) { ttc.timelines.last }

    specify { expect(subject.timeline_intervals.count).to eq(3) }
    specify { expect(subject.timeline_intervals.last.end_pos).to be < 1 }
    specify { expect(subject.timeline_events.count).to eq(4) }
  end

  context "when deleted and then readded" do
    let(:tc) {
      tc = create_cites_eu_species
      create_cites_I_addition(
        :taxon_concept => tc,
        :effective_at => '1975-06-06',
        :is_current => false
      )
      create_cites_I_deletion(
        :taxon_concept => tc,
        :effective_at => '1975-06-07',
        :is_current => false
      )
      create_cites_I_addition(
        :taxon_concept => tc,
        :effective_at => '1975-06-08',
        :is_current => true
      )
      SapiModule::StoredProcedures.rebuild_cites_taxonomy_and_listings
      MTaxonConcept.find(tc.id)
    }
    let(:ttc) { Checklist::TimelinesForTaxonConcept.new(tc) }
    let(:subject) { ttc.timelines.first }

    specify { expect(subject.timeline_intervals.count).to eq(2) }
    specify { expect(subject.timeline_events.count).to eq(3) }
    specify { expect(subject.timeline_intervals[0].end_pos).to eq(subject.timeline_intervals[1].start_pos) }
  end

  context "when reservation withdrawn" do
    let(:tc) {
      tc = create_cites_eu_species
      create_cites_I_addition(
        :taxon_concept => tc,
        :effective_at => '1975-06-06',
        :is_current => true
      )
      cnt = create(:geo_entity, geo_entity_type: country_geo_entity_type)
      r1 = create_cites_I_reservation(
        :taxon_concept => tc,
        :effective_at => '1975-06-06',
        :is_current => false
      )
      create(
        :listing_distribution,
        :geo_entity => cnt,
        :listing_change => r1,
        :is_party => true
      )
      w = create_cites_I_reservation_withdrawal(
        :taxon_concept => tc,
        :effective_at => '1976-06-07',
        :is_current => false
      )
      create(
        :listing_distribution,
        :geo_entity => cnt,
        :listing_change => w,
        :is_party => true
      )
      SapiModule::StoredProcedures.rebuild_cites_taxonomy_and_listings
      MTaxonConcept.find(tc.id)
    }
    let(:ttc) { Checklist::TimelinesForTaxonConcept.new(tc) }
    let(:subject) { ttc.timelines.first.timelines.first }

    specify { expect(subject.timeline_intervals.count).to eq(1) }
    specify { expect(subject.timeline_events.count).to eq(2) }
    specify { expect(subject.timeline_intervals[0].end_pos).to eq(subject.timeline_events[1].pos) }
  end

  context "when reservation withdrawn and then readded" do
    let(:tc) {
      tc = create_cites_eu_species
      cnt = create(:geo_entity, geo_entity_type: country_geo_entity_type)
      r1 = create_cites_III_reservation(
        :taxon_concept => tc,
        :effective_at => '1975-06-06',
        :is_current => false
      )
      create(
        :listing_distribution,
        :geo_entity => cnt,
        :listing_change => r1,
        :is_party => true
      )
      w = create_cites_III_reservation_withdrawal(
        :taxon_concept => tc,
        :effective_at => '1976-06-07',
        :is_current => false
      )
      create(
        :listing_distribution,
        :geo_entity => cnt,
        :listing_change => w,
        :is_party => true
      )
      r2 = create_cites_III_reservation(
        :taxon_concept => tc,
        :effective_at => '1977-06-06',
        :is_current => true
      )
      create(
        :listing_distribution,
        :geo_entity => cnt,
        :listing_change => r2,
        :is_party => true
      )
      SapiModule::StoredProcedures.rebuild_cites_taxonomy_and_listings
      MTaxonConcept.find(tc.id)
    }
    let(:ttc) { Checklist::TimelinesForTaxonConcept.new(tc) }
    let(:subject) { ttc.timelines.last.timelines.first }

    specify { expect(subject.timeline_intervals.count).to eq(2) }
    specify { expect(subject.timeline_events.count).to eq(3) }
    specify { expect(subject.timeline_intervals[0].end_pos).to eq(subject.timeline_events[1].pos) }
    specify { expect(subject.timeline_intervals[1].end_pos).to eq(1) }
  end

  context "when added multiple times" do
    let(:tc) {
      tc = create_cites_eu_species
      create_cites_I_addition(
        :taxon_concept => tc,
        :effective_at => '1975-06-06',
        :is_current => false
      )
      create_cites_I_addition(
        :taxon_concept => tc,
        :effective_at => '1975-06-08',
        :is_current => true
      )
      SapiModule::StoredProcedures.rebuild_cites_taxonomy_and_listings
      MTaxonConcept.find(tc.id)
    }
    let(:ttc) { Checklist::TimelinesForTaxonConcept.new(tc) }
    let(:subject) { ttc.timelines.first }

    specify {
      expect(subject.timeline_events.map(&:change_type_name)).to eq(
        ['ADDITION', 'AMENDMENT']
      )
    }
    specify { expect(subject.timeline_intervals.count).to eq(2) }
    specify { expect(subject.timeline_intervals[1].end_pos).to eq(1) }
  end

  context "when automatic deletion from ancestor listing" do
    let(:tc) {
      genus = create_cites_eu_genus
      tc = create_cites_eu_species(parent: genus)
      create_cites_I_addition(
        :taxon_concept => genus,
        :effective_at => '1975-06-06',
        :is_current => true
      )
      create_cites_II_addition(
        :taxon_concept => tc,
        :effective_at => '1976-06-08',
        :is_current => true
      )
      # tc should have a cascaded ADD I from parent and an auto DEL I
      SapiModule::StoredProcedures.rebuild_cites_taxonomy_and_listings
      MTaxonConcept.find(tc.id)
    }
    let(:ttc) { Checklist::TimelinesForTaxonConcept.new(tc) }
    let(:subject) { ttc.timelines.first }

    specify {
      expect(subject.timeline_events.map(&:change_type_name)).to eq(
        ['ADDITION', 'DELETION']
      )
    }
    specify { expect(subject.timeline_intervals.count).to eq(1) }
    specify { expect(subject.timeline_intervals[0].end_pos).to eq(subject.timeline_events[1].pos) }
  end

end
