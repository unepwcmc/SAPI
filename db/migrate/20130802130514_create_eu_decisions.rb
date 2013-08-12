class CreateEuDecisions < ActiveRecord::Migration
  def change
    drop_table :eu_decisions

    create_table :eu_decisions do |t|
      t.boolean :is_current
      t.text :notes
      t.text :internal_notes
      t.integer :taxon_concept_id
      t.integer :geo_entity_id
      t.datetime :start_date
      t.integer :start_event_id
      t.datetime :end_date
      t.integer :end_event_id
      t.string :type
      t.string :restriction
      t.boolean :conditions_apply

      t.timestamps
    end
    add_foreign_key "eu_decisions", "taxon_concepts", :name => "eu_decisions_taxon_concept_id_fk"
    add_foreign_key "eu_decisions", "geo_entities", :name => "eu_decisions_geo_entity_id_fk"
    add_foreign_key "eu_decisions", "events", :name => "eu_decisions_start_event_id_fk", :column => 'start_event_id'
    add_foreign_key "eu_decisions", "events", :name => "eu_decisions_end_event_id_fk", :column => 'end_event_id'
  end
end
