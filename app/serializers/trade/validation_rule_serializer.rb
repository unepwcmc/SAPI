class Trade::ValidationRuleSerializer < ActiveModel::Serializer
  attributes :id,  :type, :column_names, :run_order, :created_at, :updated_at
end
