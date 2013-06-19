class CreateDesignationGeoEntities < ActiveRecord::Migration
  def change
    create_table :designation_geo_entities do |t|
      t.integer :designation_id
      t.integer :geo_entity_id

      t.timestamps
    end
    add_foreign_key "designation_geo_entities", "geo_entities",
      :name => "designation_geo_entities_geo_entity_id_fk"
    add_foreign_key "designation_geo_entities", "designations",
      :name => "designation_geo_entities_designation_id_fk"
  end
end
