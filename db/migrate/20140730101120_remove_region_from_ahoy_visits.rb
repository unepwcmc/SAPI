class RemoveRegionFromAhoyVisits < ActiveRecord::Migration[4.2]
  def up
    remove_column :ahoy_visits, :region
  end

  def down
    add_column :ahoy_visits, :region, :string
  end
end
