class RemoveListingChangesMviewTriggers < ActiveRecord::Migration
  def up
    execute <<-SQL
    DROP FUNCTION IF EXISTS trg_listing_changes_u() CASCADE;
    DROP FUNCTION IF EXISTS trg_listing_changes_d() CASCADE;
    DROP FUNCTION IF EXISTS trg_listing_changes_i() CASCADE;
    DROP FUNCTION IF EXISTS trg_annotations_u() CASCADE;
    DROP FUNCTION IF EXISTS trg_change_types_u() CASCADE;
    DROP FUNCTION IF EXISTS trg_species_listings_u() CASCADE;
    DROP FUNCTION IF EXISTS trg_listing_distributions_ui() CASCADE;
    DROP FUNCTION IF EXISTS trg_listing_distributions_d() CASCADE;
    DROP FUNCTION IF EXISTS listing_changes_refresh_row(row_id INTEGER) CASCADE;
    DROP FUNCTION IF EXISTS listing_changes_invalidate_row(id INTEGER) CASCADE;
    SQL
  end

  def down
  end
end
