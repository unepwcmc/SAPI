class Api::V1::GeoEntitiesController < ApplicationController
  caches_action :index, :cache_path => Proc.new { |c| c.params.select{ |k,v|
    ["geo_entity_types_set", "locale"].include?(k)
  }}
  cache_sweeper :geo_entity_sweeper

  def index
    locale = params['locale'] || I18n.locale
    geo_entity_types = (
      if params[:geo_entity_types_set]
        GeoEntityType::SETS[params[:geo_entity_types_set]]
      else
        [params[:geo_entity_type] && params[:geo_entity_type].upcase]
      end
    ).compact & GeoEntityType.dict
    designation = (
      Designation.dict &
      [params[:designation] && params[:designation].upcase]
    ).first
    @geo_entities = GeoEntity.includes(:geo_entity_type).current.order("name_#{locale}")
    unless geo_entity_types.empty?
      @geo_entities = @geo_entities.
        joins(:geo_entity_type).
        where(:"geo_entity_types.name" => geo_entity_types)
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
