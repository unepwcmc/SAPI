class RemoveDistributionTriggersAndInheritedTables < ActiveRecord::Migration
  def up
    execute "DROP TRIGGER distribution_component_insert_trigger ON distribution_components;"
    execute "DROP FUNCTION distribution_component_insert_trigger_fun();"
    execute("
      DROP TABLE country_distribution_components;
      DROP TABLE bru_distribution_components;
      DROP TABLE region_distribution_components;
    ")
  end

  def down
  end
end
