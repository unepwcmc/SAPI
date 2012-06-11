class AddTriggerToUpdateTaxonomicPosition < ActiveRecord::Migration
  def change
    execute <<-SQL
    CREATE OR REPLACE FUNCTION update_taxonomic_position(INTEGER) RETURNS VOID AS $$
    DECLARE
      in_parent_id ALIAS FOR $1;
      taxon_concept_id INTEGER;
    BEGIN
      UPDATE taxon_concepts
      SET data = data || 
       ('taxonomic_position' => CAST(parent_part || '.' || child_part AS CHARACTER VARYING))
      FROM (
        SELECT
        children.id, parent.data->'taxonomic_position' AS parent_part,
        row_number() OVER (ORDER BY children.data -> 'full_name') AS child_part
        FROM taxon_concepts AS children
        LEFT JOIN taxon_concepts AS parent ON children.parent_id = parent.id
        WHERE parent.id = in_parent_id
      ) children_with_positions
      WHERE taxon_concepts.id = children_with_positions.id;
      FOR taxon_concept_id IN (SELECT * FROM taxon_concepts WHERE parent_id = in_parent_id)
      LOOP
        PERFORM update_taxonomic_position(taxon_concept_id);
      END LOOP;
    END;
$$ LANGUAGE plpgsql;
SQL

    execute <<-SQL
COMMENT ON FUNCTION update_taxonomic_position(INTEGER) IS
'Updates the taxonomic position by taking the parent value and adding another ordinal to reflect alphabetical order';
SQL

    execute <<-SQL
CREATE OR REPLACE FUNCTION get_full_name(
  CHARACTER VARYING(64), CHARACTER VARYING(255), CHARACTER VARYING(255), CHARACTER VARYING(255)
  ) RETURNS CHARACTER VARYING(255) AS $$
  DECLARE
    rank_name ALIAS FOR $1;
    genus_name ALIAS FOR $2;
    species_name ALIAS FOR $3;
    scientific_name ALIAS FOR $4;
    full_name CHARACTER VARYING(255);
  BEGIN
    -- construct the full name for display purposes
    IF rank_name = 'SPECIES' THEN
      -- now create a binomen for full name
      full_name := genus_name || ' ' ||
      LOWER(scientific_name);
    ELSIF rank_name = 'SUBSPECIES' THEN
      -- now create a trinomen for full name
      full_name := genus_name || ' ' ||
      LOWER(species_name) || ' ' ||
      scientific_name;
    ELSE
       full_name := scientific_name;
    END IF;
    RETURN full_name;
  END;
$$ LANGUAGE plpgsql;
SQL

    execute <<-SQL
COMMENT ON FUNCTION get_full_name(
  CHARACTER VARYING(64), CHARACTER VARYING(255), CHARACTER VARYING(255), CHARACTER VARYING(255)
  ) IS
'Returns the full name constructed as a single name, binomen or trinomen depending on rank';
SQL

    execute <<-SQL
CREATE OR REPLACE FUNCTION update_taxon_concept_hstore_trigger() RETURNS trigger AS $update_taxon_concept_hstore_trigger$
  DECLARE
    res hstore;
    taxon_data_rec taxon_concept_with_ancestors;
    upper INTEGER;
    rank_name CHARACTER VARYING(255);
    scientific_name CHARACTER VARYING(255);
    full_name CHARACTER VARYING(255);
  BEGIN
    IF NEW.data IS NULL THEN
      res := ''::hstore;
    ELSE
      res := NEW.data;
    END IF;

    SELECT * FROM taxon_concept_with_ancestors(NEW.id) INTO taxon_data_rec;
    IF FOUND THEN
      upper = array_upper(taxon_data_rec.ranks, 1);
      IF upper IS NOT NULL THEN
        rank_name := taxon_data_rec.ranks[upper];
        scientific_name := taxon_data_rec.names[upper];
        -- for each ancestor create a field in the hstore
        FOR i IN array_lower(taxon_data_rec.ranks, 1)..upper
        LOOP
          IF rank_name <> taxon_data_rec.ranks[i] THEN
            res := res || (LOWER(taxon_data_rec.ranks[i]) || '_name' => taxon_data_rec.names[i]);
          END IF;
        END LOOP;
        full_name := get_full_name(rank_name, res -> 'genus_name', res -> 'species_name', scientific_name);
        -- taxonomic_position := res -> 'taxonomic_position';
        res := res || 
          ('scientific_name' => scientific_name) ||
          ('full_name' => full_name) ||
          ('rank_name' => rank_name);
        END IF;
      UPDATE taxon_concepts SET data = res WHERE id = NEW.id;
      IF CAST(res -> 'taxonomic_position' AS CHARACTER VARYING(64)) IS NULL THEN
        PERFORM update_taxonomic_position(NEW.parent_id);
      END IF;
    END IF;
    RETURN NULL;
  END;
$update_taxon_concept_hstore_trigger$ LANGUAGE plpgsql;
SQL
  end
end
