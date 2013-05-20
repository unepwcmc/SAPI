class Trade::FormatValidationRule < Trade::ValidationRule

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
