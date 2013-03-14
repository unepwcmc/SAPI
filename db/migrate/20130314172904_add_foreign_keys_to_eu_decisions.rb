class AddForeignKeysToEuDecisions < ActiveRecord::Migration
  def change
    add_foreign_key "eu_decisions", "events", :name => "eu_decisions_law_id_fk", :column => :law_id
    add_foreign_key "eu_decisions", "geo_entities", :name => "eu_decisions_geo_entity_id_fk"
    add_foreign_key "eu_decisions", "trade_codes", :name => "eu_decisions_term_id_fk", :column => :term_id
    add_foreign_key "eu_decisions", "trade_codes", :name => "eu_decisions_source_id_fk", :column => :source_id
    add_foreign_key "eu_decisions", "taxon_concepts", :name => "eu_decisions_taxon_concept_id_fk"
  end
end
