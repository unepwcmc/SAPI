class AddParentIdToTaxonConceptsMview < ActiveRecord::Migration
  def up
    add_column :taxon_concepts_mview, :parent_id, :integer

    execute <<-SQL
    UPDATE taxon_concepts_mview SET
    parent_id = taxon_concepts.parent_id
    FROM taxon_concepts
    WHERE taxon_concepts_mview.id = taxon_concepts.id
    SQL
  end
  def down
    remove_column :taxon_concepts_mview, :parent_id
  end
end
