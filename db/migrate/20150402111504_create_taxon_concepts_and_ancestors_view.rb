class CreateTaxonConceptsAndAncestorsView < ActiveRecord::Migration
  def up
    execute "DROP MATERIALIZED VIEW IF EXISTS taxon_concept_and_ancestors_mview"
    execute "CREATE MATERIALIZED VIEW taxon_concepts_and_ancestors_mview AS #{view_sql('20150402111504', 'taxon_concepts_and_ancestors_mview')}"
    execute "CREATE UNIQUE INDEX ON taxon_concepts_and_ancestors_mview(ancestor_taxon_concept_id, taxon_concept_id)"
    execute "CREATE INDEX ON taxon_concepts_and_ancestors_mview(taxonomy_id)"
  end

  def down
    execute "DROP MATERIALIZED VIEW IF EXISTS taxon_concept_and_ancestors_mview"
  end
end
