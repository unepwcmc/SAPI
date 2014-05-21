class AddUpdatedByIdToTradeRestrictionPurposes < ActiveRecord::Migration
  def change
    add_column :trade_restriction_purposes, :updated_by_id, :integer
  end
end
