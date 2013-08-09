class Species::EuDecisionSerializer < ActiveModel::Serializer
  attributes :start_date, :event_name,
    :geo_entity_name, :decision_type_name,
    :decision_type_tooltip, :is_current
end
