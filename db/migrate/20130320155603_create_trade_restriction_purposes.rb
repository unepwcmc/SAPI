class CreateTradeRestrictionPurposes < ActiveRecord::Migration
  def change
    create_table :trade_restriction_purposes do |t|
      t.integer :trade_restriction_id
      t.integer :purpose_id

      t.timestamps
    end
  end
end
