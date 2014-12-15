class AddNomenclatureNotesToDesignationListingChangesMview < ActiveRecord::Migration
  def change
    if table_exists? :cites_listing_changes_mview
      add_column :cites_listing_changes_mview, :nomenclature_note_en, :text
      add_column :cites_listing_changes_mview, :nomenclature_note_fr, :text
      add_column :cites_listing_changes_mview, :nomenclature_note_es, :text
    end
    if table_exists? :eu_listing_changes_mview
      add_column :eu_listing_changes_mview, :nomenclature_note_en, :text
      add_column :eu_listing_changes_mview, :nomenclature_note_fr, :text
      add_column :eu_listing_changes_mview, :nomenclature_note_es, :text
    end
    if table_exists? :cms_listing_changes_mview
      add_column :cms_listing_changes_mview, :nomenclature_note_en, :text
      add_column :cms_listing_changes_mview, :nomenclature_note_fr, :text
      add_column :cms_listing_changes_mview, :nomenclature_note_es, :text
    end
  end
end
