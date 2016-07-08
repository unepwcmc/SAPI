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

class Trade::NumericalityValidationRule < Trade::ValidationRule

  def error_message
    column_names.join(', ') + ' must be a number'
  end

  private

  # Returns records that do not pass the ISNUMERIC test for all columns
  # specified in column_names.
  def matching_records(annual_report_upload)
    table_name = annual_report_upload.sandbox.table_name
    sandbox_klass = Trade::SandboxTemplate.ar_klass(table_name)
    s = Arel::Table.new(table_name)
    arel_columns = column_names.map { |c| Arel::Attribute.new(s, c) }
    isnumeric_columns = arel_columns.map do |a|
      Arel::Nodes::NamedFunction.new 'isnumeric', [a]
    end
    arel_nodes = isnumeric_columns.map { |c| c.eq(false) }
    sandbox_klass.select('*').where(arel_nodes.inject(&:or))
  end
end
