class CreateTaxonCommons < ActiveRecord::Migration
  def change
    create_table :taxon_commons do |t|
      t.integer :taxon_concept_id
      t.integer :common_name_id

      t.timestamps
    end
  end
end
