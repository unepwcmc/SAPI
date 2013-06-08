#TODO remove this once Checklist is upgraded to use the API
class Checklist::GeoEntitiesController < ApplicationController
  caches_action :index

  #override the serializer by using render :text, old ember-data won't handle json root
  def index
    geo_entity_type = (
      GeoEntityType.dict &
      [params[:geo_entity_type] && params[:geo_entity_type].upcase]
    ).first
    designation = (
      Designation.dict &
      [params[:designation] && params[:designation].upcase]
    ).first
    @geo_entities = GeoEntity.current.order(:name_en)
    if geo_entity_type
      @geo_entities = @geo_entities.
        joins(:geo_entity_type).
        where(:"geo_entity_types.name" => geo_entity_type)
    end
    if designation
      @geo_entities = @geo_entities.
        joins(:designations).
        where(:"designations.name" => designation)
    end
    render :text => @geo_entities.to_json
  end

end
