class Species::EuDecisionSerializer < ActiveModel::Serializer
  attributes :notes, {:start_date_formatted => :start_date},
    :is_current, :subspecies_info

  has_one :eu_decision_type, :serializer => Species::EuDecisionTypeSerializer
  has_one :geo_entity, :serializer => Species::GeoEntitySerializer
  has_one :start_event, :serializer => Species::EventSerializer
  has_one :source, :serializer => Species::TradeCodeSerializer
  has_one :term, :serializer => Species::TradeCodeSerializer
end
