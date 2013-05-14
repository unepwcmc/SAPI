class DropAnnualReports < ActiveRecord::Migration
  def change
    drop_table :trade_annual_reports
  end
end
