class Trade::ShipmentApiFromViewSerializer < ActiveModel::Serializer
  attributes :id

  def id
    object.id || object.shipment_id
  end
end
