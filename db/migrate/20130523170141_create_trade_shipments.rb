class CreateTradeShipments < ActiveRecord::Migration
  def change

    create_table :trade_permits do |t|
      t.string :number
      t.integer :geo_entity_id

      t.timestamps
    end

    add_foreign_key "trade_permits", "geo_entities", :name => "trade_permits_geo_entity_id_fk", :column => "geo_entity_id"

    create_table :trade_exporter_permits do |t|
      t.integer :trade_permit_id
      t.integer :trade_shipment_id

      t.timestamps
    end

    add_foreign_key "trade_exporter_permits", "trade_permits", :name => "trade_exporter_permits_trade_permit_id_fk", :column => "trade_permit_id"
    add_foreign_key "trade_exporter_permits", "trade_permits", :name => "trade_exporter_permits_trade_shipment_id_fk", :column => "trade_shipment_id"

    create_table :trade_shipments do |t|
      t.integer :source_id
      t.integer :unit_id
      t.integer :purpose_id
      t.integer :term_id
      t.decimal :quantity
      t.string :reported_appendix
      t.string :appendix
      t.integer :trade_annual_report_upload_id
      t.integer :exporter_id
      t.integer :importer_id
      t.integer :country_of_origin_id
      t.integer :country_of_origin_permit_id
      t.integer :import_permit_id
      t.boolean :reported_by_exporter
      t.integer :taxon_concept_id
      t.string :reported_species_name
      t.integer :year

      t.timestamps
    end

    add_foreign_key "trade_shipments", "trade_codes", :name => "trade_shipments_source_id_fk", :column => "source_id"
    add_foreign_key "trade_shipments", "trade_codes", :name => "trade_shipments_term_id_fk", :column => "term_id"
    add_foreign_key "trade_shipments", "trade_codes", :name => "trade_shipments_unit_id_fk", :column => "unit_id"
    add_foreign_key "trade_shipments", "trade_codes", :name => "trade_shipments_purpose_id_fk", :column => "purpose_id"
    add_foreign_key "trade_shipments", "trade_annual_report_uploads", :name => "trade_shipments_trade_annual_report_upload_id_fk", :column => "trade_annual_report_upload_id"
    add_foreign_key "trade_shipments", "geo_entities", :name => "trade_shipments_exporter_id_fk", :column => "exporter_id"
    add_foreign_key "trade_shipments", "geo_entities", :name => "trade_shipments_importer_id_fk", :column => "importer_id"
    add_foreign_key "trade_shipments", "geo_entities", :name => "trade_shipments_country_of_origin_id_fk", :column => "country_of_origin_id"
    add_foreign_key "trade_shipments", "trade_permits", :name => "trade_shipments_country_of_origin_permit_id_fk", :column => "country_of_origin_permit_id"
    add_foreign_key "trade_shipments", "trade_permits", :name => "trade_shipments_import_permit_id_fk", :column => "import_permit_id"
    add_foreign_key "trade_shipments", "taxon_concepts", :name => "trade_shipments_taxon_concept_id_fk", :column => "taxon_concept_id"
  end
end
