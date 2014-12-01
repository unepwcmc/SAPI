class RemoveInternalNomenclatureNoteThroughout < ActiveRecord::Migration
  def up
    remove_column :listing_changes, :internal_nomenclature_note
    remove_column :trade_restrictions, :internal_nomenclature_note
    remove_column :eu_decisions, :internal_nomenclature_note
  end

  def down
    add_column :listing_changes, :internal_nomenclature_note, :text
    add_column :trade_restrictions, :internal_nomenclature_note, :text
    add_column :eu_decisions, :internal_nomenclature_note, :text
  end
end
