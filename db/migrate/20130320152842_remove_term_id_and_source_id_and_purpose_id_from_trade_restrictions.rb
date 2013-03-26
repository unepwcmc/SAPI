class RemoveTermIdAndSourceIdAndPurposeIdFromTradeRestrictions < ActiveRecord::Migration
  def up
    remove_column :trade_restrictions, :term_id
    remove_column :trade_restrictions, :source_id
    remove_column :trade_restrictions, :purpose_id
  end

  def down
    add_column :trade_restrictions, :purpose_id, :integer
    add_column :trade_restrictions, :source_id, :integer
    add_column :trade_restrictions, :term_id, :integer
  end
end
