class AddIndexOnTaxonConceptIdToTaxonInstruments < ActiveRecord::Migration
  def change
  	add_index "taxon_instruments", ["taxon_concept_id"]
  end
end
