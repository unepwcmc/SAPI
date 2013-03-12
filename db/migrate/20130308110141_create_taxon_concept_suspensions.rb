class CreateTaxonConceptSuspensions < ActiveRecord::Migration
  def change
    create_table :taxon_concept_suspensions do |t|
      t.integer :taxon_concept_id
      t.integer :suspension_id

      t.timestamps
    end
  end
end
