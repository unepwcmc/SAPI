# One row per designation and geo entity: Importers::DesignationGeoEntitiesImporter
# upserts on exactly this pair, and upsert_all needs a real unique index to
# resolve the conflict against.
#
# Nothing stopped a pair being written twice before - the 2013 data holds at
# least one - so the copies go first, keeping the oldest, or the index cannot
# be built. They carry nothing but the pair itself, so no information is lost,
# and nothing can put them back on the way down.
class AddUniqueIndexToDesignationGeoEntities < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  # Rails' own name for a two-column index here is too long, and it falls back
  # to a hash nobody can read.
  INDEX_NAME = 'index_designation_geo_entities_on_designation_and_geo_entity'

  def up
    # strong_migrations cannot see inside execute, so it asks. A DELETE of the
    # copies only, on a table of a few hundred rows that nothing reads yet.
    safety_assured do
      execute <<-SQL.squish
        DELETE FROM designation_geo_entities
        WHERE id IN (
          SELECT id FROM (
            SELECT id, ROW_NUMBER() OVER (
              PARTITION BY designation_id, geo_entity_id ORDER BY id
            ) AS position
            FROM designation_geo_entities
          ) numbered
          WHERE position > 1
        )
      SQL
    end

    add_index :designation_geo_entities, [ :designation_id, :geo_entity_id ],
      unique: true, name: INDEX_NAME, algorithm: :concurrently, if_not_exists: true
  end

  def down
    remove_index :designation_geo_entities, name: INDEX_NAME, algorithm: :concurrently, if_exists: true
  end
end
