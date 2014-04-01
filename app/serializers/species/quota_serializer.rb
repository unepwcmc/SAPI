class Species::QuotaSerializer < ActiveModel::Serializer
  attributes :quota, :year, {:publication_date_formatted => :publication_date},
    :notes, :url, :public_display, :is_current, :unit_name, :subspecies_info

  has_one :geo_entity, :serializer => Species::GeoEntitySerializer

  def quota
    if object.quota == -1
      "in prep."
    else
      object.quota
    end
  end
end
