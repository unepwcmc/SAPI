class AddTriggersToUpdateTaxonConceptsHstore < ActiveRecord::Migration
  def up
    execute <<-SQL
CREATE TYPE taxon_concept_with_ancestors AS (
    id integer,
    names character varying(255)[],
    ranks character varying(255)[]
);
SQL
    execute <<-SQL
CREATE OR REPLACE FUNCTION taxon_concept_with_ancestors(param_id integer) RETURNS taxon_concept_with_ancestors AS $$
  DECLARE
    tmp_rec taxon_concept_with_ancestors;
  BEGIN
      -- this recursive statement will go through the forest from the roots up
      -- and concatenate ancestor names and ranks in hierarchic order
      WITH RECURSIVE q AS
      (
      SELECT  h,
      ARRAY[taxon_names.scientific_name] AS names_ary,
      ARRAY[ranks.name] AS ranks_ary
      FROM    taxon_concepts h
      INNER JOIN taxon_names ON h.taxon_name_id = taxon_names.id
      INNER JOIN ranks ON h.rank_id = ranks.id
      WHERE h.parent_id IS NULL
      UNION ALL
      SELECT  hi,
      CAST(names_ary || taxon_names.scientific_name as character varying(255)[]),
      CAST(ranks_ary || ranks.name as character varying(255)[])
      FROM    q
      JOIN    taxon_concepts hi
      ON      hi.parent_id = (q.h).id
      INNER JOIN taxon_names ON hi.taxon_name_id = taxon_names.id
      INNER JOIN ranks ON hi.rank_id = ranks.id
      )
      SELECT
      (q.h).id,
      names_ary::VARCHAR AS names,
      ranks_ary::VARCHAR AS ranks
      INTO tmp_rec
      FROM    q
      WHERE (q.h).id = param_id;
    return tmp_rec;
  END;
$$ LANGUAGE plpgsql;
SQL
    execute <<-SQL
COMMENT ON FUNCTION taxon_concept_with_ancestors(integer) 
IS 'Returns ordered ancestor names and ranks for given taxon concept id';
SQL
    execute <<-SQL
CREATE OR REPLACE FUNCTION update_taxon_concept_hstore(taxon_concepts, OUT hstore) AS $$
  DECLARE
    in_taxon_concept_row ALIAS FOR $1;
    res ALIAS FOR $2;
    taxon_data_rec taxon_concept_with_ancestors;
    upper INTEGER;
    rank_name CHARACTER VARYING(255);
    scientific_name CHARACTER VARYING(255);
    full_name CHARACTER VARYING(255);
  BEGIN
    SELECT * FROM taxon_concept_with_ancestors(in_taxon_concept_row.id) INTO taxon_data_rec;
    IF FOUND THEN
      res := ''::hstore;
      upper = array_upper(taxon_data_rec.ranks, 1);
      IF upper IS NOT NULL THEN
        rank_name := taxon_data_rec.ranks[upper];
        scientific_name := taxon_data_rec.names[upper];
        -- for each ancestor create a field in the hstore
        FOR i IN array_lower(taxon_data_rec.ranks, 1)..upper
        LOOP
          res := res || (LOWER(taxon_data_rec.ranks[i]) => taxon_data_rec.names[i]);
        END LOOP;
        -- construct the full name for display purposes
        IF rank_name = 'SPECIES' THEN
          -- now create a binomen for full name
          full_name := CAST(res -> 'genus' AS character varying(255)) || ' ' ||
          LOWER(scientific_name);
        ELSIF rank_name = 'SUBSPECIES' THEN
          -- now create a trinomen for full name
          full_name := CAST(res -> 'genus' AS character varying(255)) || ' ' ||
          LOWER(CAST(res -> 'species' AS character varying(255))) || ' ' ||
          scientific_name;
        ELSE
           full_name := scientific_name;
        END IF;
        res := res || 
        ('scientific_name' => scientific_name) ||
        ('full_name' => full_name) ||
        ('rank_name' => rank_name);
      END IF;
    END IF;
END;
$$ LANGUAGE plpgsql;
SQL

    execute <<-SQL
COMMENT ON FUNCTION update_taxon_concept_hstore(taxon_concepts)
IS 'Updates additional fields in the hstore column';
SQL

    execute <<-SQL
CREATE OR REPLACE FUNCTION update_taxon_concept_hstore_trigger() RETURNS trigger AS $update_taxon_concept_hstore_trigger$
  BEGIN
    UPDATE taxon_concepts SET data = update_taxon_concept_hstore(NEW);
    RETURN NULL;
  END;
$update_taxon_concept_hstore_trigger$ LANGUAGE plpgsql;
SQL

    execute <<-SQL
COMMENT ON FUNCTION update_taxon_concept_hstore_trigger()
IS 'Trigger function that updates additional fields in the hstore column';
SQL

    execute <<-SQL
CREATE TRIGGER taxon_concept_insert_trigger
  AFTER INSERT ON taxon_concepts
  FOR EACH ROW
  EXECUTE PROCEDURE update_taxon_concept_hstore_trigger();
SQL

    execute <<-SQL
CREATE TRIGGER taxon_concept_update_trigger
  AFTER UPDATE ON taxon_concepts
  FOR EACH ROW
  WHEN (OLD.parent_id IS DISTINCT FROM NEW.parent_id)
  EXECUTE PROCEDURE update_taxon_concept_hstore_trigger();
SQL
  end

  def down
    execute "DROP TRIGGER IF EXISTS taxon_concept_update_trigger ON taxon_concepts;"
    execute "DROP trigger IF EXISTS taxon_concept_insert_trigger ON taxon_concepts;"
    execute "DROP FUNCTION IF EXISTS update_taxon_concept_hstore_trigger();"
    execute "DROP FUNCTION IF EXISTS update_taxon_concept_hstore(taxon_concepts);"
    execute "DROP FUNCTION IF EXISTS taxon_concept_with_ancestors(integer);"
    execute "DROP TYPE IF EXISTS taxon_concept_with_ancestors CASCADE;"
  end
end
