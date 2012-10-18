class AddIndexOnHistoryFilter < ActiveRecord::Migration
  def change
    add_index "taxon_concepts_mview", ["designation_is_cites", "cites_listed", "kingdom_position"], :name => "index_taxon_concepts_mview_on_history_filter"
  end
end
