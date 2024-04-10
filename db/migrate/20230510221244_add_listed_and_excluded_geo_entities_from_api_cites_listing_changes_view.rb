class AddListedAndExcludedGeoEntitiesFromApiCitesListingChangesView < ActiveRecord::Migration[4.2]
  def up
    execute "DROP VIEW IF EXISTS taxa_with_eu_listings_export_view"
    execute "DROP VIEW IF EXISTS api_cites_listing_changes_view"
    execute "CREATE VIEW api_cites_listing_changes_view AS #{view_sql('20230509172742', 'api_cites_listing_changes_view')}"
    execute "CREATE VIEW taxa_with_eu_listings_export_view AS #{view_sql('20221013164743', 'taxa_with_eu_listings_export_view')}"
  end

  def down
    execute "DROP VIEW IF EXISTS taxa_with_eu_listings_export_view"
    execute "DROP VIEW IF EXISTS api_cites_listing_changes_view"
    execute "CREATE VIEW api_cites_listing_changes_view AS #{view_sql('20141230193844', 'api_cites_listing_changes_view')}"
    execute "CREATE VIEW taxa_with_eu_listings_export_view AS #{view_sql('20221013164743', 'taxa_with_eu_listings_export_view')}"
  end
end
