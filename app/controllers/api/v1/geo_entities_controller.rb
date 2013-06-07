class Api::V1::GeoEntitiesController < ApplicationController

  def index
    geo_entity_type = params[:geo_entity_type] || 'COUNTRY'
    @geo_entities = GeoEntity.
      select([:"geo_entities.id", :"geo_entities.name_en", :"geo_entities.iso_code2"]).
      joins(:geo_entity_type).
      where(:"geo_entity_types.name" => geo_entity_type).
      current.
      order(:name_en)
    render :json => @geo_entities.limit(10),
      :each_serializer => Species::GeoEntitySerializer,
      :meta => {:total => @geo_entities.count}
  end

end
