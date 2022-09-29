class CreateCitesCaptivityProcesses < ActiveRecord::Migration
  def change
    create_table :cites_captivity_processes do |t|
      t.string :resolution
      t.references :taxon_concept, index: true
      t.references :geo_entity
      t.references :start_event
      t.datetime :start_date
      t.string :status # change to Enum type after migrating to rails 4.1
      t.integer  :created_by_id
      t.integer  :updated_by_id
      t.text :notes

      t.timestamps
    end
  end
end
