class AddOriginalIdToTradeRestrictions < ActiveRecord::Migration
  def change
    add_column :trade_restrictions, :original_id, :integer
  end
end
