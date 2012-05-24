class CreateGeoEntities < ActiveRecord::Migration
  def change
    create_table :geo_entities do |t|
      t.integer :geo_entity_type_id, :null => false
      t.string :name, :null => false
      t.string :long_name
      t.string :iso_code2
      t.string :iso_code3
      t.integer :legacy_id
      t.string :legacy_type

      t.timestamps
    end
    add_foreign_key "geo_entities", "geo_entity_types", :column => "geo_entity_type_id"
  end
end
