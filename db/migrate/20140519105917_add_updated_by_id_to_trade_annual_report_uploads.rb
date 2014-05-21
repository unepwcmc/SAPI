class AddUpdatedByIdToTradeAnnualReportUploads < ActiveRecord::Migration
  def change
    add_column :trade_annual_report_uploads, :updated_by_id, :integer
  end
end
