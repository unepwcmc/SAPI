class CreateEuDecisions < ActiveRecord::Migration
  def change
    create_table :eu_decisions do |t|
      t.string :type
      t.integer :law_id
      t.integer :taxon_concept_id
      t.integer :geo_entity_id
      t.datetime :start_date
      t.datetime :end_date
      t.string :restriction
      t.text :restriction_text
      t.integer :term_id
      t.integer :source_id
      t.boolean :conditions
      t.text :comments
      t.boolean :is_current

      t.timestamps
    end
  end
end
