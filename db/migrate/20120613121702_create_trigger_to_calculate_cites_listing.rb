class CreateTriggerToCalculateCitesListing < ActiveRecord::Migration
  def up

    execute <<-SQL
    CREATE OR REPLACE FUNCTION listing_changes_cites_listing_trg_func() RETURNS trigger AS $listing_changes_cites_listing_trg_func$
      DECLARE
        designation_name CHARACTER VARYING(255);
        taxon_concept_rec taxon_concepts;
      BEGIN
        SELECT designations.name INTO designation_name
        FROM species_listings
        LEFT JOIN designations ON designation_id = designations.id
        WHERE species_listings.id = NEW.species_listing_id;
        IF designation_name = 'CITES' THEN
          SELECT * INTO taxon_concept_rec
          FROM taxon_concepts WHERE id = NEW.taxon_concept_id;
          UPDATE taxon_concepts SET listing = get_cites_listing(taxon_concept_rec);
        END IF;
        RETURN NULL;
      END;
    $listing_changes_cites_listing_trg_func$ LANGUAGE plpgsql;
    SQL

    execute <<-SQL
    COMMENT ON FUNCTION listing_changes_cites_listing_trg_func()
    IS 'Trigger function that updates cites listing fields in the taxon_concepts.listing column';
    SQL

    execute <<-SQL
    CREATE TRIGGER listing_changes_insert_trigger
      AFTER INSERT ON listing_changes
      FOR EACH ROW
      EXECUTE PROCEDURE listing_changes_cites_listing_trg_func();
    SQL

    execute <<-SQL
    CREATE TRIGGER listing_changes_update_trigger
      AFTER UPDATE ON listing_changes
      FOR EACH ROW
      EXECUTE PROCEDURE listing_changes_cites_listing_trg_func();
    SQL

  end
  
  def down
    #execute "DROP TRIGGER IF EXISTS listing_changes_update_trigger ON listing_changes;"
    #execute "DROP TRIGGER IF EXISTS listing_changes_insert_trigger ON listing_changes;"
  end
end
