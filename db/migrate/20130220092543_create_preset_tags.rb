class CreatePresetTags < ActiveRecord::Migration
  def change
    create_table :preset_tags do |t|
      t.string :name
      t.string :model

      t.timestamps
    end
  end
end
