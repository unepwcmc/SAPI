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

class Trade::InclusionValidationRule < Trade::ValidationRule
  attr_accessible :valid_values_view
  # Returns records from sandbox where values in column_names are not included
  # in valid_values_view.
  # The valid_values_view should have the same column names and data types as
  # the sandbox columns specified in column_names.
  def matching_records(table_name)
    s = Arel::Table.new(table_name)
    v = Arel::Table.new(valid_values_view)
    arel_nodes = column_names.map do |c|
      func =Arel::Nodes::NamedFunction.new 'btrim', [s[c]]
      v[c].eq(func)
    end
    join_conditions = arel_nodes.shift
    arel_nodes.each{ |n| join_conditions = join_conditions.and(n) }
    valid_values = s.project(s['*']).join(v).on(join_conditions)
    puts s.project('*').except(valid_values).to_sql
    Trade::SandboxTemplate.find_by_sql(s.project('*').except(valid_values).to_sql)
  end
end
