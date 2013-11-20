class AddConstraintsToShipmentsColumns < ActiveRecord::Migration
  #legitimately blank fields: unit, purpose, source, origin country
  def change
    change_column :trade_shipments, :taxon_concept_id, :integer, :null => false
    change_column :trade_shipments, :reported_taxon_concept_id, :integer, :null => false
    change_column :trade_shipments, :term_id, :integer, :null => false
    change_column :trade_shipments, :exporter_id, :integer, :null => false
    change_column :trade_shipments, :importer_id, :integer, :null => false
    change_column :trade_shipments, :appendix, :string, :null => false
    change_column :trade_shipments, :quantity, :decimal, :null => false
    change_column :trade_shipments, :year, :integer, :null => false
    change_column :trade_shipments, :reported_by_exporter, :boolean, :default => true, :null => false
  end
end
