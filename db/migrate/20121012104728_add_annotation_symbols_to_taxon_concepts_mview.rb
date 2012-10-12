class AddAnnotationSymbolsToTaxonConceptsMview < ActiveRecord::Migration
  def up
    add_column :taxon_concepts_mview, :specific_annotation_symbol, :string
    add_column :taxon_concepts_mview, :generic_annotation_symbol, :string

    execute <<-SQL
    UPDATE taxon_concepts_mview SET
    specific_annotation_symbol = taxon_concepts.listing->'specific_annotation_symbol',
    generic_annotation_symbol = taxon_concepts.listing->'generic_annotation_symbol'
    FROM taxon_concepts
    WHERE taxon_concepts_mview.id = taxon_concepts.id
    SQL
  end
  def down
    remove_column :taxon_concepts_mview, :specific_annotation_symbol
    remove_column :taxon_concepts_mview, :generic_annotation_symbol
  end
end
