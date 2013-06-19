class AddIsDoneToTradeAnnualReportUploads < ActiveRecord::Migration
  def change
    add_column :trade_annual_report_uploads, :is_done, :boolean, :default => false
  end
end
