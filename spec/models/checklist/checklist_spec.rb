require 'spec_helper'

describe Checklist::Checklist do

  describe :summarise_filters do
    context "when params empty" do
      let(:summary) {
        Checklist::Checklist.summarise_filters({})
      }
      specify {
        summary.should == "All results"
      }
    end
  end
  context "when 1 region" do
    let(:region) {
      region_type = create(:geo_entity_type,
                           :name => 'REGION')
      create(:geo_entity,
            :geo_entity_type_id => region_type.id)
    }
    let(:summary) {
      Checklist::Checklist.summarise_filters({ :cites_region_ids => [region.id] })
    }
    specify {
      summary.should == "Results from 1 region"
    }
  end
  context "when > 1 region" do
    let(:regions) {
      region_type = create(:geo_entity_type,
                           :name => 'REGION')
      region = create(:geo_entity,
            :geo_entity_type_id => region_type.id)
      region2 = create(:geo_entity,
            :geo_entity_type_id => region_type.id)
      [region.id, region2.id]
    }
    let(:summary) {
      Checklist::Checklist.summarise_filters({ :cites_region_ids => regions })
    }
    specify {
      summary.should == "Results from 2 regions"
    }
  end
end
