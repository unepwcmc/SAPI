class AddCreatedByIdToTradeRestrictionPurposes < ActiveRecord::Migration
  def change
    add_column :trade_restriction_purposes, :created_by_id, :integer
  end
end
