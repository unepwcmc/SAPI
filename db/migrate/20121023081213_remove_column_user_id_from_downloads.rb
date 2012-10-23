class RemoveColumnUserIdFromDownloads < ActiveRecord::Migration
  def up
    remove_column(:downloads, :user_id)
  end

  def down
  end
end
