require 'spec_helper'

describe Checklist::Checklist do
  describe :summarise_filters do
    context 'when params empty' do
      let(:summary) do
        Checklist::Checklist.summarise_filters({})
      end
      specify do
        expect(summary).to eq('All results')
      end
    end
  end
  context 'when 1 region' do
    let(:region) do
      region_type = create(:geo_entity_type,
        name: 'REGION')
      create(:geo_entity,
        geo_entity_type_id: region_type.id)
    end
    let(:summary) do
      Checklist::Checklist.summarise_filters({ cites_region_ids: [ region.id ] })
    end
    specify do
      expect(summary).to eq('Results from 1 region')
    end
  end
  context 'when > 1 region' do
    let(:regions) do
      region_type = create(:geo_entity_type,
        name: 'REGION')
      region = create(:geo_entity,
        geo_entity_type_id: region_type.id)
      region2 = create(:geo_entity,
        geo_entity_type_id: region_type.id)
      [ region.id, region2.id ]
    end
    let(:summary) do
      Checklist::Checklist.summarise_filters({ cites_region_ids: regions })
    end
    specify do
      expect(summary).to eq('Results from 2 regions')
    end
  end
end
