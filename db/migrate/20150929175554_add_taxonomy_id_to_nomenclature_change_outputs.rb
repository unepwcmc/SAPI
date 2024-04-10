class AddTaxonomyIdToNomenclatureChangeOutputs < ActiveRecord::Migration[4.2]
  def change
    add_column :nomenclature_change_outputs, :taxonomy_id, :integer
  end
end
