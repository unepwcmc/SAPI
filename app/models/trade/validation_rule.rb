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
#

class Trade::ValidationRule < ActiveRecord::Base
  attr_accessible :column_names, :run_order, :is_primary, :scope
  include PgArrayParser
  serialize :scope, ActiveRecord::Coders::Hstore

  def column_names
    parse_pg_array(read_attribute(:column_names))
  end
  def column_names=(ary)
    write_attribute(:column_names, '{' + ary.join(',') + '}')
  end

  def validation_errors(annual_report_upload)
    matching_records = matching_records(annual_report_upload.sandbox.table_name)
    error_count = matching_records.length
    if error_count > 0
      [
        Trade::ValidationError.new(
          :error_message => error_message,
          :annual_report_upload_id => annual_report_upload.id,
          :validation_rule_id => self.id,
          :error_count => error_count,
          :error_selector => error_selector(matching_records),
          :matching_records_ids => matching_records.map(&:id),
          :is_primary => self.is_primary
        )
      ]
    else
      []
    end
  end

  private

  # Returns a hash with column values to be used to select invalid rows.
  # For most primary validations this will be a pair
  # of validated field => array of invalid values.
  # e.g.
  # {
  #    :species_name => ['Loxodonta afticana', 'Loxadonta afacana']
  # }
  # Expects a single grouped matching record.
  def error_selector(matching_records)
    res = {}
    column_names.each do |cn|
      res[cn] = matching_records.select(cn).uniq.map(&cn.to_sym)
    end
    res
  end
end
