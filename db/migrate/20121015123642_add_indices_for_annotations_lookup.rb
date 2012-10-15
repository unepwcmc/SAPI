class AddIndicesForAnnotationsLookup < ActiveRecord::Migration
  def change
    add_index "annotations", ["listing_change_id"], :name => "index_annotations_on_listing_change_id"
    add_index "listing_changes", ["parent_id"], :name => "index_listing_changes_on_parent_id"
    add_index "listing_distributions", ["listing_change_id"], :name => "index_listing_distributions_on_listing_change_id"
  end
end
