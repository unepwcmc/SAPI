require 'spec_helper'

describe Trade::GeoEntitiesController do
  let(:country){
    create(:geo_entity_type, :name => GeoEntityType::COUNTRY)
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
      get :index
      response.body.should have_json_size(1)
    end
  end
end
