class CreateMatchableTaxonomies < ActiveRecord::Migration[8.1]
  def change
    create_table :matchable_taxonomies do |t|
      t.string :code, null: false
      t.string :name, null: false

      t.timestamps
    end

    # The code is the token the API path is addressed by
    # (/intertaxonomic_mappings/CITES_EU:6353), so it has to stay unique.
    add_index :matchable_taxonomies, :code, unique: true
  end
end
