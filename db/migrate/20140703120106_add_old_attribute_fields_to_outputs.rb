class AddOldAttributeFieldsToOutputs < ActiveRecord::Migration
  def change
    add_column :nomenclature_change_outputs, :parent_id, :integer
    add_column :nomenclature_change_outputs, :rank_id, :integer
    add_column :nomenclature_change_outputs, :scientific_name, :string
    add_column :nomenclature_change_outputs, :author_year, :string
    add_column :nomenclature_change_outputs, :name_status, :string
  end
end
