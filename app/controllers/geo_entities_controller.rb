class GeoEntitiesController < ApplicationController
  caches_action :index

  def index
    render :json => GeoEntity.
      select([:"geo_entities.id", :"geo_entities.name_en", :"geo_entities.iso_code2"]).
      joins(:geo_entity_type).
      where(:"geo_entity_types.name" => params[:geo_entity_type]).
      current.
      order(:name_en).all
  end
end
