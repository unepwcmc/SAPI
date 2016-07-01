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

class Trade::DistinctValuesValidationRule < Trade::InclusionValidationRule

  # TODO: should have a validation for at least 2 column names

  def validation_errors_for_shipment(shipment)
    return nil unless shipment_in_scope?(shipment)
    # if it is, check if validated columns are not equal
    distinct_values = true
    shipments_columns.each do |c1|
      shipments_columns.each do |c2|
        distinct_values = false if c1 != c2 && shipment.send(c1) == shipment.send(c2)
      end
    end
    return nil if distinct_values
    error_message
  end

  private

  # Returns records that have the same value for both columns
  # specified in column_names. If more then 2 columns are specified,
  # only the first two are taken into consideration.
  def matching_records_arel(table_name)
    s = Arel::Table.new("#{table_name}_view")
    arel_columns = column_names.map { |c| Arel::Attribute.new(s, c) }
    Trade::SandboxTemplate.select('*').from("#{table_name}_view").where(
      arel_columns.shift.eq(arel_columns.shift)
    )
  end
end
