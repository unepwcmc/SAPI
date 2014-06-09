require 'spec_helper'

describe Checklist::GeoEntitiesController do
  let(:country){
    create(:geo_entity_type, :name => GeoEntityType::COUNTRY)
  }
  let!(:europe){
    create(
      :geo_entity,
      :geo_entity_type => cites_region_geo_entity_type,
      :name => 'Europe'
    )
  }
  let(:territory){
    create(:geo_entity_type, :name => GeoEntityType::TERRITORY)
  }
  let!(:france){
    create(
      :geo_entity,
      :geo_entity_type => country,
      :name => 'France',
      :iso_code2 => 'FR',
      :designations => [cites]
    )
  }
  let!(:andorra){
        create(
          :geo_entity,
          :geo_entity_type => country,
          :name => 'andorra',
          :iso_code2 => 'AD'
        )
  }
  let!(:french_guiana){
    create(
      :geo_entity,
      :geo_entity_type => territory,
      :name => 'French Guiana',
      :iso_code2 => 'GF',
      :designations => [cites]
    )
  }
  describe "GET index" do
    it "returns regions" do
      get :index, :geo_entity_types_set => "1"
      response.body.should have_json_size(1)
    end
    it "returns countries & territories" do
      get :index, :geo_entity_types_set => "2"
      response.body.should have_json_size(3)
    end
  end
end
