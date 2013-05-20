class Trade::InclusionValidationRule < Trade::ValidationRule
  validates :column_names, :uniqueness => {:scope => :valid_values_view}

  # Returns records from sandbox where values in column_names are not included
  # in valid_values_view.
  # The valid_values_view should have the same column names and data types as
  # the sandbox columns specified in column_names.
  def matching_records(table_name)
    s = Arel::Table.new(table_name)
    v = Arel::Table.new(valid_values_view)
    valid_taxon_checks = s.project(s['*']).join(v).on(v[:taxon_check].eq(s[:taxon_check]))
    Trade::SandboxTemplate.find_by_sql(s.project('*').except(valid_taxon_checks).to_sql)
  end
end
