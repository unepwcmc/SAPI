class TranslateRanksAndChangeTypes < ActiveRecord::Migration
  def up
    add_column :ranks, :display_name_en, :text
    add_column :ranks, :display_name_es, :text
    add_column :ranks, :display_name_fr, :text
    execute 'UPDATE ranks SET display_name_en = name'
    change_column :ranks, :display_name_en, :text, :null => false
    add_column :change_types, :display_name_en, :text
    add_column :change_types, :display_name_es, :text
    add_column :change_types, :display_name_fr, :text
    execute 'UPDATE change_types SET display_name_en = name'
    change_column :change_types, :display_name_en, :text, :null => false
  end

  def down
    remove_column :ranks, :display_name_en
    remove_column :ranks, :display_name_es
    remove_column :ranks, :display_name_fr
    remove_column :change_types, :display_name_en
    remove_column :change_types, :display_name_es
    remove_column :change_types, :display_name_fr
  end
end
