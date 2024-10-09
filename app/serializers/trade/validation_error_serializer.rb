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
class Trade::ValidationErrorSerializer < ActiveModel::Serializer
  attributes :id, :error_message, :error_count, :is_primary,
    :is_ignored
end
