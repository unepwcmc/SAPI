class CreateCitesProcesses < ActiveRecord::Migration
  def change
    create_table :cites_processes do |t|
      t.string :resolution
      t.references :taxon_concept, index: true
      t.references :geo_entity
      t.references :start_event
      t.datetime :start_date
      t.string :status # change to Enum type after migrating to rails 4.1
      t.string :type
      t.integer :created_by_id
      t.integer :updated_by_id
      t.text :notes
      t.integer :case_id

      t.timestamps
    end
  end
end
