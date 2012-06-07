class FixTaxonConceptTriggers < ActiveRecord::Migration
  def up

    execute "DROP FUNCTION IF EXISTS update_taxon_concept_hstore(taxon_concepts);"

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
    res := ''::hstore;
    SELECT * FROM taxon_concept_with_ancestors(NEW.id) INTO taxon_data_rec;
    IF FOUND THEN
      upper = array_upper(taxon_data_rec.ranks, 1);
      IF upper IS NOT NULL THEN
        rank_name := taxon_data_rec.ranks[upper];
        scientific_name := taxon_data_rec.names[upper];
        -- for each ancestor create a field in the hstore
        FOR i IN array_lower(taxon_data_rec.ranks, 1)..upper
        LOOP
          res := res || (LOWER(taxon_data_rec.ranks[i]) || '_name' => taxon_data_rec.names[i]);
        END LOOP;
        -- construct the full name for display purposes
        IF rank_name = 'SPECIES' THEN
          -- now create a binomen for full name
          full_name := CAST(res -> 'genus_name' AS character varying(255)) || ' ' ||
          LOWER(scientific_name);
        ELSIF rank_name = 'SUBSPECIES' THEN
          -- now create a trinomen for full name
          full_name := CAST(res -> 'genus_name' AS character varying(255)) || ' ' ||
          LOWER(CAST(res -> 'species_name' AS character varying(255))) || ' ' ||
          scientific_name;
        ELSE
           full_name := scientific_name;
        END IF;
        res := res || 
        ('scientific_name' => scientific_name) ||
        ('full_name' => full_name) ||
        ('rank_name' => rank_name);
      END IF;
      UPDATE taxon_concepts SET data = res WHERE id = NEW.id;
    END IF;
    RETURN NULL;
  END;
$update_taxon_concept_hstore_trigger$ LANGUAGE plpgsql;
SQL
  end

  def down
    
  end
end
