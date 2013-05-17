class Trade::InclusionValidationRule < Trade::ValidationRule
  validates :column_names, :presence => true, :uniqueness => {:scope => :valid_values_view}

  def matching_records(table_name)
    s = Arel::Table.new(table_name)
    v = Arel::Table.new(valid_values_view)
    valid_taxon_checks = s.project(s['*']).join(v).on(v[:taxon_check].eq(s[:taxon_check]))
    Trade::SandboxTemplate.find_by_sql(s.project('*').except(valid_taxon_checks).to_sql)
  end
end
