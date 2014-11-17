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
#  is_primary        :boolean          default(TRUE), not null
#  scope             :hstore
#  is_strict         :boolean          default(FALSE), not null
#

class Trade::PresenceValidationRule < Trade::ValidationRule
  #validates :column_names, :uniqueness => true

  def error_message
    column_names.join(', ') + ' cannot be blank'
  end

  # Returns records where the specified columns are NULL.
  # In case more than one column is specified, predicates are combined
  # using AND.
  def matching_records(table_name)
    s = Arel::Table.new(table_name)
    arel_nodes = column_names.map do |c|
      s[c].eq(nil)
    end
    Trade::SandboxTemplate.select('*').from(table_name).where(arel_nodes.inject(&:and))
  end
end
