class Trade::ValidationRule < ActiveRecord::Base
  attr_accessible :column_names, :run_order
  include PgArrayParser

  def column_names
    parse_pg_array(read_attribute(:column_names))
  end
  def column_names=(ary)
    write_attribute(:column_names, '{' + ary.join(',') + '}')
  end
  def matching_records
    raise "Must be implemented in subcass"
  end

  def validation_errors(annual_report_upload)
    error_count = matching_records(annual_report_upload.sandbox.table_name).length
    if error_count > 0
      [
        Trade::ValidationError.new(
          :error_message => error_message,
          :annual_report_upload_id => annual_report_upload.id,
          :validation_rule_id => self.id,
          :error_count => error_count
        )
      ]
    else
      []
    end
  end

end
