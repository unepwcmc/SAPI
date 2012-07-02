class AddIsPartyToListingDistributions < ActiveRecord::Migration
  def change
    add_column :listing_distributions, :is_party, :boolean, :null => false, :default => true
  end
end
