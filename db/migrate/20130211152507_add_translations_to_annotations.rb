class AddTranslationsToAnnotations < ActiveRecord::Migration
  def change
    add_column :annotations, :short_note_en, :text
    add_column :annotations, :full_note_en, :text
    add_column :annotations, :short_note_fr, :text
    add_column :annotations, :full_note_fr, :text
    add_column :annotations, :short_note_es, :text
    add_column :annotations, :full_note_es, :text
  end
end
