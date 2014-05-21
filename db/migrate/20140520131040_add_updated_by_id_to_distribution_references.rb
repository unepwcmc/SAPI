class AddUpdatedByIdToDistributionReferences < ActiveRecord::Migration
  def change
    add_column :distribution_references, :updated_by_id, :integer
  end
end
