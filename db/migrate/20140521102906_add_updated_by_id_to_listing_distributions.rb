class AddUpdatedByIdToListingDistributions < ActiveRecord::Migration
  def change
    add_column :listing_distributions, :updated_by_id, :integer
  end
end
