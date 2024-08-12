# == Schema Information
#
# Table name: trade_validation_rules
#
#  id                :integer          not null, primary key
#  column_names      :string(255)      is an Array
#  format_re         :string(255)
#  is_primary        :boolean          default(TRUE), not null
#  is_strict         :boolean          default(FALSE), not null
#  run_order         :integer          not null
#  scope             :hstore
#  type              :string(255)      not null
#  valid_values_view :string(255)
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

class Trade::FormatValidationRule < Trade::ValidationRule
  # Only created by seed.
  # attr_accessible :format_re

  def error_message
    column_names.join(', ') + ' must be formatted as ' + format_re
  end

  private

  # Returns records that do not pass the regex test for all columns
  # specified in column_names.
  def matching_records(annual_report_upload)
    table_name = annual_report_upload.sandbox.table_name
    sandbox_klass = Trade::SandboxTemplate.ar_klass(table_name)
    s = Arel::Table.new(table_name)
    arel_nodes = column_names.map { |c| "#{c} !~ '#{format_re}'" }
    sandbox_klass.select(Arel.star).where(arel_nodes.inject(&:or))
  end
end
