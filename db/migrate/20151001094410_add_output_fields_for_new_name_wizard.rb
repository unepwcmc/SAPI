class AddOutputFieldsForNewNameWizard < ActiveRecord::Migration
  def change
    add_column :nomenclature_change_outputs, :accepted_taxon_ids, "INTEGER[]"
    add_column :nomenclature_change_outputs, :hybrid_parent_id, :integer
    add_column :nomenclature_change_outputs, :other_hybrid_parent_id, :integer
  end
end
