class CreateNomenclatureChangeOutputs < ActiveRecord::Migration
  def change
    create_table :nomenclature_change_outputs do |t|
      t.integer :nomenclature_change_id, :null => false
      t.integer :taxon_concept_id
      t.integer :new_taxon_concept_id
      t.integer :new_parent_id
      t.integer :new_rank_id
      t.string :new_scientific_name
      t.string :new_author_year
      t.string :new_name_status
      t.text :note
      t.integer :created_by_id, :null => false
      t.integer :updated_by_id, :null => false

      t.timestamps
    end
    add_foreign_key 'nomenclature_change_outputs', 'users',
      name: 'nomenclature_change_outputs_created_by_id_fk',
      column: 'created_by_id'
    add_foreign_key 'nomenclature_change_outputs', 'users',
      name: 'nomenclature_change_outputs_updated_by_id_fk',
      column: 'updated_by_id'
    add_foreign_key 'nomenclature_change_outputs', 'nomenclature_changes',
      name: 'nomenclature_change_outputs_nomenclature_change_id_fk',
      column: 'nomenclature_change_id'
    add_foreign_key 'nomenclature_change_outputs', 'taxon_concepts',
      name: 'nomenclature_change_outputs_taxon_concept_id_fk',
      column: 'taxon_concept_id'
    add_foreign_key 'nomenclature_change_outputs', 'taxon_concepts',
      name: 'nomenclature_change_outputs_new_taxon_concept_id_fk',
      column: 'new_taxon_concept_id'
    add_foreign_key 'nomenclature_change_outputs', 'taxon_concepts',
      name: 'nomenclature_change_outputs_new_parent_id_fk',
      column: 'new_parent_id'
    add_foreign_key 'nomenclature_change_outputs', 'ranks',
      name: 'nomenclature_change_outputs_new_rank_id_fk',
      column: 'new_rank_id'
  end
end
