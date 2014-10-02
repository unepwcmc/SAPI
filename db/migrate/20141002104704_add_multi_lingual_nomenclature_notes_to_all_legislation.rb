class AddMultiLingualNomenclatureNotesToAllLegislation < ActiveRecord::Migration
  def change
    rename_column :eu_decisions, :nomenclature_note, :nomenclature_note_en
    add_column :eu_decisions, :nomenclature_note_es, :text
    add_column :eu_decisions, :nomenclature_note_fr, :text
    rename_column :trade_restrictions, :nomenclature_note, :nomenclature_note_en
    add_column :trade_restrictions, :nomenclature_note_es, :text
    add_column :trade_restrictions, :nomenclature_note_fr, :text
  end
end
