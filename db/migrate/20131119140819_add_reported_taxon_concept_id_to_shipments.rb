class AddReportedTaxonConceptIdToShipments < ActiveRecord::Migration
  def up
    add_column :trade_shipments, :reported_taxon_concept_id, :integer
    Trade::Shipment.update_all('reported_taxon_concept_id = taxon_concept_id')
    add_foreign_key :trade_shipments, :taxon_concepts, :column => :reported_taxon_concept_id
  end

  def down
    remove_column :trade_shipments, :reported_taxon_concept_id
  end
end
