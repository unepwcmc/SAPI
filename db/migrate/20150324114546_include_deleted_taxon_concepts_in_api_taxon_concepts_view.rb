class IncludeDeletedTaxonConceptsInApiTaxonConceptsView < ActiveRecord::Migration
  def up
    execute "DROP VIEW IF EXISTS api_taxon_concepts_view"
    execute "CREATE VIEW api_taxon_concepts_view AS #{view_sql('20150324114546', 'api_taxon_concepts_view')}"
  end

  def down
    execute "DROP VIEW IF EXISTS api_taxon_concepts_view"
    execute "CREATE VIEW api_taxon_concepts_view AS #{view_sql('20150119122122', 'api_taxon_concepts_view')}"
  end
end
