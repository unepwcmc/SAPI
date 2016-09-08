class Trade::ValidationError < ActiveRecord::Base
  belongs_to :annual_report_upload, class_name: Trade::AnnualReportUpload
  belongs_to :validation_rule, class_name: Trade::ValidationRule
  attr_accessible :annual_report_upload_id,
    :validation_rule_id,
    :matching_criteria,
    :is_ignored,
    :is_primary,
    :error_message,
    :error_count
end
