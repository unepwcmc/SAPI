class AddInternalNomenclatureNoteColumns < ActiveRecord::Migration
  def change
    add_column :taxon_concepts, :internal_nomenclature_note, :text
    add_column :listing_changes, :internal_nomenclature_note, :text
    add_column :trade_restrictions, :internal_nomenclature_note, :text
    add_column :eu_decisions, :internal_nomenclature_note, :text
  end
end
