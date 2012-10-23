class AddAuthorYearToTaxonConceptsMview < ActiveRecord::Migration
  def up
    add_column :taxon_concepts_mview, :author_year, :string
    execute <<-SQL
    UPDATE taxon_concepts_mview SET
    author_year = taxon_concepts.author_year
    FROM taxon_concepts
    WHERE taxon_concepts_mview.id = taxon_concepts.id
    SQL
  end
  def down
    remove_column :taxon_concepts_mview, :author_year
  end
end
