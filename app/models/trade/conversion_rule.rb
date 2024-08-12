# == Schema Information
#
# Table name: trade_conversion_rules
#
#  id            :bigint           not null, primary key
#  rule_input    :jsonb
#  rule_name     :string
#  rule_output   :jsonb
#  rule_priority :integer
#  rule_type     :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
# Indexes
#
#  index_trade_conversion_rules_on_rule_type_and_rule_priority  (rule_type,rule_priority) UNIQUE
#
class Trade::ConversionRule < ApplicationRecord
  # Populated exclusively by the application via a rake task
end
