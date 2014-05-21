class AddCreatedByIdToDistributions < ActiveRecord::Migration
  def change
    add_column :distributions, :created_by_id, :integer
  end
end
