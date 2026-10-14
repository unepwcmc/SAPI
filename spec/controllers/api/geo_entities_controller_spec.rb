require 'spec_helper'

describe Api::V1::GeoEntitiesController do
  let!(:europe) do
    create(
      :geo_entity,
      geo_entity_type: cites_region_geo_entity_type,
      name: 'Europe'
    )
  end
  let!(:france) do
    create(
      :geo_entity,
      geo_entity_type: country_geo_entity_type,
      name: 'France',
      iso_code2: 'FR',
      designations: [ cites ]
    )
  end
  let!(:andorra) do
    create(
      :geo_entity,
      geo_entity_type: country_geo_entity_type,
      name: 'andorra',
      iso_code2: 'AD'
    )
  end
  let!(:french_guiana) do
    create(
      :geo_entity,
      geo_entity_type: territory_geo_entity_type,
      name: 'French Guiana',
      iso_code2: 'GF',
      designations: [ cites ]
    )
  end
  describe 'GET index' do
    def designations_of(geo_entity)
      response.parsed_body['geo_entities'].find { |json| json['id'] == geo_entity.id }['designations']
    end

    it 'returns regions' do
      get :index, params: { geo_entity_types_set: '1' }
      expect(response.body).to have_json_size(1).at_path('geo_entities')
    end
    it 'returns countries & territories' do
      get :index, params: { geo_entity_types_set: '2' }
      expect(response.body).to have_json_size(3).at_path('geo_entities')
    end

    it 'returns the designations a geo entity is a Party to' do
      get :index, params: { geo_entity_types_set: '2' }
      expect(designations_of(france)).to eq [ { 'id' => cites.id, 'name' => 'CITES' } ]
    end

    it 'returns no designations for a geo entity that is a Party to none' do
      get :index, params: { geo_entity_types_set: '2' }
      expect(designations_of(andorra)).to eq []
    end

    context 'with the search cached' do
      # The test environment's cache is a null store, under which nothing is
      # ever cached.
      before { allow(Rails).to receive(:cache).and_return(ActiveSupport::Cache::MemoryStore.new) }

      it 'serves the designations from the cache' do
        get :index, params: { geo_entity_types_set: '2' }
        DesignationGeoEntity.where(geo_entity: france).delete_all # skips callbacks, so clears nothing
        get :index, params: { geo_entity_types_set: '2' }
        expect(designations_of(france)).to eq [ { 'id' => cites.id, 'name' => 'CITES' } ]
      end

      it 'serves new designations once one changes' do
        get :index, params: { geo_entity_types_set: '2' }
        DesignationGeoEntity.where(geo_entity: france).destroy_all
        get :index, params: { geo_entity_types_set: '2' }
        expect(designations_of(france)).to eq []
      end
    end
  end
end
