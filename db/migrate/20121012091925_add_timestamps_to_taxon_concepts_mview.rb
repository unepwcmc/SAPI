class AddTimestampsToTaxonConceptsMview < ActiveRecord::Migration
  def up
    add_column :taxon_concepts_mview, :listing_updated_at, :datetime
    add_column :taxon_concepts_mview, :updated_at, :datetime
    add_column :taxon_concepts_mview, :created_at, :datetime
    execute <<-SQL
    UPDATE taxon_concepts_mview SET
    listing_updated_at = taxon_concepts_view.listing_updated_at,
    updated_at = taxon_concepts_view.updated_at,
    created_at = taxon_concepts_view.created_at
    FROM taxon_concepts_view
    WHERE taxon_concepts_mview.id = taxon_concepts_view.id
    SQL
  end
  def down
    remove_column :taxon_concepts_mview, :listing_updated_at
    remove_column :taxon_concepts_mview, :updated_at
    remove_column :taxon_concepts_mview, :created_at
  end
end
