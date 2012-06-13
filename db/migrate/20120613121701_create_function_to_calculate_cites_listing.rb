class CreateFunctionToCalculateCitesListing < ActiveRecord::Migration
  def up
    execute <<-SQL
    CREATE TYPE listing_change_extended AS (
      id INTEGER,
      taxon_concept_id INTEGER,
      effective_at TIMESTAMP WITHOUT TIME ZONE,
      change_type CHARACTER VARYING(255),
      listing CHARACTER VARYING(255)
    )
    SQL

    execute <<-SQL
    CREATE OR REPLACE FUNCTION get_cites_listing(taxon_concepts) RETURNS hstore AS $$
      DECLARE
        taxon_concept_rec ALIAS FOR $1;
        child_taxon_concept_rec taxon_concepts;
        listing hstore;
        res hstore;
        listing_change_rec listing_change_extended;
        listing_str CHARACTER VARYING(8);
        listing_ary CHARACTER VARYING(8)[];
        dict_listing_ary CHARACTER VARYING(8)[] := ARRAY['I','II','III','nc'];
      BEGIN
        listing := ''::hstore;
        -- go through the changes in chronological order
        FOR listing_change_rec IN
        SELECT listing_changes.id, taxon_concept_id, effective_at,
          change_types.name AS change_type, species_listings.abbreviation AS listing
        FROM listing_changes
        LEFT JOIN change_types ON change_types.id = listing_changes.change_type_id
        LEFT JOIN species_listings ON species_listings.id = listing_changes.species_listing_id
        WHERE taxon_concept_id = taxon_concept_rec.id
        ORDER BY effective_at
        LOOP
          -- assume addition never acts as transfer
          -- a transfer would be a sequence of deletion, addition
          IF listing_change_rec.change_type = 'ADDITION' THEN
            listing := listing || (listing_change_rec.listing => CAST(TRUE AS VARCHAR));
          ELSIF listing_change_rec.change_type = 'DELETION' THEN
            listing := listing - listing_change_rec.listing;
          END IF;
        END LOOP;
        res := 
          ('cites_I' => CAST(listing ? 'I' AS VARCHAR)) ||
          ('cites_II' => CAST(listing ? 'II' AS VARCHAR)) ||
          ('cites_III' => CAST(listing ? 'III' AS VARCHAR)) ||
          ('nc' => CAST(listing ? 'NC' AS VARCHAR)) ||
          ('incomplete' => CAST(listing ? 'incomplete' AS VARCHAR));
        -- go through the same process for all the children
        -- reuse hstore variable
        listing := ''::hstore;
        FOR child_taxon_concept_rec IN
        SELECT * FROM taxon_concepts WHERE parent_id = taxon_concept_rec.id
        LOOP
          listing := listing || get_cites_listing(child_taxon_concept_rec);
        END LOOP;
        IF listing ? 'incomplete' THEN
          listing := listing - 'incomplete';
          res := res || ('nc' => t);
        END IF;
        res := res || listing;
        FOREACH listing_str IN ARRAY dict_listing_ary
        LOOP
          IF res @> ('cites_' || listing_str => CAST(TRUE AS VARCHAR)) THEN
            listing_ary := listing_ary || listing_str;
          END IF;
        END LOOP;
        res := res || ('listing_str' => CAST(listing_ary AS VARCHAR));
        RETURN res;
      END;
    $$ LANGUAGE plpgsql;
    SQL

  end

  def down
    execute 'DROP FUNCTION get_cites_listing(taxon_concepts)'
    execute 'DROP TYPE IF EXISTS listing_change_extended CASCADE;'
  end
end
