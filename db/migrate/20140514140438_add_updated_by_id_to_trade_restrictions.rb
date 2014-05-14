class AddUpdatedByIdToTradeRestrictions < ActiveRecord::Migration
  def change
    add_column :trade_restrictions, :updated_by_id, :integer
  end
end
