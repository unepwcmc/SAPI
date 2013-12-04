class Trade::PermitSerializer < ActiveModel::Serializer
  attributes :id, :number, :geo_entity_id
end
