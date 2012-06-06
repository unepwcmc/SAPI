class CreateChangeTypes < ActiveRecord::Migration
  def change
    create_table :change_types do |t|
      t.string :name

      t.timestamps
    end

  end
end
