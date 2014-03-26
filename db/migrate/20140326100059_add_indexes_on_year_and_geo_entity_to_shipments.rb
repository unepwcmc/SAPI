class AddIndexesOnYearAndGeoEntityToShipments < ActiveRecord::Migration
  def change
    execute <<-SQL
      CREATE INDEX index_trade_shipments_on_year_exporter_id
        ON trade_shipments
        USING btree
        (year, exporter_id);
      CREATE INDEX index_trade_shipments_on_year_importer_id
        ON trade_shipments
        USING btree
        (year, importer_id);
    SQL
  end
end
