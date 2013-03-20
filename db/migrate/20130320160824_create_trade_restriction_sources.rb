class CreateTradeRestrictionSources < ActiveRecord::Migration
  def change
    create_table :trade_restriction_sources do |t|
      t.integer :trade_restriction_id
      t.integer :source_id

      t.timestamps
    end
  end
end
