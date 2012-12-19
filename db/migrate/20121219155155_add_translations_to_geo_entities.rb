class AddTranslationsToGeoEntities < ActiveRecord::Migration
  def up
    rename_column :geo_entities, :name, :name_en
    add_column :geo_entities, :name_fr, :string
    add_column :geo_entities, :name_es, :string
  end

  def down
    rename_column :geo_entities, :name_en, :name
    remove_column :geo_entities, :name_fr
    remove_column :geo_entities, :name_es
  end
end
