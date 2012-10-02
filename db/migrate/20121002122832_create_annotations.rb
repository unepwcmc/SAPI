class CreateAnnotations < ActiveRecord::Migration
  def up
    create_table :annotations do |t|
      t.string :symbol
      t.string :parent_symbol
    end
    create_table :annotation_translations do |t|
      t.integer :annotation_id, :null => false
      t.integer :language_id, :null => false
      t.string :short_note
      t.text :full_note, :null => false
    end
    add_foreign_key "annotation_translations", "annotations", :name => "annotation_translations_annotation_id_fk"
    add_foreign_key "annotation_translations", "languages", :name => "annotation_translations_language_id_fk"
  end

  def down
    drop_table :annotations
    drop_table :annotation_translations
  end
end
