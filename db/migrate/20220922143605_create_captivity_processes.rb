class CreateCaptivityProcesses < ActiveRecord::Migration
  def change
    create_table :captivity_processes do |t|
      t.string :resolution
      t.references :taxon_concept, index: true
      t.references :geo_entity
      t.references :start_event
      t.datetime :start_date
      t.integer :status
      t.text :notes

      t.timestamps
    end
  end
end
