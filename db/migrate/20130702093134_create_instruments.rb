class CreateInstruments < ActiveRecord::Migration
  def change
    create_table :instruments do |t|
      t.integer :designation_id
      t.string :name

      t.timestamps
    end

    add_foreign_key "instruments", "designations", :name => "instruments_designation_id_fk"
  end
end
