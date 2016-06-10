class CreateNomenclatureChangeInputs < ActiveRecord::Migration
  def change
    create_table :nomenclature_change_inputs do |t|
      t.integer :nomenclature_change_id, :null => false
      t.integer :taxon_concept_id, :null => false
      t.text :note
      t.integer :created_by_id, :null => false
      t.integer :updated_by_id, :null => false

      t.timestamps
    end
    add_foreign_key 'nomenclature_change_inputs', 'users',
      name: 'nomenclature_change_inputs_created_by_id_fk',
      column: 'created_by_id'
    add_foreign_key 'nomenclature_change_inputs', 'users',
      name: 'nomenclature_change_inputs_updated_by_id_fk',
      column: 'updated_by_id'
    add_foreign_key 'nomenclature_change_inputs', 'nomenclature_changes',
      name: 'nomenclature_change_inputs_nomenclature_change_id_fk',
      column: 'nomenclature_change_id'
    add_foreign_key 'nomenclature_change_inputs', 'taxon_concepts',
      name: 'nomenclature_change_inputs_taxon_concept_id_fk',
      column: 'taxon_concept_id'
  end
end
