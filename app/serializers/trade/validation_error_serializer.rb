class Trade::ValidationErrorSerializer < ActiveModel::Serializer
  attributes :id, :error_message, :error_count, :is_primary,
    :is_ignored
end
