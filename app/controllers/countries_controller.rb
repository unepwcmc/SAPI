class CountriesController < ApplicationController
  def index
    render :json => GeoEntity.joins(:geo_entity_type).
      where(:"geo_entity_types.name" => 'COUNTRY').
      order(:name).all
  end
end
