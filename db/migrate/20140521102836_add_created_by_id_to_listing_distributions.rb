class AddCreatedByIdToListingDistributions < ActiveRecord::Migration
  def change
    add_column :listing_distributions, :created_by_id, :integer
  end
end
