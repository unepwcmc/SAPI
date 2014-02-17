#TODO remove this once Checklist is upgraded to use the API
class Checklist::GeoEntitiesController < ApplicationController
  caches_action :index, :cache_path => Proc.new { |c|
    { :geo_entity_types_set => GeoEntityType::DEFAULT_SET, :locale => "en" }.
      merge(c.params.select{|k,v| ["geo_entity_types_set", "locale"].include?(k)})
  }

  #override the serializer by using render :text, old ember-data won't handle json root
  def index
    geo_entity_types = if params[:geo_entity_types_set] &&
      GeoEntityType::SETS.has_key?(params[:geo_entity_types_set])
                         GeoEntityType::SETS[params[:geo_entity_types_set]]
                       else
                         GeoEntityType::SETS[GeoEntityType::DEFAULT_SET]
                       end
    @geo_entities = GeoEntity.current.order(:"name_#{I18n.locale}")
    unless geo_entity_types.empty?
      @geo_entities = @geo_entities.
        joins(:geo_entity_type).
        where(:"geo_entity_types.name" => geo_entity_types)
    end
    render :text => @geo_entities.to_json
  end

end
