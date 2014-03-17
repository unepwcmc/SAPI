class AddTimeStampsToDistributionReferences < ActiveRecord::Migration
  def change
    add_column :distribution_references, :created_at, :datetime
    add_column :distribution_references, :updated_at, :datetime
  end
end
