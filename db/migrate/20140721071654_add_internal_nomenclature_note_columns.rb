class AddInternalNomenclatureNoteColumns < ActiveRecord::Migration
  def change
    [:en, :es, :fr].each do |lng|
      add_column :taxon_concepts, :"internal_nomenclature_note_#{lng}", :text
      add_column :listing_changes, :"internal_nomenclature_note_#{lng}", :text
    end
    add_column :trade_restrictions, :internal_nomenclature_note, :text
    add_column :eu_decisions, :internal_nomenclature_note, :text
  end
end
