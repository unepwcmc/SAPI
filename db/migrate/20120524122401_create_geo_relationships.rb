class CreateGeoRelationships < ActiveRecord::Migration
  def change
    create_table :geo_relationships do |t|
      t.integer :geo_entity_id, :null => false
      t.integer :other_geo_entity_id, :null => false
      t.integer :geo_relationship_type_id, :null => false

      t.timestamps
    end
    add_foreign_key "geo_relationships", "geo_relationship_types", :column => "geo_relationship_type_id"
    add_foreign_key "geo_relationships", "geo_entities", :column => "geo_entity_id"
    add_foreign_key "geo_relationships", "geo_entities", :column => "other_geo_entity_id"
  end
end
