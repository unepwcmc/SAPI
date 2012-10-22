class AddSynonymAuthorYearsToTaxonConceptsMview < ActiveRecord::Migration
  def up
    execute 'ALTER TABLE taxon_concepts_mview ADD COLUMN synonyms_author_years_ary VARCHAR[]'
    execute <<-SQL
    UPDATE taxon_concepts_mview SET
    synonyms_author_years_ary = taxon_concepts_view.synonyms_author_years_ary
    FROM taxon_concepts_view
    WHERE taxon_concepts_mview.id = taxon_concepts_view.id
    SQL
  end
  def down
    remove_column :taxon_concepts_mview, :synonyms_author_years_ary
  end
end
