class AddValidationInfoToAnnualReportUploads < ActiveRecord::Migration
  def change
    add_column :trade_annual_report_uploads, :validated_at, :datetime
    add_column :trade_annual_report_uploads, :validation_report, :jsonb
    add_column :trade_annual_report_uploads, :force_submit, :boolean, default: false
  end
end
