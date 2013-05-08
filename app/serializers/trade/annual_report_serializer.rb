class Trade::AnnualReportSerializer < ActiveModel::Serializer
  attributes :id, :geo_entity_id, :year
end
