class DocumentIsPublicShouldDefaultToFalse < ActiveRecord::Migration
  def change
    change_column :documents, :is_public, :boolean, null: false, default: false
  end
end
