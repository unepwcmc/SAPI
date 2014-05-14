class AddCreatedByIdToTradeRestrictions < ActiveRecord::Migration
  def change
    add_column :trade_restrictions, :created_by_id, :integer
  end
end
