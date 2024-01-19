class AddEuListingToApiTaxonConceptsView < ActiveRecord::Migration[4.2]
  def up
    execute "DROP VIEW IF EXISTS api_taxon_concepts_view CASCADE"
    execute "CREATE VIEW api_taxon_concepts_view AS #{view_sql('20221013155232', 'api_taxon_concepts_view')}"
    execute "CREATE VIEW taxa_with_eu_listings_export_view AS #{view_sql('20221013164743', 'taxa_with_eu_listings_export_view')}"
  end

  def down
    execute "DROP VIEW IF EXISTS api_taxon_concepts_view CASCADE"
    execute "CREATE VIEW api_taxon_concepts_view AS #{view_sql('20160317080944', 'api_taxon_concepts_view')}"
    execute "CREATE VIEW taxa_with_eu_listings_export_view AS #{view_sql('20221013164743', 'taxa_with_eu_listings_export_view')}"
  end
end
