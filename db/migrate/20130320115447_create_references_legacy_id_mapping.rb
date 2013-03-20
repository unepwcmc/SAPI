class CreateReferencesLegacyIdMapping < ActiveRecord::Migration
  def change
    create_table :references_legacy_id_mapping do |t|
      t.integer :legacy_id, :null =>false
      t.text :legacy_type, :null => false
      t.integer :alias_legacy_id, :null => false
    end
  end
end
