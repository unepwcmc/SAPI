class AddGenericAnnotationParentSymbolToTaxonConceptsMview < ActiveRecord::Migration
  def up
    add_column :taxon_concepts_mview, :generic_annotation_parent_symbol, :string
    execute <<-SQL
    UPDATE taxon_concepts_mview SET
    generic_annotation_symbol = taxon_concepts_view.generic_annotation_symbol,
    generic_annotation_parent_symbol = taxon_concepts_view.generic_annotation_parent_symbol,
    specific_annotation_symbol = taxon_concepts_view.specific_annotation_symbol
    FROM taxon_concepts_view
    WHERE taxon_concepts_mview.id = taxon_concepts_view.id
    SQL
  end
  def down
    remove_column :taxon_concepts_mview, :generic_annotation_parent_symbol
  end
end
