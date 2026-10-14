class Species::GeoEntitySerializer < ActiveModel::Serializer
  attributes :id, :name, :iso_code2, :iso_code3, :geo_entity_type, :designations
  def geo_entity_type
    object.geo_entity_type.name
  end

  # The conventions this geo entity is a Party to, e.g. so the NDF tool can say
  # when a country is not a Party to CITES or CMS. Callers preload
  # :designations - one query per geo entity otherwise.
  def designations
    object.designations.sort_by(&:id).map { |designation| { id: designation.id, name: designation.name } }
  end
end
