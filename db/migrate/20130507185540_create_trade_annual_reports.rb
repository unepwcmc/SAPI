class CreateTradeAnnualReports < ActiveRecord::Migration
  def change
    create_table :trade_annual_reports do |t|
      t.integer :geo_entity_id
      t.integer :year

      t.timestamps
    end
  end
end
