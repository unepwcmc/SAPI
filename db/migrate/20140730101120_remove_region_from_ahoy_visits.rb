class RemoveRegionFromAhoyVisits < ActiveRecord::Migration
  def up
    remove_column :ahoy_visits, :region
  end

  def down
    add_column :ahoy_visits, :region, :string
  end
end
