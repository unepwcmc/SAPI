class AddCreatedByIdToTradeRestrictionSources < ActiveRecord::Migration
  def change
    add_column :trade_restriction_sources, :created_by_id, :integer
  end
end
