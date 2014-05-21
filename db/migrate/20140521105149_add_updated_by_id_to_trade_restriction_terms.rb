class AddUpdatedByIdToTradeRestrictionTerms < ActiveRecord::Migration
  def change
    add_column :trade_restriction_terms, :updated_by_id, :integer
  end
end
