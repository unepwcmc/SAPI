class AddDiscussionIdAndSortOrderToDocuments < ActiveRecord::Migration[4.2]
  def change
    add_column :documents, :discussion_id, :integer
    add_column :documents, :discussion_sort_index, :integer
  end
end
