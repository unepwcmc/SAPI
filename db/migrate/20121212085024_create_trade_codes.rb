class CreateTradeCodes < ActiveRecord::Migration
  def change
    create_table :trade_codes do |t|
      t.string :code, :null => false
      t.string :name, :null => false
      t.string :description
      t.string :type, :null => false

      t.timestamps
    end
  end
end
