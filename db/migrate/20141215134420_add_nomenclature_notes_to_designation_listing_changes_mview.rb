class AddNomenclatureNotesToDesignationListingChangesMview < ActiveRecord::Migration
  def change
    add_column :cites_listing_changes_mview, :nomenclature_note_en, :text
    add_column :cites_listing_changes_mview, :nomenclature_note_fr, :text
    add_column :cites_listing_changes_mview, :nomenclature_note_es, :text
    add_column :eu_listing_changes_mview, :nomenclature_note_en, :text
    add_column :eu_listing_changes_mview, :nomenclature_note_fr, :text
    add_column :eu_listing_changes_mview, :nomenclature_note_es, :text
    add_column :cms_listing_changes_mview, :nomenclature_note_en, :text
    add_column :cms_listing_changes_mview, :nomenclature_note_fr, :text
    add_column :cms_listing_changes_mview, :nomenclature_note_es, :text
  end
end
