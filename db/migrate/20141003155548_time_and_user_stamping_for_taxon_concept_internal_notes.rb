class TimeAndUserStampingForTaxonConceptInternalNotes < ActiveRecord::Migration
  def change
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
  end
end
