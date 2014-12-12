class AddNomenclatureNotesToListingChangesMview < ActiveRecord::Migration
  def change
    add_column :listing_changes_mview, :nomenclature_note_en, :text
    add_column :listing_changes_mview, :nomenclature_note_fr, :text
    add_column :listing_changes_mview, :nomenclature_note_es, :text
  end
end
