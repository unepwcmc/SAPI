class CreateNomenclatureChangeComponents < ActiveRecord::Migration
  def change
    create_table :nomenclature_change_components do |t|
      t.integer :nomenclature_change_id, :null => false
      t.integer :taxon_concept_id, :null => false
      t.boolean :is_input, :null => false
      t.integer :created_by_id
      t.integer :updated_by_id

      t.timestamps
    end
    add_foreign_key "nomenclature_change_components", "users", name: "nomenclature_change_components_created_by_id_fk", column: "created_by_id"
    add_foreign_key "nomenclature_change_components", "users", name: "nomenclature_change_components_updated_by_id_fk", column: "updated_by_id"
    add_foreign_key "nomenclature_change_components", "nomenclature_changes", name: "nomenclature_change_components_nomenclature_change_id_fk", column: "nomenclature_change_id"
    add_foreign_key "nomenclature_change_components", "taxon_concepts", name: "nomenclature_change_components_taxon_concept_id_fk", column: "taxon_concept_id"
  end
end
