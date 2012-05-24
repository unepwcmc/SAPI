class CreateGeoEntityTypes < ActiveRecord::Migration
  def change
    create_table :geo_entity_types do |t|
      t.string :name, :null => false, :unique => true

      t.timestamps
    end
  end
end
