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

class Trade::InclusionValidationRule < Trade::ValidationRule
  attr_accessible :valid_values_view

  def error_message(values_ary)
    column_names.each_with_index.map do |cn, idx|
      "#{cn} #{values_ary[idx]}"
    end.join(" with ") + ' is invalid'
  end

  def validation_errors(annual_report_upload)
    matching_records_grouped(annual_report_upload.sandbox.table_name).map do |mr|
      values_ary = column_names.map{ |cn| mr.send(cn) }
      Trade::ValidationError.new(
          :error_message => error_message(values_ary),
          :annual_report_upload_id => annual_report_upload.id,
          :validation_rule_id => self.id,
          :error_count => mr.error_count,
          :matching_records_ids => parse_pg_array(mr.matching_records_ids),
          :is_primary => self.is_primary
      )
    end
  end

  private
  # Returns matching records grouped by column_names to return the count of
  # specific errors and ids of matching records
  def matching_records_grouped(table_name)
    squished_column_names = column_names.map{ |c| "SQUISH(#{c})" }
    Trade::SandboxTemplate.
    select(
      squished_column_names.each_with_index.map { |c, idx| "#{c} AS #{column_names[idx]}"} +
      ['COUNT(*) AS error_count', 'ARRAY_AGG(id) AS matching_records_ids']
    ).from(Arel.sql("(#{matching_records_arel(table_name).to_sql}) AS matching_records")).
    group(squished_column_names).having(
      squished_column_names.map{ |cn| "#{cn} IS NOT NULL"}.join(' AND ')
    )
  end

  # Returns records from sandbox where values in column_names are not null
  # and not included in valid_values_view.
  # The valid_values_view should have the same column names and data types as
  # the sandbox columns specified in column_names.
  def matching_records_arel(table_name)
    s = Arel::Table.new(table_name)
    v = Arel::Table.new(valid_values_view)
    arel_nodes = column_names.map do |c|
      func =Arel::Nodes::NamedFunction.new 'squish', [s[c]]
      v[c].eq(func)
    end
    join_conditions = arel_nodes.shift
    arel_nodes.each{ |n| join_conditions = join_conditions.and(n) }
    valid_values = s.project(s['*']).join(v).on(join_conditions)
    not_null_nodes = column_names.map { |c| s[c].not_eq(nil).and(s[c].not_eq('')) }
    not_null_conds = not_null_nodes.shift
    not_null_nodes.each{ |n| not_null_conds = not_null_conds.and(n) }
    s.project('*').where(not_null_conds).except(valid_values)
  end

end
