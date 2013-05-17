class Trade::ValidationRuleSerializer < ActiveModel::Serializer
  attributes :id,  :type, :column_names, :valid_values_view, :created_at, :updated_at
end
