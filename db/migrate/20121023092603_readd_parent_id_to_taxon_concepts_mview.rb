class ReaddParentIdToTaxonConceptsMview < ActiveRecord::Migration
  def up
    execute <<-SQL
    UPDATE taxon_concepts_mview SET
    parent_id = taxon_concepts.parent_id
    FROM taxon_concepts
    WHERE taxon_concepts_mview.id = taxon_concepts.id
    SQL
  end
  def down
  end
end
