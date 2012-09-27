class CreateMaterializedListingChangesView < ActiveRecord::Migration
  def up
    execute <<-SQL
    CREATE TABLE listing_changes_mview AS
    SELECT *,
    false as dirty,
    null::timestamp with time zone as expiry
    FROM listing_changes_view;
    SQL
  end

  def down
    drop_table :listing_changes_mview
  end
end
