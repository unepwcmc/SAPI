class Admin::GeoEntitiesController < Admin::SimpleCrudController

  before_filter :load_geo_entity_types, :only => [:index, :create]

  def autocomplete
    render :json => GeoEntity.
      select([:"geo_entities.id", :"geo_entities.name_en", :"geo_entities.iso_code2"]).
      where("geo_entities.name_en ILIKE '#{params[:name]}%'").
      current.
      order(:name_en).
      limit(5)
  end

  protected

  def load_geo_entity_types
    @geo_entity_type = GeoEntityType.find_by_name(
      params[:type] || GeoEntityType::COUNTRY
    )
    @geo_entity_types = GeoEntityType.order(:name)
    @geo_entity_types_for_dropdown = @geo_entity_types.map do |t|
      {:value => t.id, :text => t.name}
    end
  end

  def collection
    @geo_entities ||= end_of_association_chain.
      joins(:geo_entity_type).
      where(:"geo_entity_types.name" => @geo_entity_type.name).
      order(:name_en).
      page(params[:page])
  end
end
