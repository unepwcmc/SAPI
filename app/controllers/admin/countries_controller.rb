class Admin::CountriesController < Admin::SimpleCrudController
  inherit_resources
  defaults :resource_class => GeoEntity, 
    :collection_name => 'geo_entities',
    :instance_name => 'geo_entity'

  def index
    @geo_entity_type = GeoEntityType.find_by_name(GeoEntityType::COUNTRY)
    index!
  end

  protected

  def collection
    @geo_entities ||= end_of_association_chain.
      joins(:geo_entity_type).
      where(:"geo_entity_types.name" => GeoEntityType::COUNTRY).
      order(:name_en).
      page(params[:page])
  end
end
