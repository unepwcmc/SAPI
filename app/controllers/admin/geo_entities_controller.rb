class Admin::GeoEntitiesController < Admin::SimpleCrudController
  inherit_resources

  def index
    @geo_entity_type = GeoEntityType.find_by_name(params[:type])
    @geo_entity_types = GeoEntityType.order(:name)
    index!
  end

  protected

  def collection
    @geo_entities ||= end_of_association_chain.
      joins(:geo_entity_type).
      where(:"geo_entity_types.name" => params[:type]).
      order(:name_en).
      page(params[:page])
  end
end
