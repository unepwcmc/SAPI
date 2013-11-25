class RemoveReportedValuesColumns < ActiveRecord::Migration
  def change
    #redefine drop sandboxes in case someone is migrating from scratch
    execute "
    CREATE OR REPLACE FUNCTION drop_trade_sandboxes() RETURNS void
      LANGUAGE plpgsql
      AS $$
      DECLARE
        current_table_name TEXT;
      BEGIN
        FOR current_table_name IN SELECT table_name FROM information_schema.tables
        WHERE table_name LIKE 'trade_sandbox%'
          AND table_name != 'trade_sandbox_template'
          AND table_type != 'VIEW'
        LOOP
          EXECUTE 'DROP TABLE ' || current_table_name || ' CASCADE';
        END LOOP;
        RETURN;
      END;
      $$;
    "
    execute "select * from drop_trade_sandboxes()"
    Trade::AnnualReportUpload.where(:is_done => false).each do |aru|
      aru.destroy
    end
    remove_column :trade_sandbox_template, :reported_appendix
    remove_column :trade_sandbox_template, :reported_species_name
    remove_column :trade_shipments, :reported_appendix
    remove_column :trade_shipments, :reported_species_name
  end
end
