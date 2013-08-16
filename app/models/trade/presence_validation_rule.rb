# == Schema Information
#
# Table name: trade_validation_rules
#
#  id                :integer          not null, primary key
#  valid_values_view :string(255)
#  type              :string(255)      not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  format_re         :string(255)
#  run_order         :integer          not null
#  column_names      :string(255)
#

class Trade::PresenceValidationRule < Trade::ValidationRule
  #validates :column_names, :uniqueness => true

  def error_message
    column_names.join(', ') + ' cannot be blank'
  end

  private
  # Returns records where the specified columns are NULL.
  # In case more than one column is specified, predicates are combined
  # using AND.
  def matching_records(table_name)
    s = Arel::Table.new(table_name)
    arel_nodes = column_names.map{|c| s[c].eq(nil)}
    conditions = arel_nodes.shift
    arel_nodes.each{ |n| conditions = conditions.and(n) }
    Trade::SandboxTemplate.select('*').from(table_name).where(conditions)
  end
end
