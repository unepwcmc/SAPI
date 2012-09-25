class CreateMaterializedListingChangesView < ActiveRecord::Migration
  def up
    execute <<-SQL
    CREATE TABLE mat_listing_changes_view AS
    SELECT *,
    false as dirty,
    null::timestamp with time zone as expiry
    FROM listing_changes_view;
    SQL
  end

  def down
    drop_table :mat_listing_changes_view
  end
end
