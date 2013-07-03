class CreateTaxonInstruments < ActiveRecord::Migration
  def change
    create_table :taxon_instruments do |t|
      t.integer :taxon_concept_id
      t.integer :instrument_id
      t.datetime :effective_from

      t.timestamps
    end

    add_foreign_key "taxon_instruments", "taxon_concepts", :name => "taxon_instruments_taxon_concept_id_fk"
    add_foreign_key "taxon_instruments", "instruments", :name => "taxon_instruments_instrument_id_fk"
  end
end
