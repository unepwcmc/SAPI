class AddCitesListingToApiTaxonConceptsView < ActiveRecord::Migration
  def change
    execute "DROP VIEW IF EXISTS api_taxon_concepts_view"
    execute "CREATE VIEW api_taxon_concepts_view AS #{view_sql('20150116112256', 'api_taxon_concepts_view')}"
  end
end
