class CreateNomenclatureChanges < ActiveRecord::Migration
  def change
    create_table :nomenclature_changes do |t|
      t.integer :event_id
      t.integer :created_by_id
      t.integer :updated_by_id

      t.timestamps
    end
  end
end
