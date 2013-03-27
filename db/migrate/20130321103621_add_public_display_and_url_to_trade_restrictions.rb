class AddPublicDisplayAndUrlToTradeRestrictions < ActiveRecord::Migration
  def change
    add_column :trade_restrictions, :public_display, :boolean, :default => true
    add_column :trade_restrictions, :url, :text
  end
end
