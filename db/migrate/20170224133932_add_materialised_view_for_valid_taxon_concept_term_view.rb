class AddMaterialisedViewForValidTaxonConceptTermView < ActiveRecord::Migration
  def up
    execute "DROP MATERIALIZED VIEW IF EXISTS valid_taxon_concept_term_mview"
    execute "CREATE MATERIALIZED VIEW valid_taxon_concept_term_mview AS SELECT * FROM valid_taxon_concept_term_view"
    execute "CREATE INDEX ON valid_taxon_concept_term_mview (taxon_concept_id)"
    execute "CREATE INDEX ON valid_taxon_concept_term_mview (term_id)"
  end

  def down
    execute "DROP MATERIALIZED VIEW IF EXISTS valid_taxon_concept_term_mview"
  end
end
