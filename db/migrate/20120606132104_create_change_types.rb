class CreateChangeTypes < ActiveRecord::Migration
  def change
    create_table :change_types do |t|
      t.integer :listing_change_id
      t.string :name

      t.timestamps
    end

    add_foreign_key 'change_types', 'listing_changes', :name => 'change_types_listing_change_id_fk'
  end
end
