require 'spec_helper'
describe GeoEntitySearch do

  describe :results do
    context "when searching by geo entity types set" do
      before(:each) do
        @asia = create(
          :geo_entity,
          geo_entity_type: cites_region_geo_entity_type,
          name_en: '2- Asia',
          name_es: '2- Asia',
          name_fr: '2- Asie'
        )
        @burma = create(
          :geo_entity,
          geo_entity_type: country_geo_entity_type,
          name_en: 'Burma',
          name_es: 'Birmania',
          name_fr: 'Birmanie',
          iso_code2: 'BU',
          is_current: false
        )
        @myanmar = create(
          :geo_entity,
          geo_entity_type: country_geo_entity_type,
          name_en: 'Myanmar',
          name_es: 'Myanmar',
          name_fr: 'Myanmar',
          iso_code2: 'MM'
        )
        @samoa = create(
          :geo_entity,
          geo_entity_type: territory_geo_entity_type,
          name_en: 'American Samoa',
          name_es: 'Samoa Americana',
          name_fr: 'Samoa américaines',
          iso_code2: 'AS'
        )
        @intro_from_the_sea = create(
          :geo_entity,
          geo_entity_type: trade_geo_entity_type,
          name_en: 'Introduction from the sea',
          name_es: 'Introducción procedente del mar',
          name_fr: 'Introduction en provenance de la mer',
          iso_code2: 'ZZ'
        )
      end
      context "default set" do
        context "default locale" do
          subject { GeoEntitySearch.new({}).results }
          specify { expect(subject).to include(@myanmar) }
          specify { expect(subject).not_to include(@burma) }
        end
      end
      context "Checklist regions (1)" do
        subject { GeoEntitySearch.new({ geo_entity_types_set: '1' }).results }
        specify { expect(subject).to include(@asia) }
        specify { expect(subject.length).to eq(1) }
      end
      context "Checklist countries & territories (2)" do
        subject { GeoEntitySearch.new({ geo_entity_types_set: '2' }).results }
        specify { expect(subject).not_to include(@asia) }
        specify { expect(subject).to include(@burma) }
        specify { expect(subject).to include(@myanmar) }
        specify { expect(subject).to include(@samoa) }
        specify { expect(subject).not_to include(@intro_from_the_sea) }
      end
      context "Species+ regions, countries & territories (3)" do
        context "English locale" do
          subject { GeoEntitySearch.new({ geo_entity_types_set: '3', locale: 'EN' }).results }
          specify { expect(subject).to include(@asia) }
          specify { expect(subject).not_to include(@burma) }
          specify { expect(subject).to include(@myanmar) }
          specify { expect(subject).not_to include(@intro_from_the_sea) }
          specify { expect(subject.index(@samoa)).to eq(1) }
          specify { expect(subject.index(@myanmar)).to eq(2) }
        end
        context "Spanish locale" do
          subject { GeoEntitySearch.new({ geo_entity_types_set: '3', locale: 'ES' }).results }
          specify { expect(subject).to include(@asia) }
          specify { expect(subject).not_to include(@burma) }
          specify { expect(subject).to include(@myanmar) }
          specify { expect(subject).not_to include(@intro_from_the_sea) }
          specify { expect(subject.index(@samoa)).to eq(2) }
          specify { expect(subject.index(@myanmar)).to eq(1) }
        end
      end
      context "Trade countries, territories and trade entities (4)" do
        subject { GeoEntitySearch.new({ geo_entity_types_set: '4' }).results }
        specify { expect(subject).not_to include(@asia) }
        specify { expect(subject).to include(@burma) }
        specify { expect(subject).to include(@myanmar) }
        specify { expect(subject).to include(@samoa) }
        specify { expect(subject).to include(@intro_from_the_sea) }
      end
    end
  end

  describe :cached_results do
    before(:each) do
      @burma = create(
        :geo_entity,
        geo_entity_type: country_geo_entity_type,
        name_en: 'Burma',
        iso_code2: 'BU'
      )
    end
    subject { GeoEntitySearch.new({ geo_entity_types_set: '3' }) }
    specify do
      subject.cached_results
      @burma.update_attributes({ is_current: false })
      expect(subject.cached_results).not_to include(@burma)
    end
  end
end
