# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120517081442) do

  create_table "authors", :force => true do |t|
    t.string   "first_name"
    t.string   "middle_name"
    t.string   "last_name",   :null => false
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "bru_distribution_components", :force => true do |t|
    t.integer  "distribution_id", :null => false
    t.integer  "component_id",    :null => false
    t.string   "component_type",  :null => false
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  create_table "brus", :force => true do |t|
    t.string   "code",       :null => false
    t.integer  "level",      :null => false
    t.string   "name"
    t.integer  "parent_id"
    t.integer  "country_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "countries", :force => true do |t|
    t.string   "iso_name",   :null => false
    t.string   "iso2_code"
    t.string   "iso3_code"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "region_id"
  end

  create_table "country_distribution_components", :force => true do |t|
    t.integer  "distribution_id", :null => false
    t.integer  "component_id",    :null => false
    t.string   "component_type",  :null => false
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  create_table "designations", :force => true do |t|
    t.string   "name",       :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "distribution_components", :force => true do |t|
    t.integer  "distribution_id", :null => false
    t.integer  "component_id",    :null => false
    t.string   "component_type",  :null => false
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  create_table "distributions", :force => true do |t|
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
    t.integer  "taxon_concept_id", :null => false
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

  create_table "region_distribution_components", :force => true do |t|
    t.integer  "distribution_id", :null => false
    t.integer  "component_id",    :null => false
    t.string   "component_type",  :null => false
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  create_table "regions", :force => true do |t|
    t.string   "name",       :null => false
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

  add_foreign_key "bru_distribution_components", "brus", :name => "bru_distribution_components_component_id_fkey", :column => "component_id"

  add_foreign_key "brus", "brus", :name => "brus_parent_id_fk", :column => "parent_id"
  add_foreign_key "brus", "countries", :name => "brus_country_id_fk"

  add_foreign_key "countries", "regions", :name => "countries_regions_id_fk"

  add_foreign_key "country_distribution_components", "countries", :name => "country_distribution_components_component_id_fkey", :column => "component_id"

  add_foreign_key "distribution_components", "distributions", :name => "distribution_components_distribution_id_fk"

  add_foreign_key "distributions", "taxon_concepts", :name => "distributions_taxon_concept_id_fk"

  add_foreign_key "ranks", "ranks", :name => "ranks_parent_id_fk", :column => "parent_id"

  add_foreign_key "region_distribution_components", "regions", :name => "region_distribution_components_component_id_fkey", :column => "component_id"

  add_foreign_key "taxon_concepts", "designations", :name => "taxon_concepts_designation_id_fk"
  add_foreign_key "taxon_concepts", "ranks", :name => "taxon_concepts_rank_id_fk"
  add_foreign_key "taxon_concepts", "taxon_concepts", :name => "taxon_concepts_parent_id_fk", :column => "parent_id"
  add_foreign_key "taxon_concepts", "taxon_names", :name => "taxon_concepts_taxon_name_id_fk"

  add_foreign_key "taxon_names", "taxon_names", :name => "taxon_names_basionym_id_fk", :column => "basionym_id"

  add_foreign_key "taxon_relationships", "taxon_concepts", :name => "taxon_relationships_taxon_concept_id_fk"
  add_foreign_key "taxon_relationships", "taxon_relationship_types", :name => "taxon_relationships_taxon_relationship_type_id_fk"

end
