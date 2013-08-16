class Species::CitesSuspensionSerializer < ActiveModel::Serializer
  attributes :notes, {:start_date_formatted => :start_date},
    :is_current, :subspecies_info
  has_one :geo_entity, :serializer => Species::GeoEntitySerializer
  has_one :start_notification, :serializer => Species::EventSerializer
end

