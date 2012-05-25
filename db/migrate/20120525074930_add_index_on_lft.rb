class AddIndexOnLft < ActiveRecord::Migration
  def change
    add_index(:taxon_concepts, :lft)
  end
end
