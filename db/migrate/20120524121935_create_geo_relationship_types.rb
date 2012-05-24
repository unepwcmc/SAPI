class CreateGeoRelationshipTypes < ActiveRecord::Migration
  def change
    create_table :geo_relationship_types do |t|
      t.string :name, :null => false, :unique => true

      t.timestamps
    end
  end
end
