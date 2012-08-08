class AddLegacyIdToReferences < ActiveRecord::Migration
  def change
    add_column :references, :legacy_id, :integer
  end
end
