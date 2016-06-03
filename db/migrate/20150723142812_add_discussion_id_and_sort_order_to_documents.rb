class AddDiscussionIdAndSortOrderToDocuments < ActiveRecord::Migration
  def change
    add_column :documents, :discussion_id, :integer
    add_column :documents, :discussion_sort_index, :integer
  end
end
