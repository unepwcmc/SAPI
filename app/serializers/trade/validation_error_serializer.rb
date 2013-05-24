class Trade::ValidationErrorSerializer < ActiveModel::Serializer
  attributes :id, :error_message, :error_count, :sandbox_shipment_ids
end
