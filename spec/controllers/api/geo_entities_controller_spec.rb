require 'spec_helper'

describe Api::V1::GeoEntitiesController do
  let(:region){
    create(:geo_entity_type, :name => GeoEntityType::CITES_REGION)
  }
  let(:country){
    create(:geo_entity_type, :name => GeoEntityType::COUNTRY)
  }
  let(:territory){
    create(:geo_entity_type, :name => GeoEntityType::TERRITORY)
  }
  let!(:europe){
    create(
      :geo_entity,
      :geo_entity_type => region,
      :name => 'Europe'
    )
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
    it "returns CITES parties only" do
      get :index, :geo_entity_type => :country, :designation => :cites
      response.body.should have_json_size(1).at_path('geo_entities')
    end
    it "returns regions" do
      get :index, :geo_entity_type => :cites_region
      response.body.should have_json_size(1).at_path('geo_entities')
    end
    it "returns countries" do
      get :index, :geo_entity_type => :country
      response.body.should have_json_size(2).at_path('geo_entities')
    end
    it "returns countries & territories" do
      get :index, :geo_entity_types => [:country, :territory]
      response.body.should have_json_size(3).at_path('geo_entities')
    end
  end
end
