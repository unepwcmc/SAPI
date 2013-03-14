class CreateTradeRestrictions < ActiveRecord::Migration
  def change
    create_table :trade_restrictions do |t|
      t.boolean :is_current
      t.datetime :start_date
      t.datetime :end_date
      t.integer :geo_entity_id
      t.integer :quota
      t.datetime :publication_date
      t.text :notes
      t.string :suspension_basis
      t.string :type
      t.integer :unit_id
      t.integer :term_id
      t.integer :source_id
      t.integer :purpose_id
      t.integer :taxon_concept_id

      t.timestamps
    end
    add_foreign_key "trade_restrictions", "trade_codes", :name => "trade_restrictions_unit_id_fk", :column => :unit_id
    add_foreign_key "trade_restrictions", "geo_entities", :name => "trade_restrictions_geo_entity_id_fk"
    add_foreign_key "trade_restrictions", "trade_codes", :name => "trade_restrictions_term_id_fk", :column => :term_id
    add_foreign_key "trade_restrictions", "trade_codes", :name => "trade_restrictions_source_id_fk", :column => :source_id
    add_foreign_key "trade_restrictions", "trade_codes", :name => "trade_restrictions_purpose_id_fk", :column => :purpose_id
    add_foreign_key "trade_restrictions", "taxon_concepts", :name => "trade_restrictions_taxon_concept_id_fk"
  end
end
