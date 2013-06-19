class CreateTradeAnnualReports < ActiveRecord::Migration
  def change
    create_table :trade_annual_reports do |t|
      t.integer :geo_entity_id
      t.integer :year

      t.timestamps
    end
    add_foreign_key "trade_annual_reports", "geo_entities", :name => "trade_annual_reports_geo_entity_id_fk"
  end
end
