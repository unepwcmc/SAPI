class Trade::PresenceValidationRule < Trade::ValidationRule
  #validates :column_names, :uniqueness => true

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
