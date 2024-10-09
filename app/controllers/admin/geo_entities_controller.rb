class Admin::GeoEntitiesController < Admin::StandardAuthorizationController
  before_action :load_geo_entity_types, only: [ :index, :create ]

  def index
    index! do |format|
      @geo_entity = GeoEntity.new(is_current: true)
    end
  end

protected

  def load_geo_entity_types
    @geo_entity_type = GeoEntityType.find_by(
      name: params[:type] || GeoEntityType::COUNTRY
    )
    @geo_entity_types = GeoEntityType.order(:name)
    @geo_entity_types_for_dropdown =
      @geo_entity_types.map do |t|
        { value: t.id, text: t.name }
      end
  end

  def collection
    @geo_entities ||= end_of_association_chain.joins(
      :geo_entity_type
    ).where(
      'geo_entity_types.name': @geo_entity_type.name
    ).order(
      :name_en
    ).page(
      params[:page]
    ).search(
      params[:query]
    )
  end

private

  def geo_entity_params
    params.require(:geo_entity).permit(
      # attributes were in model `attr_accessible`.
      :geo_entity_type_id, :iso_code2, :iso_code3,
      :legacy_id, :legacy_type, :long_name, :name_en, :name_es, :name_fr,
      :is_current
    )
  end
end
