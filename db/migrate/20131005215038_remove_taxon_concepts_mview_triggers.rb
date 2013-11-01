class RemoveTaxonConceptsMviewTriggers < ActiveRecord::Migration
  def up
     execute <<-SQL
    DROP FUNCTION IF EXISTS trg_taxon_concepts_u() CASCADE;
    DROP FUNCTION IF EXISTS trg_taxon_concepts_d() CASCADE;
    DROP FUNCTION IF EXISTS trg_taxon_concepts_i() CASCADE;
    DROP FUNCTION IF EXISTS trg_ranks_u() CASCADE;
    DROP FUNCTION IF EXISTS trg_taxon_names_u() CASCADE;
    DROP FUNCTION IF EXISTS trg_common_names_u() CASCADE;
    DROP FUNCTION IF EXISTS trg_taxon_commons_ui() CASCADE;
    DROP FUNCTION IF EXISTS trg_taxon_commons_d() CASCADE;
    DROP FUNCTION IF EXISTS trg_taxon_relationships_ui() CASCADE;
    DROP FUNCTION IF EXISTS trg_taxon_relationships_d() CASCADE;
    DROP FUNCTION IF EXISTS trg_geo_entities_u() CASCADE;
    DROP FUNCTION IF EXISTS trg_distributions_ui() CASCADE;
    DROP FUNCTION IF EXISTS trg_distributions_d() CASCADE;
    DROP FUNCTION IF EXISTS trg_taxon_concept_references_ui() CASCADE;
    DROP FUNCTION IF EXISTS trg_taxon_concept_references_d() CASCADE;
    DROP FUNCTION IF EXISTS trg_names_and_ranks() CASCADE;
    DROP FUNCTION IF EXISTS taxon_concepts_refresh_row(row_id INTEGER) CASCADE;
    DROP FUNCTION IF EXISTS taxon_concepts_invalidate_row(id INTEGER) CASCADE;
    SQL
  end

  def down
  end
end
