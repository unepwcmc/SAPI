class AddTagListToNomenclatureChangesOutput < ActiveRecord::Migration
  def change
    add_column :nomenclature_change_outputs, :tag_list, :text, array: true, default: []
  end
end
