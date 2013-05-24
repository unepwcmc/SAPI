# == Schema Information
#
# Table name: trade_validation_rules
#
#  id                :integer          not null, primary key
#  column_names      :string(255)      not null
#  valid_values_view :string(255)
#  type              :string(255)      not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  format_re         :string(255)
#

class Trade::FormatValidationRule < Trade::ValidationRule
  attr_accessible :format_re
  # Returns records that do not pass the regex test for all columns
  # specified in column_names.
  def matching_records(table_name)
    s = Arel::Table.new(table_name)
    arel_nodes = column_names.map{ |c| "#{c} !~ '#{format_re}'" }
    conditions = arel_nodes.shift
    arel_nodes.each{ |n| conditions = conditions.or(n) }
    Trade::SandboxTemplate.select('*').from(table_name).where(conditions)
  end
end
