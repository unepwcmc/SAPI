class Admin::GeoRelationshipsController < Admin::StandardAuthorizationController

  belongs_to :geo_entity
  before_filter :load_geo_relationship_types, :only => [:index, :create]
  before_filter :load_geo_entities, :only => [:index, :create]

  def index
    index! do
      @inverse_geo_relationships = GeoRelationship.where(:other_geo_entity_id => @geo_entity.id).page(params[:page])
    end
  end

  protected

  def load_geo_relationship_types
    @geo_relationship_type = GeoRelationshipType.find_by_name(
      params[:type] || GeoRelationshipType::CONTAINS
    )
    @geo_relationship_types = GeoRelationshipType.order(:name)
    @geo_relationship_types_for_dropdown = @geo_relationship_types.map do |t|
      { :value => t.id, :text => t.name }
    end
  end

  def load_geo_entities
    @geo_entities = GeoEntity.order(:geo_entity_type_id, :name_en)
    @geo_entities_for_dropdown = @geo_entities.map do |t|
      { :value => t.id, :text => t.name }
    end
  end

  def collection
    @geo_relationships ||= end_of_association_chain.
      joins(:geo_relationship_type).
      where(:"geo_relationship_types.name" => @geo_relationship_type.name).
      page(params[:page])
  end

end
