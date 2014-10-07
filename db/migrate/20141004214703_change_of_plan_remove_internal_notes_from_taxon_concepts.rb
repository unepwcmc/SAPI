class ChangeOfPlanRemoveInternalNotesFromTaxonConcepts < ActiveRecord::Migration
  def up
    execute 'DROP VIEW IF EXISTS orphaned_taxon_concepts_view'
    execute 'DROP VIEW IF EXISTS synonyms_and_trade_names_view'
    execute 'DROP VIEW IF EXISTS taxon_concepts_names_view'
    execute 'DROP VIEW IF EXISTS taxon_concepts_distributions_view'
    remove_column :taxon_concepts, :internal_general_note_updated_at
    remove_column :taxon_concepts, :internal_nomenclature_note_updated_at
    remove_column :taxon_concepts, :internal_distribution_note_updated_at
    remove_column :taxon_concepts, :internal_general_note_updated_by_id
    remove_column :taxon_concepts, :internal_nomenclature_note_updated_by_id
    remove_column :taxon_concepts, :internal_distribution_note_updated_by_id
    remove_column :taxon_concepts, :internal_general_note
    remove_column :taxon_concepts, :internal_nomenclature_note
    remove_column :taxon_concepts, :internal_distribution_note
  end

  def down
    add_column :taxon_concepts, :internal_general_note_updated_at, :datetime
    add_column :taxon_concepts, :internal_nomenclature_note_updated_at, :datetime
    add_column :taxon_concepts, :internal_distribution_note_updated_at, :datetime
    add_column :taxon_concepts, :internal_general_note_updated_by_id, :integer
    add_column :taxon_concepts, :internal_nomenclature_note_updated_by_id, :integer
    add_column :taxon_concepts, :internal_distribution_note_updated_by_id, :integer
    add_foreign_key :taxon_concepts, :users,
      name: 'taxon_concepts_internal_general_note_updated_by_id_fk',
      column: 'internal_general_note_updated_by_id'
    add_foreign_key :taxon_concepts, :users,
      name: 'taxon_concepts_internal_nomenclature_note_updated_by_id_fk',
      column: 'internal_nomenclature_note_updated_by_id'
    add_foreign_key :taxon_concepts, :users,
      name: 'taxon_concepts_internal_distribution_note_updated_by_id_fk',
      column: 'internal_distribution_note_updated_by_id'
    add_column :taxon_concepts, :internal_general_note, :text
    add_column :taxon_concepts, :internal_nomenclature_note, :text
    add_column :taxon_concepts, :internal_distribution_note, :text
  end
end
