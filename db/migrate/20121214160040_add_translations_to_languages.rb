class AddTranslationsToLanguages < ActiveRecord::Migration
  def up
    rename_column :languages, :name, :name_en
    add_column :languages, :name_fr, :string
    add_column :languages, :name_es, :string
  end

  def down
    rename_column :languages, :name_en, :name
    remove_column :languages, :name_fr
    remove_column :languages, :name_es
  end
end
