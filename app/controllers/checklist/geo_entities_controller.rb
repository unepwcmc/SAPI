#TODO remove this once Checklist is upgraded to use the API
class Checklist::GeoEntitiesController < ApplicationController
  caches_action :index, :cache_path => Proc.new { |c| c.params }
  cache_sweeper :geo_entity_sweeper

  #override the serializer by using render :text, old ember-data won't handle json root
  def index
    geo_entity_types = (
      if params[:geo_entity_types]
        params[:geo_entity_types].map(&:upcase)
      else
        [params[:geo_entity_type] && params[:geo_entity_type].upcase]
      end
    ).compact & GeoEntityType.dict
    designation = (
      Designation.dict &
      [params[:designation] && params[:designation].upcase]
    ).first
    @geo_entities = GeoEntity.current.order(:"name_#{I18n.locale}")
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
    render :text => @geo_entities.to_json
  end

end
