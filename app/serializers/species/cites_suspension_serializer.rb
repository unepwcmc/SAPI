class Species::CitesSuspensionSerializer < ActiveModel::Serializer
  attributes :notes, {:start_date_formatted => :start_date}, 
    {:publication_date_formatted => :publication_date},
    :url, {:end_date_formatted => :end_date}, :is_current
  has_one :geo_entity, :serializer => Species::GeoEntitySerializer
end

