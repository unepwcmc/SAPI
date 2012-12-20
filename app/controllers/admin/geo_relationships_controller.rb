class Admin::GeoRelationshipsController < Admin::SimpleCrudController
  inherit_resources
  belongs_to :geo_entity
  def index
    @geo_relationship_types = GeoRelationshipType.order(:name)
    @geo_entities = GeoEntity.order(:geo_entity_type_id, :name_en)
    index!
  end

  protected

  def collection
    @geo_relationships ||= end_of_association_chain.
      page(params[:page])
  end
end