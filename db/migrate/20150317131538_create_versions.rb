class CreateVersions < ActiveRecord::Migration
  def change
    create_table :versions do |t|
      t.string   :item_type, :null => false
      t.integer  :item_id,   :null => false
      t.string   :event,     :null => false
      t.string   :whodunnit
      t.text     :object
      t.datetime :created_at
    end
    add_index :versions, [:item_type, :item_id]

    create_table :taxon_concept_versions do |t|
      t.string   :item_type, :null => false
      t.integer  :item_id,   :null => false
      t.string   :event,     :null => false
      t.string   :whodunnit
      t.text     :object
      t.datetime :created_at
      t.integer  :taxon_concept_id, :null => false
      t.text     :taxonomy_name, :null => false
      t.text     :full_name, :null => false
      t.text     :author_year
      t.text     :name_status, :null => false
      t.text     :rank_name, :null => false
    end
    add_index :taxon_concept_versions, [:event]
    add_index :taxon_concept_versions, [:taxonomy_name, :created_at]
    add_index :taxon_concept_versions, [:full_name, :created_at]
  end

end
