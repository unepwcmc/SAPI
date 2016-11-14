class AddSubmittedTimestampsForEpixUsersToAnnualReportUploads < ActiveRecord::Migration
  def change
    add_column :trade_annual_report_uploads, :epix_submitted_by_id, :integer
    add_column :trade_annual_report_uploads, :epix_submitted_at, :datetime
  end
end
