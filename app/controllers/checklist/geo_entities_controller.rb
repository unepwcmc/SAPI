class Checklist::GeoEntitiesController < ApplicationController

  #override the serializer by using render :text, old ember-data won't handle json root
  def index
    @geo_entities = GeoEntitySearch.new(
      params.slice(:geo_entity_types_set, :locale)
    ).results
    render :text => @geo_entities.to_json
  end

end
