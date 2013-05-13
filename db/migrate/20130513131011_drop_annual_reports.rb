class DropAnnualReports < ActiveRecord::Migration
  def change
    drop_table :annual_reports
  end
end
