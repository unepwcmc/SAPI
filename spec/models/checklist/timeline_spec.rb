require 'spec_helper'

describe Checklist::Timeline do
  context "when deleted" do
    let(:tc){
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
      eu
      cms_designation
      Sapi.rebuild
      MTaxonConcept.find(tc.id)
    }
    let(:ttc){ Checklist::TimelinesForTaxonConcept.new(tc)}
    let(:subject){ ttc.timelines.first }

    specify{ subject.timeline_intervals.count.should == 1 }
    specify{ subject.timeline_intervals.last.end_pos.should < 1 }
    specify{ subject.timeline_events.count.should == 2 }
  end

  context "when deleted from III multiple times" do
    let(:tc){
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
      eu
      cms_designation
      Sapi.rebuild
      MTaxonConcept.find(tc.id)
    }
    let(:ttc){ Checklist::TimelinesForTaxonConcept.new(tc)}
    let(:subject){ ttc.timelines.last }

    specify{ subject.timeline_intervals.count.should == 3 }
    pending{ subject.timeline_intervals.last.end_pos.should < 1 }
    pending{ subject.timeline_events.count.should == 4 }
  end

  context "when deleted and then readded" do
    let(:tc){
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
      eu
      cms_designation
      Sapi.rebuild
      MTaxonConcept.find(tc.id)
    }
    let(:ttc){ Checklist::TimelinesForTaxonConcept.new(tc)}
    let(:subject){ ttc.timelines.first }

    pending{ subject.timeline_intervals.count.should == 2 }
    pending{ subject.timeline_events.count.should == 3 }
  end

  context "when added multiple times" do
    let(:tc){
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
      eu
      cms_designation
      Sapi.rebuild
      MTaxonConcept.find(tc.id)
    }
    let(:ttc){ Checklist::TimelinesForTaxonConcept.new(tc)}
    let(:subject){ ttc.timelines.first }

    specify{
      subject.timeline_events.map(&:change_type_name).should ==
        ['ADDITION', 'AMENDMENT']
    }
  end

end
