class CreateDownloads < ActiveRecord::Migration
  def change
    create_table :downloads do |t|
      t.string :type
      t.string :format
      t.string :status

      t.timestamps
    end
  end
end
