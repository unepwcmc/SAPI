class AddCreatedByIdToDistributionReferences < ActiveRecord::Migration
  def change
    add_column :distribution_references, :created_by_id, :integer
  end
end
