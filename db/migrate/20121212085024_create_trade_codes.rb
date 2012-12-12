class CreateTradeCodes < ActiveRecord::Migration
  def change
    create_table :trade_codes do |t|
      t.string :code
      t.string :name
      t.string :type

      t.timestamps
    end
  end
end
