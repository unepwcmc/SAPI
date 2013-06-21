class Species::QuotaSerializer < ActiveModel::Serializer
  attributes :quota, :year, {:publication_date_formatted => :publication_date},
    :notes, :url, :public_display, :is_current, :unit_name

  has_one :geo_entity, :serializer => Species::GeoEntitySerializer
end
