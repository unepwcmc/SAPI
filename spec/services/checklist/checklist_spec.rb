require 'spec_helper'

describe Checklist::ChecklistParams do
  default_sanitized = {
    authors: false,
    cites_appendices: [],
    cites_regions: [],
    countries: [],
    english_common_names: false,
    french_common_names: false,
    intro: false,
    level_of_listing: false,
    output_layout: :alphabetical,
    page: 1,
    per_page: 20,
    scientific_name: nil,
    spanish_common_names: false,
    synonyms: false
  }

  describe :sanitize do
    context 'when params empty' do
      specify do
        expect(
          Checklist::ChecklistParams.sanitize({})
        ).to match(
          default_sanitized
        )
      end
    end

    context 'when show_author = true' do
      specify do
        expect(
          Checklist::ChecklistParams.sanitize({ show_author: true })
        ).to match(
          default_sanitized.merge({ authors: true })
        )
      end
    end

    context 'when authors = true' do
      specify do
        expect(
          Checklist::ChecklistParams.sanitize({ authors: true })
        ).to match(
          default_sanitized.merge({ authors: true })
        )
      end
    end

    context 'Fully repeatable' do
      specify do
        first_iteration =
          Checklist::ChecklistParams.sanitize(
            authors: true,
            show_spanish: true,
            country_ids: [ 123, 234, 345 ]
          )

        expect(
          Checklist::ChecklistParams.sanitize(
            first_iteration
          )
        ).to match(
          first_iteration
        )
      end
    end
  end
end

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
      region_type = create(
        :geo_entity_type,
        name: 'REGION'
      )
      create(
        :geo_entity,
        geo_entity_type_id: region_type.id
      )
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
      region_type = create(
        :geo_entity_type,
        name: 'REGION'
      )
      region = create(
        :geo_entity,
        geo_entity_type_id: region_type.id
      )
      region2 = create(
        :geo_entity,
        geo_entity_type_id: region_type.id
      )
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
