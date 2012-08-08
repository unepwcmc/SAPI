class AddAuthorToReferences < ActiveRecord::Migration
  def change
    add_column :references, :author, :string
  end
end
