class CreateFunctionToRebuildDatabase < ActiveRecord::Migration
  def up

    execute <<-SQL
      CREATE OR REPLACE FUNCTION sapi_rebuild() RETURNS void AS $$
        BEGIN
          RAISE NOTICE 'Rebuilding SAPI database';
          RAISE NOTICE 'TODO';
        END;
      $$ LANGUAGE plpgsql;
    SQL

    execute <<-SQL
      COMMENT ON FUNCTION sapi_rebuild() IS
      'Procedure to rebuild the computed fields in the database.'
    SQL
  end

  def down
    execute "DROP FUNCTION sapi_rebuild()"
  end
end
