class AddUpdatedByIdToDistributions < ActiveRecord::Migration
  def change
    add_column :distributions, :updated_by_id, :integer
  end
end
