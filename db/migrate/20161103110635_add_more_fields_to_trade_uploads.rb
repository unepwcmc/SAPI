class AddMoreFieldsToTradeUploads < ActiveRecord::Migration
  def change
    add_column :trade_annual_report_uploads, :is_from_epix, :boolean, default: false
    add_column :trade_annual_report_uploads, :is_from_web_service, :boolean, default: false
    add_column :trade_annual_report_uploads, :number_of_records_submitted, :integer
    add_column :trade_annual_report_uploads, :auto_reminder_sent_at, :datetime
    add_column :trade_annual_report_uploads, :sandbox_transferred_at, :datetime
    add_column :trade_annual_report_uploads, :sandbox_transferred_by_id, :integer
    add_column :trade_annual_report_uploads, :submitted_at, :datetime
    add_column :trade_annual_report_uploads, :submitted_by_id, :integer
    add_column :trade_annual_report_uploads, :deleted_at, :datetime
    add_column :trade_annual_report_uploads, :deleted_by_id, :integer
  end
end
