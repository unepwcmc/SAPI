# == Schema Information
#
# Table name: trade_validation_rules
#
#  id                :integer          not null, primary key
#  column_names      :string(255)      not null
#  valid_values_view :string(255)
#  type              :string(255)      not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  format_re         :string(255)
#  run_order         :integer          not null
#

class Trade::ValidationRule < ActiveRecord::Base
  attr_accessible :column_names, :run_order
  include PgArrayParser

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
          :matching_records_ids => matching_records.map(&:id)
        )
      ]
    else
      []
    end
  end

end
