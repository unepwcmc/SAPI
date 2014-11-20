class AddNotNullConstraintToEuDecisionsGeoEntityId < ActiveRecord::Migration
  def change
    change_column :eu_decisions, :geo_entity_id, :integer, null: false
  end
end
