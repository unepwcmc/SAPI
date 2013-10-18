class CreateTradeTaxonConceptCodePairs < ActiveRecord::Migration
  def change
    create_table :trade_taxon_concept_code_pairs do |t|
      t.integer :taxon_concept_id
      t.integer :trade_code_id
      t.string :trade_code_type

      t.timestamps
    end
    add_foreign_key "trade_taxon_concept_code_pairs", "taxon_concepts", :name => "trade_taxon_concept_code_pairs_taxon_concept_id_fk"
    add_foreign_key "trade_taxon_concept_code_pairs", "trade_codes", :name => "trade_taxon_concept_code_pairs_trade_code_id_fk"
  end
end
