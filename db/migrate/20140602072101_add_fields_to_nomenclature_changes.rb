class AddFieldsToNomenclatureChanges < ActiveRecord::Migration
  def change
    add_column :nomenclature_changes, :type, :string
    add_column :nomenclature_changes, :is_submitted, :boolean, :default => false, :null => false
  end
end
