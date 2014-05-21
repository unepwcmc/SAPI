class AddUpdatedByIdToTradeRestrictionSources < ActiveRecord::Migration
  def change
    add_column :trade_restriction_sources, :updated_by_id, :integer
  end
end
