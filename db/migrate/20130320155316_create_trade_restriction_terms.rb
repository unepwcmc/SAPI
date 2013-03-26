class CreateTradeRestrictionTerms < ActiveRecord::Migration
  def change
    create_table :trade_restriction_terms do |t|
      t.integer :trade_restriction_id
      t.integer :term_id

      t.timestamps
    end
  end
end
