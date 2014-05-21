class AddCreatedByIdToTradeAnnualReportUploads < ActiveRecord::Migration
  def change
    add_column :trade_annual_report_uploads, :created_by_id, :integer
  end
end
