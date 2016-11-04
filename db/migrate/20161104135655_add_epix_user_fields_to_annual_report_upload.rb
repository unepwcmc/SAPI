class AddEpixUserFieldsToAnnualReportUpload < ActiveRecord::Migration
  def change
    add_column :trade_annual_report_uploads, :epix_created_by_id, :integer
    add_column :trade_annual_report_uploads, :epix_created_at, :integer
    add_column :trade_annual_report_uploads, :epix_updated_by_id, :integer
    add_column :trade_annual_report_uploads, :epix_updated_at, :integer
    remove_column :trade_annual_report_uploads, :is_from_epix
  end
end
