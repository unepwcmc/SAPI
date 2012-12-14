class AddTranslationsToTradeCodes < ActiveRecord::Migration
  def up
    rename_column :trade_codes, :name, :name_en
    add_column :trade_codes, :name_es, :string
    add_column :trade_codes, :name_fr, :string
    rename_column :trade_codes, :description, :description_en
    add_column :trade_codes, :description_es, :string
    add_column :trade_codes, :description_fr, :string
  end

  def down
    rename_column :trade_codes, :name_en, :name
    remove_column :trade_codes, :name_es
    remove_column :trade_codes, :name_fr
    rename_column :trade_codes, :description_en, :description
    remove_column :trade_codes, :description_es
    remove_column :trade_codes, :description_fr
  end
end
