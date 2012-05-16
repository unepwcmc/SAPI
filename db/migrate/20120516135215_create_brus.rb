class CreateBrus < ActiveRecord::Migration
  def change
    create_table :brus do |t|
      t.string :code, :null => false
      t.integer :level, :null => false
      t.string :name
      t.integer :parent_id
      t.integer :country_id
      t.timestamps
    end
    add_foreign_key "brus", "brus", :name => "brus_parent_id_fk", :column => "parent_id"
    add_foreign_key "brus", "countries", :name => "brus_country_id_fk"
  end
end
