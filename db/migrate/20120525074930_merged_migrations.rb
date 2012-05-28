class MergedMigrations < ActiveRecord::Migration
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
  
    create_table "geo_entities", :force => true do |t|
      t.integer  "geo_entity_type_id", :null => false
      t.string   "name",               :null => false
      t.string   "long_name"
      t.string   "iso_code2"
      t.string   "iso_code3"
      t.integer  "legacy_id"
      t.string   "legacy_type"
      t.datetime "created_at",         :null => false
      t.datetime "updated_at",         :null => false
    end
  
    create_table "geo_entity_types", :force => true do |t|
      t.string   "name",       :null => false
      t.datetime "created_at", :null => false
      t.datetime "updated_at", :null => false
    end
  
    create_table "geo_relationship_types", :force => true do |t|
      t.string   "name",       :null => false
      t.datetime "created_at", :null => false
      t.datetime "updated_at", :null => false
    end
  
    create_table "geo_relationships", :force => true do |t|
      t.integer  "geo_entity_id",            :null => false
      t.integer  "other_geo_entity_id",      :null => false
      t.integer  "geo_relationship_type_id", :null => false
      t.datetime "created_at",               :null => false
      t.datetime "updated_at",               :null => false
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
  
    create_table "taxon_concept_geo_entities", :force => true do |t|
      t.integer  "taxon_concept_id", :null => false
      t.integer  "geo_entity_id",    :null => false
      t.datetime "created_at",       :null => false
      t.datetime "updated_at",       :null => false
    end
  
    create_table "taxon_concepts", :force => true do |t|
      t.integer  "parent_id"
      t.integer  "lft"
      t.integer  "rgt"
      t.integer  "rank_id",                                :null => false
      t.datetime "created_at",                             :null => false
      t.datetime "updated_at",                             :null => false
      t.integer  "spcrecid"
      t.integer  "depth"
      t.integer  "designation_id",                         :null => false
      t.integer  "taxon_name_id",                          :null => false
      t.integer  "legacy_id"
      t.boolean  "inherit_distribution", :default => true, :null => false
      t.boolean  "inherit_legislation",  :default => true, :null => false
      t.boolean  "inherit_references",   :default => true, :null => false
    end
  
    add_index "taxon_concepts", ["lft"], :name => "index_taxon_concepts_on_lft"
  
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
  
    add_foreign_key "geo_entities", "geo_entity_types", :name => "geo_entities_geo_entity_type_id_fk"
  
    add_foreign_key "geo_relationships", "geo_entities", :name => "geo_relationships_geo_entity_id_fk"
    add_foreign_key "geo_relationships", "geo_entities", :name => "geo_relationships_other_geo_entity_id_fk", :column => "other_geo_entity_id"
    add_foreign_key "geo_relationships", "geo_relationship_types", :name => "geo_relationships_geo_relationship_type_id_fk"
  
    add_foreign_key "ranks", "ranks", :name => "ranks_parent_id_fk", :column => "parent_id"
  
    add_foreign_key "taxon_concept_geo_entities", "geo_entities", :name => "taxon_concept_geo_entities_geo_entity_id_fk"
    add_foreign_key "taxon_concept_geo_entities", "taxon_concepts", :name => "taxon_concept_geo_entities_taxon_concept_id_fk"
  
    add_foreign_key "taxon_concepts", "designations", :name => "taxon_concepts_designation_id_fk"
    add_foreign_key "taxon_concepts", "ranks", :name => "taxon_concepts_rank_id_fk"
    add_foreign_key "taxon_concepts", "taxon_concepts", :name => "taxon_concepts_parent_id_fk", :column => "parent_id"
    add_foreign_key "taxon_concepts", "taxon_names", :name => "taxon_concepts_taxon_name_id_fk"
  
    add_foreign_key "taxon_names", "taxon_names", :name => "taxon_names_basionym_id_fk", :column => "basionym_id"
  
    add_foreign_key "taxon_relationships", "taxon_concepts", :name => "taxon_relationships_taxon_concept_id_fk"
    add_foreign_key "taxon_relationships", "taxon_relationship_types", :name => "taxon_relationships_taxon_relationship_type_id_fk"
  end
end
