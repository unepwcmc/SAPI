class CreateInitialSchema < ActiveRecord::Migration
  def change
    create_table "authors", :force => true do |t|
      t.string   "first_name"
      t.string   "middle_name"
      t.string   "last_name",   :null => false
      t.datetime "created_at",  :null => false
      t.datetime "updated_at",  :null => false
    end
  
    create_table "designations", :force => true do |t|
      t.string   "name",       :null => false
      t.datetime "created_at", :null => false
      t.datetime "updated_at", :null => false
    end
  
    create_table "distributions", :force => true do |t|
      t.datetime "created_at", :null => false
      t.datetime "updated_at", :null => false
    end
  
    create_table "ranks", :force => true do |t|
      t.string   "name",       :null => false
      t.integer  "parent_id"
      t.datetime "created_at", :null => false
      t.datetime "updated_at", :null => false
    end
  
    create_table "reference_authors", :force => true do |t|
      t.integer  "reference_id", :null => false
      t.integer  "author_id",    :null => false
      t.integer  "index"
      t.datetime "created_at",   :null => false
      t.datetime "updated_at",   :null => false
    end
  
    create_table "references", :force => true do |t|
      t.string   "title",      :null => false
      t.string   "year"
      t.datetime "created_at", :null => false
      t.datetime "updated_at", :null => false
    end
  
    create_table "taxon_concepts", :force => true do |t|
      t.integer  "parent_id"
      t.integer  "lft"
      t.integer  "rgt"
      t.integer  "rank_id",        :null => false
      t.datetime "created_at",     :null => false
      t.datetime "updated_at",     :null => false
      t.integer  "spcrecid"
      t.integer  "depth"
      t.integer  "designation_id", :null => false
      t.integer  "taxon_name_id",  :null => false
    end
  
    create_table "taxon_distributions", :force => true do |t|
      t.integer  "taxon_id",        :null => false
      t.integer  "distribution_id", :null => false
      t.datetime "created_at",      :null => false
      t.datetime "updated_at",      :null => false
    end
  
    create_table "taxon_names", :force => true do |t|
      t.string   "scientific_name", :null => false
      t.integer  "basionym_id"
      t.datetime "created_at",      :null => false
      t.datetime "updated_at",      :null => false
    end
  
    create_table "taxon_references", :force => true do |t|
      t.integer  "referenceable_id"
      t.string   "referenceable_type", :default => "Taxon", :null => false
      t.integer  "reference_id",                            :null => false
      t.datetime "created_at",                              :null => false
      t.datetime "updated_at",                              :null => false
    end
  
    create_table "taxon_relationship_types", :force => true do |t|
      t.string   "name",       :null => false
      t.datetime "created_at", :null => false
      t.datetime "updated_at", :null => false
    end
  
    create_table "taxon_relationships", :force => true do |t|
      t.integer  "taxon_concept_id",           :null => false
      t.integer  "other_taxon_concept_id",     :null => false
      t.integer  "taxon_relationship_type_id", :null => false
      t.datetime "created_at",                 :null => false
      t.datetime "updated_at",                 :null => false
    end
  
    add_foreign_key "ranks", "ranks", :name => "ranks_parent_id_fk", :column => "parent_id"
  
    add_foreign_key "taxon_concepts", "designations", :name => "taxon_concepts_designation_id_fk"
    add_foreign_key "taxon_concepts", "ranks", :name => "taxon_concepts_rank_id_fk"
    add_foreign_key "taxon_concepts", "taxon_concepts", :name => "taxon_concepts_parent_id_fk", :column => "parent_id"
    add_foreign_key "taxon_concepts", "taxon_names", :name => "taxon_concepts_taxon_name_id_fk"
  
    add_foreign_key "taxon_names", "taxon_names", :name => "taxon_names_basionym_id_fk", :column => "basionym_id"
  
    add_foreign_key "taxon_relationships", "taxon_concepts", :name => "taxon_relationships_taxon_concept_id_fk"
    add_foreign_key "taxon_relationships", "taxon_relationship_types", :name => "taxon_relationships_taxon_relationship_type_id_fk"
  end
end
