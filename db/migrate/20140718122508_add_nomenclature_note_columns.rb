class AddNomenclatureNoteColumns < ActiveRecord::Migration
  def change
    [:en, :es, :fr].each do |lng|
      add_column :taxon_concepts, :"nomenclature_note_#{lng}", :text
      add_column :listing_changes, :"nomenclature_note_#{lng}", :text
    end
    add_column :trade_restrictions, :nomenclature_note, :text
    add_column :eu_decisions, :nomenclature_note, :text
  end
end
