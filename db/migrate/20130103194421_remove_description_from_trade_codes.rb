class RemoveDescriptionFromTradeCodes < ActiveRecord::Migration
  def up
    remove_column :trade_codes, :description_en
    remove_column :trade_codes, :description_es
    remove_column :trade_codes, :description_fr
  end

  def down
    add_column :trade_codes, :description_en, :string
    add_column :trade_codes, :description_es, :string
    add_column :trade_codes, :description_fr, :string
  end
end
