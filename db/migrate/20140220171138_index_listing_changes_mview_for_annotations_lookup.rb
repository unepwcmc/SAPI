class IndexListingChangesMviewForAnnotationsLookup < ActiveRecord::Migration
  def up
    execute "DROP INDEX IF EXISTS annotations_display_in_index_symbol_idx"
    execute "CREATE INDEX listing_changes_mview_display_in_index ON listing_changes_mview (is_current, display_in_index, designation_id)"
  end

  def down
    execute "CREATE INDEX annotations_display_in_index_symbol_idx ON annotations (display_in_index, symbol)"
    execute "DROP INDEX listing_changes_mview_display_in_index"
  end
end
