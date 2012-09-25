class CreateMaterializedTaxonConceptsView < ActiveRecord::Migration
  def up
    execute <<-SQL
    CREATE TABLE mat_taxon_concepts_view AS
    SELECT *,
    false as dirty,
    null::timestamp with time zone as expiry
    FROM taxon_concepts_view;
    SQL
  end

  def down
    drop_table :mat_taxon_concepts_view
  end
end
