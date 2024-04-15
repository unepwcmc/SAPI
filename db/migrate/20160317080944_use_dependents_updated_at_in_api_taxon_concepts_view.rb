class UseDependentsUpdatedAtInApiTaxonConceptsView < ActiveRecord::Migration[4.2]
  def up
    execute "DROP VIEW IF EXISTS api_taxon_concepts_view"
    execute "CREATE VIEW api_taxon_concepts_view AS #{view_sql('20160317080944', 'api_taxon_concepts_view')}"
  end

  def down
    execute "DROP VIEW IF EXISTS api_taxon_concepts_view"
    execute "CREATE VIEW api_taxon_concepts_view AS #{view_sql('20150518131629', 'api_taxon_concepts_view')}"
  end
end
