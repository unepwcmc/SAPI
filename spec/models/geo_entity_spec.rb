# == Schema Information
#
# Table name: geo_entities
#
#  id                 :integer          not null, primary key
#  is_current         :boolean          default(TRUE)
#  iso_code2          :string(255)
#  iso_code3          :string(255)
#  legacy_type        :string(255)
#  long_name          :string(255)
#  name_en            :string(255)      not null
#  name_es            :string(255)
#  name_fr            :string(255)
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  geo_entity_type_id :integer          not null
#  legacy_id          :integer
#
# Indexes
#
#  index_geo_entities_on_geo_entity_type_id  (geo_entity_type_id)
#  index_geo_entities_on_iso_code2           (iso_code2) UNIQUE WHERE (iso_code2 IS NOT NULL)
#  index_geo_entities_on_iso_code3           (iso_code3) UNIQUE WHERE (iso_code3 IS NOT NULL)
#
# Foreign Keys
#
#  geo_entities_geo_entity_type_id_fk  (geo_entity_type_id => geo_entity_types.id)
#

require 'spec_helper'

describe GeoEntity do
  describe :nodes_and_descendants do
    let(:europe) do
      create(
        :geo_entity,
        geo_entity_type: cites_region_geo_entity_type,
        name: 'Europe'
      )
    end
    let(:poland) do
      create(
        :geo_entity,
        geo_entity_type: country_geo_entity_type,
        name: 'Poland',
        iso_code2: 'PL'
      )
    end
    let(:wolin) do
      create(
        :geo_entity,
        geo_entity_type: territory_geo_entity_type,
        name: 'Wolin'
      )
    end
    context 'Europe should contain Europe, Poland and Wolin' do
      let!(:poland_contains_wolin) do
        create(
          :geo_relationship,
          geo_relationship_type: contains_geo_relationship_type,
          geo_entity: poland,
          related_geo_entity: wolin
        )
      end
      let!(:europe_contains_poland) do
        create(
          :geo_relationship,
          geo_relationship_type: contains_geo_relationship_type,
          geo_entity: europe,
          related_geo_entity: poland
        )
      end
      subject { GeoEntity.nodes_and_descendants([ europe.id ]) }
      specify { expect(subject.map(&:id)).to include(europe.id, poland.id, wolin.id) }
      specify { expect(subject.size).to eq(3) }
    end
  end
  describe :destroy do
    let(:geo_entity) { create(:geo_entity) }
    context 'when no dependent objects attached' do
      specify { expect(geo_entity.destroy).to be_truthy }
    end
    context 'when dependent objects attached' do
      context 'when distributions' do
        before(:each) { create(:distribution, geo_entity: geo_entity) }
        specify { expect(geo_entity.destroy).to be_falsey }
      end
      context 'when exported shipments' do
        before(:each) { create(:shipment, exporter: geo_entity) }
        specify { expect(geo_entity.destroy).to be_falsey }
      end
      context 'when imported shipments' do
        before(:each) { create(:shipment, importer: geo_entity) }
        specify { expect(geo_entity.destroy).to be_falsey }
      end
      context 'when originated shipments' do
        before(:each) { create(:shipment, country_of_origin: geo_entity) }
        specify { expect(geo_entity.destroy).to be_falsey }
      end
      context 'when connected geo entities' do
        let(:child_geo_entity) { create(:geo_entity) }
        before(:each) do
          create(
            :geo_relationship,
            geo_relationship_type: contains_geo_relationship_type,
            geo_entity: geo_entity,
            related_geo_entity: child_geo_entity
          )
        end
        specify { expect(geo_entity.destroy).to be_falsey }
      end
    end
  end
end
