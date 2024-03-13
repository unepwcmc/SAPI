class AddNomenclatureNotesToListingChangesMview < ActiveRecord::Migration[4.2]
  def change
    if table_exists? :listing_changes_mview
      add_column :listing_changes_mview, :nomenclature_note_en, :text
      add_column :listing_changes_mview, :nomenclature_note_fr, :text
      add_column :listing_changes_mview, :nomenclature_note_es, :text
    end
  end
end
