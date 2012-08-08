class AddLegacyTypeToReferences < ActiveRecord::Migration
  def change
    add_column :references, :legacy_type, :string
  end
end
