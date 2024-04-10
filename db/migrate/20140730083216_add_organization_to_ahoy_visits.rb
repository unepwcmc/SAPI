class AddOrganizationToAhoyVisits < ActiveRecord::Migration[4.2]
  def change
    add_column :ahoy_visits, :organization, :text
  end
end
