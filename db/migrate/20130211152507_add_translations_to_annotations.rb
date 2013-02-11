class AddTranslationsToAnnotations < ActiveRecord::Migration
  def change
    add_column :annotations, :short_note_en, :string
    add_column :annotations, :full_note_en, :string
    add_column :annotations, :short_note_fr, :string
    add_column :annotations, :full_note_fr, :string
    add_column :annotations, :short_note_es, :string
    add_column :annotations, :full_note_es, :string
  end
end
