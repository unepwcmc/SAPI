class AddTagListToNomenclatureChangesOutput < ActiveRecord::Migration[4.2]
  def change
    add_column :nomenclature_change_outputs, :tag_list, :text, array: true, default: []
  end
end
