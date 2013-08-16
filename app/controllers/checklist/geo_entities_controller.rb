#TODO remove this once Checklist is upgraded to use the API
class Checklist::GeoEntitiesController < ApplicationController
  caches_action :index, :cache_path => Proc.new { |c|
    c.params.select { |k,v| ['geo_entity_type', 'designation'].include? k }
  }

  #override the serializer by using render :text, old ember-data won't handle json root
  def index
    geo_entity_types = (
      GeoEntityType.dict &
      (
        if params[:geo_entity_types] 
          params[:geo_entity_types].map(&:upcase)
        else
          [params[:geo_entity_type] && params[:geo_entity_type].upcase]
        end
      )
    )
    designation = (
      Designation.dict &
      [params[:designation] && params[:designation].upcase]
    ).first
    @geo_entities = GeoEntity.current.order(:name_en)
    if geo_entity_types
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
