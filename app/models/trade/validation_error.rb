class Trade::ValidationError < ApplicationRecord
  include ActiveModel::Validations

  validates_each :matching_criteria, allow_blank: true do |record, attr, value|
    record.errors.add attr, "must be a Hash, got a #{value.class.name}" if !value.is_a? Hash

    # Matching criteria values should be strings, because they could be invalid
    # formats for integers in the CSV.
    value.each_pair do |k, v|
      if !v.nil? && !v.is_a?(String)
        record.errors.add attr, "all values must be strings, got a #{v.class.name} for #{k}"
      end
    end
  end

  belongs_to :annual_report_upload, class_name: 'Trade::AnnualReportUpload'
  belongs_to :validation_rule, class_name: 'Trade::ValidationRule'

  # Used by app/models/trade/validation_rule.rb
  # attr_accessible :annual_report_upload_id,
  #   :validation_rule_id,
  #   :matching_criteria,
  #   :is_ignored,
  #   :is_primary,
  #   :error_message,
  #   :error_count
end
