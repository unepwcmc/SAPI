class CreateMappingTaxa < ActiveRecord::Migration[8.1]
  def change
    create_table :mapping_taxa, id: :uuid do |t|
      t.references :matchable_taxonomy, null: false, foreign_key: true

      # The name's own identifier. Null for IUCN synonyms, which are the only
      # ones issued without an id by their source; every other platform gives
      # its synonyms one.
      t.string :taxon_nid

      # The concept this name belongs to. Null only for the 149 WoRMS nomina
      # nuda, which were never validly published and so point at nothing.
      t.string :accepted_taxon_nid

      t.string :name_status, null: false
      t.references :rank, type: :integer, foreign_key: true
      t.string :scientific_name, null: false
      t.string :author_year
      # The run that wrote this row, which is how a whole upload is found,
      # replaced or deleted. Not the file's name: two uploads can share one,
      # and the name alone says nothing about who sent it or when. The run
      # holds the file itself, so the name is still reachable.
      t.references :import_run, null: false, foreign_key: true

      t.timestamps
    end

    # The API resolves accepted names only, and among those taxon_nid is
    # present and unique on every platform. It is neither once synonyms are
    # included, so the index is scoped rather than made unique.
    add_index :mapping_taxa, [ :matchable_taxonomy_id, :taxon_nid ],
      where: "name_status = 'A'",
      name: 'index_mapping_taxa_on_accepted_nid'

    # Every name belonging to one concept, for showing how a match was reached.
    add_index :mapping_taxa, [ :matchable_taxonomy_id, :accepted_taxon_nid ],
      name: 'index_mapping_taxa_on_concept'
  end
end
