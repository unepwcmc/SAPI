class AddCreatedByIdToTradeRestrictionTerms < ActiveRecord::Migration
  def change
    add_column :trade_restriction_terms, :created_by_id, :integer
  end
end
