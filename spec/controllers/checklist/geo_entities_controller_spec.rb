require 'spec_helper'

describe Checklist::GeoEntitiesController do
  let(:region){
    create(:geo_entity_type, :name => GeoEntityType::CITES_REGION)
  }
  let(:country){
    create(:geo_entity_type, :name => GeoEntityType::COUNTRY)
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
  describe "GET index" do
    it "returns CITES parties only" do
      get :index, :geo_entity_type => :country, :designation => :cites
      response.body.should have_json_size(1)
    end
    it "returns regions" do
      get :index, :geo_entity_type => :cites_region
      response.body.should have_json_size(1)
    end
    it "returns countries" do
      get :index, :geo_entity_type => :country
      response.body.should have_json_size(2)
    end
  end
end
