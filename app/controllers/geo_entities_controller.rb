class GeoEntitiesController < ApplicationController
  def index
    render :json => GeoEntity.joins(:geo_entity_type).
      where(:"geo_entity_types.name" => params[:geo_entity_type]).
      order(:name).all
  end
end
