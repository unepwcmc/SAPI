class RemoveUnnecessaryNewNameRelatedFieldsFromOutput < ActiveRecord::Migration
  def up
    remove_column :nomenclature_change_outputs, :accepted_taxon_ids
    remove_column :nomenclature_change_outputs, :hybrid_parent_id
    remove_column :nomenclature_change_outputs, :other_hybrid_parent_id
  end

  def down
    add_column :nomenclature_change_outputs, :accepted_taxon_ids, "INTEGER[]"
    add_column :nomenclature_change_outputs, :hybrid_parent_id, :integer
    add_column :nomenclature_change_outputs, :other_hybrid_parent_id, :integer
  end
end
