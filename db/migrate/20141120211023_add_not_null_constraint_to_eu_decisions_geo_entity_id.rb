class AddNotNullConstraintToEuDecisionsGeoEntityId < ActiveRecord::Migration[4.2]
  def change
    execute 'DROP VIEW IF EXISTS eu_decisions_view'
    change_column :eu_decisions, :geo_entity_id, :integer, null: false
  end
end
