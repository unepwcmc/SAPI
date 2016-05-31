class Species::GeoEntitySerializer < ActiveModel::Serializer
  attributes :id, :name, :iso_code2, :geo_entity_type
  def geo_entity_type
    object.geo_entity_type.name
  end
end
