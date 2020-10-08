class CreateAllTaxonConceptsAndAncestorsMview < ActiveRecord::Migration
  def up
    execute "DROP MATERIALIZED VIEW IF EXISTS all_taxon_concepts_and_ancestors_mview"
    execute "CREATE MATERIALIZED VIEW all_taxon_concepts_and_ancestors_mview AS #{view_sql('20201008133057', 'all_taxon_concepts_and_ancestors_mview')}"
    execute "CREATE UNIQUE INDEX ON all_taxon_concepts_and_ancestors_mview(ancestor_taxon_concept_id, taxon_concept_id)"
    execute "CREATE INDEX ON all_taxon_concepts_and_ancestors_mview(taxonomy_id)"
  end

  def down
    execute "DROP MATERIALIZED VIEW IF EXISTS all_taxon_concepts_and_ancestors_mview"
  end
end
