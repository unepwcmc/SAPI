class Api::V1::GeoEntitiesController < ApplicationController

  def index
    @geo_entities = GeoEntitySearch.new(
      params.slice(:geo_entity_types_set, :locale)
    ).cached_results
    render :json => @geo_entities,
      :each_serializer => Species::GeoEntitySerializer,
      :meta => { :total => @geo_entities.count }
  end

end
