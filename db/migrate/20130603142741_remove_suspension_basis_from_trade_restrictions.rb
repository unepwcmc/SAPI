class RemoveSuspensionBasisFromTradeRestrictions < ActiveRecord::Migration
  def change
    remove_column :trade_restrictions, :suspension_basis
  end
end
