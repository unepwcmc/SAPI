require 'spec_helper'

describe Checklist::TimelinesForTaxonConcept do
  before do
    travel_to Time.zone.local(1990)
  end

  after do
  end

  describe :timelines do
    context 'when Appendix I' do
      let(:tc) do
        tc = create_cites_eu_species
        create_cites_I_addition(
          taxon_concept: tc,
          effective_at: '1975-06-06',
          is_current: true
        )
        SapiModule::StoredProcedures.rebuild_cites_taxonomy_and_listings
        MTaxonConcept.find(tc.id)
      end
      subject { Checklist::TimelinesForTaxonConcept.new(tc) }
      specify { expect(subject.raw_timelines['I'].timeline_events).not_to be_empty }
      specify { expect(subject.raw_timelines['II'].timeline_events).to be_empty }
    end
    context 'when Appendix III' do
      let(:tc) do
        tc = create_cites_eu_species
        lc = create_cites_III_addition(
          taxon_concept: tc,
          effective_at: '1975-06-06',
          is_current: true
        )
        create(
          :listing_distribution,
          geo_entity: create(:geo_entity),
          listing_change: lc,
          is_party: true
        )
        SapiModule::StoredProcedures.rebuild_cites_taxonomy_and_listings
        MTaxonConcept.find(tc.id)
      end
      subject { Checklist::TimelinesForTaxonConcept.new(tc) }
      specify { expect(subject.raw_timelines['III'].timeline_events).not_to be_empty }
      specify { expect(subject.raw_timelines['I'].timeline_events).to be_empty }
    end
    context 'when Appendix III reservation' do
      let(:tc) do
        tc = create_cites_eu_species
        lc = create_cites_III_reservation(
          taxon_concept: tc,
          effective_at: '1975-06-06',
          is_current: true
        )
        create(
          :listing_distribution,
          geo_entity: create(:geo_entity),
          listing_change: lc,
          is_party: true
        )
        SapiModule::StoredProcedures.rebuild_cites_taxonomy_and_listings
        MTaxonConcept.find(tc.id)
      end
      subject { Checklist::TimelinesForTaxonConcept.new(tc) }
      specify { expect(subject.raw_timelines['III'].timeline_events).to be_empty }
      specify { expect(subject.raw_timelines['III'].timelines.first.timeline_events).not_to be_empty }
      specify { expect(subject.raw_timelines['I'].timeline_events).to be_empty }
    end
  end

  describe :timeline_years do
    context 'when in 1990' do
      let(:tc) do
        tc = create(:taxon_concept)
        SapiModule::StoredProcedures.rebuild_cites_taxonomy_and_listings
        MTaxonConcept.find(tc.id)
      end
      subject { Checklist::TimelinesForTaxonConcept.new(tc).timeline_years }
      specify { expect(subject.size).to eq(5) }
      specify { expect(subject.first.year).to eq(1975) }
      specify { expect(subject.last.year).to eq(1995) }
    end
  end
end
