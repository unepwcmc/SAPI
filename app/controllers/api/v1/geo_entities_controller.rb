class Api::V1::GeoEntitiesController < ApplicationController
  caches_action :index, :cache_path => Proc.new { |c|
    { :geo_entity_types_set => GeoEntityType::DEFAULT_SET, :locale => "en" }.
      merge(c.params.select{|k,v| !v.blank? && ["geo_entity_types_set", "locale"].include?(k)})
  }

  # TODO refactor this into a search class with low level caching
  # needs to handle both geo entity types selection and is_current
  # perhaps a visibility parameter (e.g. checklist, s+, admin trade)
  def index
    locale = params['locale'] || I18n.locale
    geo_entity_types_set = GeoEntityType::SETS.has_key?(params[:geo_entity_types_set]) &&
      params[:geo_entity_types_set] || GeoEntityType::DEFAULT_SET
    geo_entity_types = GeoEntityType::SETS[geo_entity_types_set]
    @geo_entities = GeoEntity.includes(:geo_entity_type).order("name_#{locale}")
    if GeoEntityType::CURRENT_ONLY_SETS.include?(geo_entity_types_set)
      @geo_entities = @geo_entities.current
    end
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
