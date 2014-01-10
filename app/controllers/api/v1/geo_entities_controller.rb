class Api::V1::GeoEntitiesController < ApplicationController
  caches_action :index, :cache_path => Proc.new { |c|
    { :geo_entity_types_set => GeoEntityType::DEFAULT_SET, :locale => "en" }.
      merge(c.params.select{|k,v| ["geo_entity_types_set", "locale"].include?(k)})
  }

  def index
    locale = params['locale'] || I18n.locale
    geo_entity_types = if params[:geo_entity_types_set]
                         GeoEntityType::SETS[params[:geo_entity_types_set]]
                       else
                         GeoEntityType::SETS[GeoEntityType::DEFAULT_SET]
                       end
    @geo_entities = GeoEntity.includes(:geo_entity_type).current.order("name_#{locale}")
    unless geo_entity_types.empty?
      @geo_entities = @geo_entities.
        joins(:geo_entity_type).
        where(:"geo_entity_types.name" => geo_entity_types)
    end
    render :json => @geo_entities,
      :each_serializer => Species::GeoEntitySerializer,
      :meta => {:total => @geo_entities.count}
  end

end
