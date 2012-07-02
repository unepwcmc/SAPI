class GeoEntitiesController < ApplicationController
  def index
    render :json => GeoEntity.
      select([:"geo_entities.id", :"geo_entities.name"]).
      joins(:geo_entity_type).
      where(:"geo_entity_types.name" => params[:geo_entity_type]).
      order(:name).all
  end
end
