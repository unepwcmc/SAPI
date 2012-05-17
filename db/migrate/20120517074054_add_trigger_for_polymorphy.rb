class AddTriggerForPolymorphy < ActiveRecord::Migration
  def up
    execute <<-eos
      CREATE OR REPLACE FUNCTION distribution_component_insert_trigger_fun() RETURNS TRIGGER AS $$
      BEGIN
        IF (NEW."component_type" = 'Country') THEN
          INSERT INTO country_distribution_components VALUES (NEW.*);
        ELSIF (NEW."component_type" = 'Bru') THEN
          INSERT INTO bru_distribution_components VALUES (NEW.*);
        ELSIF (NEW."component_type" = 'Region') THEN
          INSERT INTO region_distribution_components VALUES (NEW.*);
        ELSE
          RAISE EXCEPTION 'Wrong "component_type"="%", fix component_type_insert_trigger_fun() fun', NEW."component_type";
        END IF;
        RETURN NULL;
      END; $$ LANGUAGE plpgsql;
    eos
    execute <<-eos
      CREATE TRIGGER distribution_component_insert_trigger
      BEFORE INSERT ON distribution_components
      FOR EACH ROW EXECUTE PROCEDURE distribution_component_insert_trigger_fun();
    eos
  end

  def down
    execute "DROP TRIGGER distribution_component_insert_trigger ON distribution_components;"
    execute "DROP FUNCTION distribution_component_insert_trigger_fun();"
  end
end
