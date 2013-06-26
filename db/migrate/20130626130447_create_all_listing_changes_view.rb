class CreateAllListingChangesView < ActiveRecord::Migration
  def change
    execute <<-SQL
    DROP VIEW IF EXISTS all_listing_changes_view;
    CREATE VIEW all_listing_changes_view AS
    SELECT
        designation_id,
        ROW_NUMBER() OVER (PARTITION BY designation_id, self_and_ancestors.original_id ORDER BY effective_at, tree_distance)::INT AS timeline_position,
        listing_changes.id,
        self_and_ancestors.original_id AS original_taxon_concept_id,
        taxon_concept_id,
        species_listing_id,
        change_type_id,
        inclusion_taxon_concept_id,
        effective_at::DATE,
        self_and_ancestors.tree_distance
    FROM listing_changes
    JOIN (
      SELECT *, ROW_NUMBER() OVER(PARTITION BY original_id) -1 AS tree_distance FROM (
        SELECT id AS original_id,
        (data->(LOWER(higher_or_equal_ranks_names(data->'rank_name')) || '_id'))::INT AS id
        FROM taxon_concepts
      ) q
    ) self_and_ancestors ON listing_changes.taxon_concept_id = self_and_ancestors.id
    JOIN change_types ON change_types.id = listing_changes.change_type_id
    --JOIN designations ON designations.id = change_types.designation_id AND designations.name = 'CITES'
    SQL
  end
end
