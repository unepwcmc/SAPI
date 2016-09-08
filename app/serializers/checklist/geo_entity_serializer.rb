class Checklist::GeoEntitySerializer < ActiveModel::Serializer
  attributes :id, :name, :iso_code2, :is_current
end
