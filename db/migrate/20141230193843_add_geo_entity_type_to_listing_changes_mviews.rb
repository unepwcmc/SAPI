class AddGeoEntityTypeToListingChangesMviews < ActiveRecord::Migration
  def change
    [:cites, :eu, :cms].each do |designation|
      listing_changes_mview = "#{designation}_listing_changes_mview"
      unless column_exists? listing_changes_mview, :geo_entity_type
        add_column listing_changes_mview, :geo_entity_type, :string
      end
    end
  end
end
