class UpdateListingChangesViews < ActiveRecord::Migration
  def change
    execute "DROP VIEW IF EXISTS api_cites_listing_changes_view"
    execute "CREATE VIEW api_cites_listing_changes_view AS #{view_sql('20141228224334', 'api_cites_listing_changes_view')}"
    execute "DROP VIEW IF EXISTS api_eu_listing_changes_view"
    execute "CREATE VIEW api_eu_listing_changes_view AS #{view_sql('20141228224334', 'api_eu_listing_changes_view')}"
  end
end
