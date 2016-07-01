class ChangeMultiPermitNumberColumnsToText < ActiveRecord::Migration
  def up
    sql = <<-SQL
      CREATE OR REPLACE FUNCTION drop_trade_sandbox_views() RETURNS void
        LANGUAGE plpgsql
        AS $$
        DECLARE
          current_view_name TEXT;
        BEGIN
          FOR current_view_name IN SELECT table_name FROM information_schema.tables
          WHERE table_name LIKE 'trade_sandbox%_view'
            AND table_type = 'VIEW'
          LOOP
            EXECUTE 'DROP VIEW IF EXISTS ' || current_view_name || ' CASCADE';
          END LOOP;
          RETURN;
        END;
        $$;

      CREATE OR REPLACE FUNCTION create_trade_sandbox_views() RETURNS void
        LANGUAGE plpgsql
        AS $$
        DECLARE
          current_table_name TEXT;
          aru_id INT;
        BEGIN
          FOR current_table_name IN SELECT table_name FROM information_schema.tables
          WHERE table_name LIKE 'trade_sandbox%'
            AND table_name != 'trade_sandbox_template'
            AND table_type != 'VIEW'
          LOOP
            aru_id := SUBSTRING(current_table_name, E'trade_sandbox_(\\\\d+)')::INT;
            IF aru_id IS NULL THEN
        RAISE WARNING 'Unable to determine annual report upload id from %', current_table_name;
            ELSE
        PERFORM create_trade_sandbox_view(current_table_name, aru_id);
            END IF;
          END LOOP;
          RETURN;
        END;
        $$;

      CREATE OR REPLACE FUNCTION refresh_trade_sandbox_views() RETURNS void
        LANGUAGE plpgsql
        AS $$
        BEGIN
          PERFORM drop_trade_sandbox_views();
          PERFORM create_trade_sandbox_views();
          RETURN;
        END;
        $$;

      SELECT * FROM drop_trade_sandbox_views();
      ALTER TABLE trade_sandbox_template
      ALTER COLUMN export_permit TYPE TEXT,
      ALTER COLUMN import_permit TYPE TEXT,
      ALTER COLUMN origin_permit TYPE TEXT;
      SELECT * FROM refresh_trade_sandbox_views();

      DROP VIEW IF EXISTS trade_shipments_with_taxa_view;

      ALTER TABLE trade_shipments
      ALTER COLUMN export_permit_number TYPE TEXT,
      ALTER COLUMN import_permit_number TYPE TEXT,
      ALTER COLUMN origin_permit_number TYPE TEXT;
    SQL
    execute sql
  end

  def down
  end
end
