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
#

class Trade::PresenceValidationRule < Trade::ValidationRule
  #validates :column_names, :uniqueness => true

  def error_message
    column_names.join(', ') + ' cannot be blank'
  end

  private
  # Returns a hash with column values to be used to select invalid rows.
  # For presence validation this will be simply a pair
  # of validated field => nil.
  # e.g.
  # {
  #    :taxon_name => nil
  # }
  # Expects a single grouped matching record.
  def error_selector(matching_records)
    res = {}
    column_names.each do |cn|
      res[cn] = nil if matching_records.select(cn).count > 0
    end
    res
  end

  # Returns records where the specified columns are NULL.
  # In case more than one column is specified, predicates are combined
  # using AND.
  def matching_records(table_name)
    s = Arel::Table.new(table_name)
    arel_nodes = column_names.map do |c|
      s[c].eq(nil)
    end
    conditions = arel_nodes.shift
    arel_nodes.each{ |n| conditions = conditions.and(n) }
    Trade::SandboxTemplate.select('*').from(table_name).where(conditions)
  end
end
