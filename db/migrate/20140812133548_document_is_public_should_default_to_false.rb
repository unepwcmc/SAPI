class DocumentIsPublicShouldDefaultToFalse < ActiveRecord::Migration[4.2]
  def change
    change_column :documents, :is_public, :boolean, null: false, default: false
  end
end
