class CreateCommonNames < ActiveRecord::Migration
  def change
    create_table :common_names do |t|
      t.string :name
      t.integer :reference_id
      t.integer :language_id

      t.timestamps
    end
  end
end
