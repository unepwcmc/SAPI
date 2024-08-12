require 'spec_helper'

describe Checklist::GeoEntitiesController do
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
    it 'returns regions' do
      get :index, params: { geo_entity_types_set: '1' }
      expect(response.body).to have_json_size(1)
    end
    it 'returns countries & territories' do
      get :index, params: { geo_entity_types_set: '2' }
      expect(response.body).to have_json_size(3)
    end
  end
end
