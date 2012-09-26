class CreateMaterializedTaxonConceptsView < ActiveRecord::Migration
  def up
    execute <<-SQL
    CREATE TABLE taxon_concepts_mview AS
    SELECT *,
    false as dirty,
    null::timestamp with time zone as expiry
    FROM taxon_concepts_view;
    SQL
  end

  def down
    drop_table :taxon_concepts_mview
  end
end
