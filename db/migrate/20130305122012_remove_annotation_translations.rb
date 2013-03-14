class RemoveAnnotationTranslations < ActiveRecord::Migration
  def change
    drop_table :annotation_translations
  end
end
