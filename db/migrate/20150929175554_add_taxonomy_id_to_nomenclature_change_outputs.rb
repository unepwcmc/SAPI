class AddTaxonomyIdToNomenclatureChangeOutputs < ActiveRecord::Migration
  def change
    add_column :nomenclature_change_outputs, :taxonomy_id, :integer
  end
end
