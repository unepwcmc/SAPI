class Api::V1::GeoEntitiesController < ApplicationController

  def index
    geo_entity_type = (['CITES_REGION', 'COUNTRY'] & [params[:geo_entity_type]]).first
    @geo_entities = GeoEntity.current.order(:name_en)
    if geo_entity_type
      @geo_entities = @geo_entities.
        joins(:geo_entity_type).
        where(:"geo_entity_types.name" => geo_entity_type)
    end
    render :json => @geo_entities.limit(10),
      :each_serializer => Species::GeoEntitySerializer,
      :meta => {:total => @geo_entities.count}
  end

end
