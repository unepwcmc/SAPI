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
    scope_info = sanitized_scope.map do |scope_column, scope_value|
      "#{scope_column} = #{scope_value}"
    end.compact.join(', ')
    info = column_names.each_with_index.map do |cn, idx|
      "#{cn} #{values_ary[idx]}"
    end.join(" with ")
    info = "#{info} (#{scope_info})" unless scope_info.blank?
    info + ' is invalid'
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

  # Sanitizes column names provided within the scope attribute
  # Also replaces attr_blank => true with attr => nil
  def sanitized_scope
    res = {}
    scope && scope.each do |scope_column, scope_value|
      scope_column =~ /(.+?)(_blank)?$/
      scope_column = $1
      scope_value = nil unless $2.nil? #if _blank, then check for null
      if (
        Trade::SandboxTemplate.column_names +
        ['point_of_view', 'importer', 'exporter']
      ).include? scope_column
        res[scope_column] = scope_value
      end
    end
    res
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
  # and optionally filtered down by specified scope
  # Pass Arel::Table
  def scoped_records_arel(s)
    not_null_nodes = column_names.map { |c| s[c].not_eq(nil).and(s[c].not_eq('')) }
    not_null_conds = not_null_nodes.shift
    not_null_nodes.each{ |n| not_null_conds = not_null_conds.and(n) }
    result = s.project('*').where(not_null_conds)
    scope_nodes = sanitized_scope.map do |scope_column, scope_value|
      s[scope_column].eq(scope_value)
    end
    scope_conds = scope_nodes.shift
    scope_nodes.each{ |n| scope_conds = scope_conds.and(n) }
    result = result.where(scope_conds) if scope_conds

    result
  end

  # Returns records from sandbox where values in column_names are not included
  # in valid_values_view.
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
    scoped_records_arel(s).except(valid_values)
  end

end
