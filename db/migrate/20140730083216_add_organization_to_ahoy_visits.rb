class AddOrganizationToAhoyVisits < ActiveRecord::Migration
  def change
    add_column :ahoy_visits, :organization, :text
  end
end
