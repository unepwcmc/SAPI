# == Schema Information
#
# Table name: trade_validation_errors
#
#  id                      :integer          not null, primary key
#  error_count             :integer          not null
#  error_message           :text             not null
#  is_ignored              :boolean          default(FALSE)
#  is_primary              :boolean          default(FALSE)
#  matching_criteria       :jsonb            not null
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  annual_report_upload_id :integer          not null
#  validation_rule_id      :integer          not null
#
# Indexes
#
#  index_trade_validation_errors_on_aru_id             (annual_report_upload_id)
#  index_trade_validation_errors_on_matching_criteria  (matching_criteria) USING gin
#  index_trade_validation_errors_on_vr_id              (validation_rule_id)
#  index_trade_validation_errors_unique                (annual_report_upload_id,validation_rule_id,matching_criteria) UNIQUE
#
# Foreign Keys
#
#  trade_validation_errors_aru_id_fk  (annual_report_upload_id => trade_annual_report_uploads.id) ON DELETE => cascade
#  trade_validation_errors_vr_id_fk   (validation_rule_id => trade_validation_rules.id) ON DELETE => cascade
#
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
