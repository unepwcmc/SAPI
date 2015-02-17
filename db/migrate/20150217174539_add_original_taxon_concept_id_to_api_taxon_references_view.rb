class AddOriginalTaxonConceptIdToApiTaxonReferencesView < ActiveRecord::Migration
  def up
    execute "DROP VIEW IF EXISTS api_taxon_references_view"
    execute "CREATE VIEW api_taxon_references_view AS #{view_sql('20150217174539', 'api_taxon_references_view')}"
  end

  def down
    execute "DROP VIEW IF EXISTS api_taxon_references_view"
    execute "CREATE VIEW api_taxon_references_view AS #{view_sql('20150106100040', 'api_taxon_references_view')}"
  end
end
