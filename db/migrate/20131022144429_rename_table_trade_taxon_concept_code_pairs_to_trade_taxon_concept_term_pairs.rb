class RenameTableTradeTaxonConceptCodePairsToTradeTaxonConceptTermPairs < ActiveRecord::Migration
  def up
    remove_foreign_key :trade_taxon_concept_code_pairs, :name => 'trade_taxon_concept_code_pairs_taxon_concept_id_fk'
    remove_foreign_key :trade_taxon_concept_code_pairs, :name => 'trade_taxon_concept_code_pairs_trade_code_id_fk'
    rename_table :trade_taxon_concept_code_pairs, :trade_taxon_concept_term_pairs
    rename_column :trade_taxon_concept_term_pairs, :trade_code_id, :term_id
    remove_column :trade_taxon_concept_term_pairs, :trade_code_type
    add_foreign_key "trade_taxon_concept_term_pairs", "trade_codes", :name => "trade_taxon_concept_code_pairs_term_id", :column => "term_id"
    add_foreign_key "trade_taxon_concept_term_pairs", "taxon_concepts", :name => "trade_taxon_concept_code_pairs_taxon_concept_id", :column => "taxon_concept_id"
  end

  def down
    remove_foreign_key :trade_taxon_concept_term_pairs, :name => 'trade_taxon_concept_term_pairs_taxon_concept_id_fk'
    remove_foreign_key :trade_taxon_concept_term_pairs, :name => 'trade_taxon_concept_term_pairs_trade_code_id_fk'
    rename_column :trade_taxon_concept_term_pairs, :term_id, :trade_code_id
    add_column :trade_taxon_concept_term_pairs, :trade_code_type, :string
    rename_table :trade_taxon_concept_term_pairs, :trade_taxon_concept_code_pairs
    add_foreign_key "trade_taxon_concept_code_pairs", "trade_codes", :name => "trade_taxon_concept_code_pairs_term_id", :column => "term_id"
    add_foreign_key "trade_taxon_concept_code_pairs", "taxon_concepts", :name => "trade_taxon_concept_code_pairs_taxon_concept_id", :column => "taxon_concept_id"
  end
end
