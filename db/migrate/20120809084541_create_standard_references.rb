class CreateStandardReferences < ActiveRecord::Migration
  def change
    create_table :standard_references do |t|
      t.string :author
      t.text :title
      t.integer :year
      t.integer :reference_id
      t.integer :reference_legacy_id
      t.string :taxon_concept_name
      t.string :taxon_concept_rank
      t.integer :taxon_concept_id
      t.integer :species_legacy_id
      t.integer :position

      t.timestamps
    end
  end
end
