class Trade::InclusionValidationRule < Trade::ValidationRule
  attr_accessible :valid_values_view

  def error_message(values_ary)
    column_names.each_with_index.map do |cn, idx|
      "#{cn} #{values_ary[idx]}"
    end.join(" with ") + ' is invalid'
  end

  def validation_errors(annual_report_upload)
    uniq_matching_records = Trade::SandboxTemplate.select(column_names).uniq.
      from(
      Arel::SqlLiteral.new(
        '(' + matching_records_arel(annual_report_upload.sandbox.table_name).to_sql + ') AS matches'
      )
    )
    uniq_offending_values = uniq_matching_records.map do |r|
      column_names.map{ |cn| r.send(cn) }
    end
    uniq_offending_values.map do |values_ary|
      hash_conditions = Hash[column_names.zip(values_ary)]

      Trade::ValidationError.new(
          :error_message => error_message(values_ary),
          :annual_report_upload_id => annual_report_upload.id,
          :validation_rule_id => self.id,
          :error_count => 0, #TODO
          :matching_records_ids => [] #TODO
      )
    end
  end

  def matching_records(table_name)
    Trade::SandboxTemplate.from(matching_records_arel(table_name))
  end

  private
  # Returns records from sandbox where values in column_names are not included
  # in valid_values_view.
  # The valid_values_view should have the same column names and data types as
  # the sandbox columns specified in column_names.
  def matching_records_arel(table_name)
    s = Arel::Table.new(table_name)
    v = Arel::Table.new(valid_values_view)
    arel_nodes = column_names.map do |c|
      func =Arel::Nodes::NamedFunction.new 'btrim', [s[c]]
      v[c].eq(func)
    end
    join_conditions = arel_nodes.shift
    arel_nodes.each{ |n| join_conditions = join_conditions.and(n) }
    valid_values = s.project(s['*']).join(v).on(join_conditions)
    s.project('*').except(valid_values)
  end

  def value_matching_records_arel(table_name, hash_conditions)
    s = Arel::Table.new(table_name)
    arel_nodes = hash_conditions.map{ |c, v| s[c].eq(v)}
    arel_conditions = arel_nodes.shift
    arel_nodes.each{ |n| arel_conditions = arel_conditions.and(n) }
    s.project('*').where(arel_conditions)
  end

end
