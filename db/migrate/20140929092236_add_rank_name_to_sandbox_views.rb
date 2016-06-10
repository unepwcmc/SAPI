class AddRankNameToSandboxViews < ActiveRecord::Migration
  def change
    execute <<-SQL

CREATE OR REPLACE FUNCTION refresh_trade_sandbox_views() RETURNS void
  LANGUAGE plpgsql
  AS $$
  DECLARE
    current_table_name TEXT;
    current_view_name TEXT;
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
      END IF;
      current_view_name := current_table_name || '_view';
      EXECUTE 'DROP VIEW IF EXISTS ' || current_view_name || ' CASCADE';
      PERFORM create_trade_sandbox_view(current_table_name, aru_id);
    END LOOP;
    RETURN;
  END;
  $$;

COMMENT ON FUNCTION refresh_trade_sandbox_views() IS '
Drops all trade_sandbox_n_view views and creates them again. Useful when the
view definition has changed and has to be applied to existing views.';


CREATE OR REPLACE FUNCTION create_trade_sandbox_view(
  target_table_name TEXT, idx INT
  ) RETURNS void
  LANGUAGE plpgsql
  AS $$
  BEGIN
    execute 'CREATE VIEW ' || target_table_name || '_view AS
      SELECT aru.point_of_view,
      CASE
        WHEN aru.point_of_view = ''E''
        THEN geo_entities.iso_code2
        ELSE trading_partner
      END AS exporter,
      CASE
        WHEN aru.point_of_view = ''E''
        THEN trading_partner
        ELSE geo_entities.iso_code2
      END AS importer,
      taxon_concepts.full_name AS accepted_taxon_name,
      taxon_concepts.data->''rank_name'' AS rank,
      taxon_concepts.rank_id,
      ' || target_table_name || '.*
      FROM ' || target_table_name || '
      JOIN trade_annual_report_uploads aru ON aru.id = ' || idx || '
      JOIN geo_entities ON geo_entities.id = aru.trading_country_id
      LEFT JOIN taxon_concepts ON taxon_concept_id = taxon_concepts.id';
    RETURN;
  END;
  $$;

    SQL

    execute "SELECT * FROM refresh_trade_sandbox_views()"
  end
end
