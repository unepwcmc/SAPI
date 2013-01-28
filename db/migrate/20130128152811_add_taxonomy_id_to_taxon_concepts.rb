class AddTaxonomyIdToTaxonConcepts < ActiveRecord::Migration

  def change
    taxonomy = Taxonomy.find_or_create_by_name(Taxonomy::WILDLIFE_TRADE)
    add_column :taxon_concepts, :taxonomy_id, :integer
    execute <<-SQL
      UPDATE taxon_concepts SET taxonomy_id = designations.taxonomy_id
      FROM taxon_concepts q
      INNER JOIN designations ON q.designation_id = designations.id
      WHERE q.id = taxon_concepts.id
    SQL
    change_table :taxon_concepts do |t|
      t.change :taxonomy_id, :integer, :null => false, :default => taxonomy.id
      t.foreign_key :taxonomies, :name => "taxon_concepts_taxonomy_id_fk"
    end
  end

end
