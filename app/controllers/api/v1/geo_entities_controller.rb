class Api::V1::GeoEntitiesController < ApplicationController

  def index
    geo_entity_type = (
      GeoEntityType.dict &
      [params[:geo_entity_type] && params[:geo_entity_type].upcase]
    ).first
    designation = (
      Designation.dict &
      [params[:designation] && params[:designation].upcase]
    ).first
    @geo_entities = GeoEntity.includes(:geo_entity_type).current.order(:name_en)
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
    render :json => @geo_entities,
      :each_serializer => Species::GeoEntitySerializer,
      :meta => {:total => @geo_entities.count}
  end

end
