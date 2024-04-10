class AddSubmittedTimestampsForEpixUsersToAnnualReportUploads < ActiveRecord::Migration[4.2]
  def change
    add_column :trade_annual_report_uploads, :epix_submitted_by_id, :integer
    add_column :trade_annual_report_uploads, :epix_submitted_at, :datetime
  end
end
