class Trade::GeoEntitiesController < ApplicationController

  def index
    render :json => GeoEntity.
      select([:"geo_entities.id", :"geo_entities.name_en", :"geo_entities.iso_code2"]).
      joins(:geo_entity_type).
      where(:"geo_entity_types.name" => [GeoEntityType::COUNTRY]).
      joins(:designations).where(:"designations.name" => Designation::CITES).
      current.
      order(:name_en).all
  end

end
