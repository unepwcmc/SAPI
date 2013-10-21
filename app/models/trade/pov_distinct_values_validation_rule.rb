class Trade::PovDistinctValuesValidationRule < Trade::ValidationRule

  # TODO should have a validation for at least 2 column names

  def error_message
    column_names.join(', ') + ' should not be equal'
  end

  private
  # Returns records that have the same value for both columns
  # specified in column_names. If more then 2 columns are specified,
  # only the first two are taken into consideration.
  def matching_records(table_name)
    s = Arel::Table.new("#{table_name}_view")
    arel_columns = column_names.map{ |c| Arel::Attribute.new(s, c) }
    Trade::SandboxTemplate.select('*').from("#{table_name}_view").where(
      arel_columns.shift.eq(arel_columns.shift)
    )
  end
end
