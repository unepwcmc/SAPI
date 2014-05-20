class CreateValidTaxonConceptAnnexYearMview < ActiveRecord::Migration
  def up
    execute <<-SQL
    CREATE TABLE IF NOT EXISTS valid_taxon_concept_annex_year_mview
    (
      taxon_concept_id integer,
      annex character varying(255),
      effective_from date,
      effective_to date
    );

    DROP INDEX IF EXISTS tmp_valid_taxon_concept_annex_taxon_concept_id_annex_effect_idx;

    CREATE INDEX valid_taxon_concept_annex_year_mview_idx
      ON valid_taxon_concept_annex_year_mview
      USING btree
      (taxon_concept_id, annex COLLATE pg_catalog."default", effective_from, effective_to);
    SQL
  end
  def down
  end
end
