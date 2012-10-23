class AddCountriesIdsToListingChangesMview < ActiveRecord::Migration
  def up
    execute 'ALTER TABLE listing_changes_mview ADD COLUMN countries_ids_ary INTEGER[]'
    execute <<-SQL
    UPDATE listing_changes_mview SET
    countries_ids_ary = listing_changes_view.countries_ids_ary
    FROM listing_changes_view
    WHERE listing_changes_mview.id = listing_changes_view.id
    SQL
  end
  def down
    remove_column :listing_changes_mview, :countries_ids_ary
  end
end
