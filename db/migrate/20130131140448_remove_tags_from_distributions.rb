class RemoveTagsFromDistributions < ActiveRecord::Migration
  def up
    remove_column :distributions, :tags
  end

  def down
    add_column :distributions, :tags, :string
  end
end
