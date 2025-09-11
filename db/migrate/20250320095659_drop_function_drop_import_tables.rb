##
# Remove the `drop_import_tables()` function. These tables seem to have been
# used for the initial population of Species+ from the CITES Trade Database.
#
# Remaining references to import tables used in rake tasks should use temp
# tables which disappear at the end of a transaction.
class DropFunctionDropImportTables < ActiveRecord::Migration[7.1]
  def up
    safety_assured do
      execute 'SELECT drop_import_tables();'
      execute 'DROP FUNCTION IF EXISTS drop_import_tables();'
    end
  end

  def down
    safety_assured do
      # NB: this function definition used to live in db/helpers/000_helpers.sql
      execute <<-SQL.squish
        CREATE OR REPLACE FUNCTION drop_import_tables()
          RETURNS void
          LANGUAGE plpgsql
        AS $$
          DECLARE
            current_table_name TEXT;
          BEGIN
            FOR current_table_name IN SELECT table_name FROM information_schema.tables
            WHERE table_name LIKE '%_import'
              AND table_type != 'VIEW'
            LOOP
              EXECUTE 'DROP TABLE ' || current_table_name || ' CASCADE';
            END LOOP;
            RETURN;
          END;
        $$;
      SQL
    end
  end
end
