require 'spec_helper'

describe Checklist::TimelinesForTaxonConcept do
  before do
    Timecop.freeze(Time.local(1990))
  end

  after do
    Timecop.return
  end

  describe :timelines do
    context "when Appendix I" do
      let(:tc) {
        tc = create_cites_eu_species
        create_cites_I_addition(
          :taxon_concept => tc,
          :effective_at => '1975-06-06',
          :is_current => true
        )
        Sapi::StoredProcedures.rebuild_cites_taxonomy_and_listings
        MTaxonConcept.find(tc.id)
      }
      subject { Checklist::TimelinesForTaxonConcept.new(tc) }
      specify { subject.raw_timelines['I'].timeline_events.should_not be_empty }
      specify { subject.raw_timelines['II'].timeline_events.should be_empty }
    end
    context "when Appendix III" do
      let(:tc) {
        tc = create_cites_eu_species
        lc = create_cites_III_addition(
          :taxon_concept => tc,
          :effective_at => '1975-06-06',
          :is_current => true
        )
        create(
          :listing_distribution,
          :geo_entity => create(:geo_entity),
          :listing_change => lc,
          :is_party => true
        )
        Sapi::StoredProcedures.rebuild_cites_taxonomy_and_listings
        MTaxonConcept.find(tc.id)
      }
      subject { Checklist::TimelinesForTaxonConcept.new(tc) }
      specify { subject.raw_timelines['III'].timeline_events.should_not be_empty }
      specify { subject.raw_timelines['I'].timeline_events.should be_empty }
    end
    context "when Appendix III reservation" do
      let(:tc) {
        tc = create_cites_eu_species
        lc = create_cites_III_reservation(
          :taxon_concept => tc,
          :effective_at => '1975-06-06',
          :is_current => true
        )
        create(
          :listing_distribution,
          :geo_entity => create(:geo_entity),
          :listing_change => lc,
          :is_party => true
        )
        Sapi::StoredProcedures.rebuild_cites_taxonomy_and_listings
        MTaxonConcept.find(tc.id)
      }
      subject { Checklist::TimelinesForTaxonConcept.new(tc) }
      specify { subject.raw_timelines['III'].timeline_events.should be_empty }
      specify { subject.raw_timelines['III'].timelines.first.timeline_events.should_not be_empty }
      specify { subject.raw_timelines['I'].timeline_events.should be_empty }
    end
  end

  describe :timeline_years do
    context "when in 1990" do
      let(:tc) {
        tc = create(:taxon_concept)
        Sapi::StoredProcedures.rebuild_cites_taxonomy_and_listings
        MTaxonConcept.find(tc.id)
      }
      subject { Checklist::TimelinesForTaxonConcept.new(tc).timeline_years }
      specify { subject.size.should == 5 }
      specify { subject.first.year.should == 1975 }
      specify { subject.last.year.should == 1995 }
    end
  end

end
