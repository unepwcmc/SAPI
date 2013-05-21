class Trade::ValidationRuleSerializer < ActiveModel::Serializer
  attributes :id,  :type, :column_names, :created_at, :updated_at
end
