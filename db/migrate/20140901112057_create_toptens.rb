class CreateToptens < ActiveRecord::Migration
  def change
    create_table :toptens do |t|
      t.string :species

      t.timestamps
    end
  end
end
