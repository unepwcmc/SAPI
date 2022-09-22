class CreateCaptivityProcesses < ActiveRecord::Migration
  def change
    create_table :captivity_processes do |t|
      t.string :resolution
      t.integer :taxon_concept_id
      t.integer :geo_entity_id
      t.datetime :date_entry
      t.datetime :start_date
      t.integer :status
      t.text :notes

      t.timestamps
    end
  end
end
