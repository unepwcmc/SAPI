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

ActiveRecord::Schema.define(:version => 20120810145423) do

  create_table "animals_import", :id => false, :force => true do |t|
    t.string  "kingdom",    :limit => nil
    t.string  "phylum",     :limit => nil
    t.string  "class",      :limit => nil
    t.string  "taxonorder", :limit => nil
    t.string  "family",     :limit => nil
    t.string  "genus",      :limit => nil
    t.string  "species",    :limit => nil
    t.string  "spcinfra",   :limit => nil
    t.integer "spcrecid"
    t.string  "spcstatus",  :limit => nil
  end

  create_table "animals_synonym_import", :id => false, :force => true do |t|
    t.string  "kingdom",             :limit => nil
    t.string  "phylum",              :limit => nil
    t.string  "class",               :limit => nil
    t.string  "taxonorder",          :limit => nil
    t.string  "family",              :limit => nil
    t.string  "genus",               :limit => nil
    t.string  "species",             :limit => nil
    t.string  "spcinfra",            :limit => nil
    t.integer "spcrecid"
    t.string  "spcstatus",           :limit => nil
    t.integer "accepted_species_id"
  end

  create_table "change_types", :force => true do |t|
    t.string   "name"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
    t.integer  "designation_id", :null => false
  end

  create_table "cites_listings_import", :id => false, :force => true do |t|
    t.integer "spc_rec_id"
    t.string  "appendix",          :limit => nil
    t.date    "listing_date"
    t.string  "country_legacy_id", :limit => nil
    t.string  "notes",             :limit => nil
  end

  create_table "cites_regions_import", :id => false, :force => true do |t|
    t.string "name", :limit => nil
  end

  create_table "common_name_import", :id => false, :force => true do |t|
    t.string  "common_name",   :limit => nil
    t.string  "language_name", :limit => nil
    t.integer "species_id"
  end

  create_table "common_names", :force => true do |t|
    t.string   "name"
    t.integer  "reference_id"
    t.integer  "language_id"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  create_table "countries_import", :id => false, :force => true do |t|
    t.integer "legacy_id"
    t.string  "iso2",          :limit => nil
    t.string  "iso3",          :limit => nil
    t.string  "name",          :limit => nil
    t.string  "long_name",     :limit => nil
    t.string  "region_number", :limit => nil
  end

  create_table "designations", :force => true do |t|
    t.string   "name",       :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "distribution_import", :id => false, :force => true do |t|
    t.integer "species_id"
    t.integer "country_id"
    t.string  "country_name", :limit => nil
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

  create_table "languages", :force => true do |t|
    t.string   "name"
    t.string   "abbreviation"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  create_table "listing_changes", :force => true do |t|
    t.integer  "species_listing_id"
    t.integer  "taxon_concept_id"
    t.integer  "change_type_id"
    t.integer  "reference_id"
    t.integer  "lft"
    t.integer  "rgt"
    t.integer  "parent_id"
    t.integer  "depth"
    t.datetime "created_at",                                            :null => false
    t.datetime "updated_at",                                            :null => false
    t.datetime "effective_at",       :default => '2012-08-08 07:40:24', :null => false
    t.text     "notes"
  end

  create_table "listing_distributions", :force => true do |t|
    t.integer  "listing_change_id",                   :null => false
    t.integer  "geo_entity_id",                       :null => false
    t.datetime "created_at",                          :null => false
    t.datetime "updated_at",                          :null => false
    t.boolean  "is_party",          :default => true, :null => false
  end

  create_table "plants_import", :id => false, :force => true do |t|
    t.string  "kingdom",    :limit => nil
    t.string  "taxonorder", :limit => nil
    t.string  "family",     :limit => nil
    t.string  "genus",      :limit => nil
    t.string  "species",    :limit => nil
    t.string  "spcinfra",   :limit => nil
    t.integer "spcrecid"
    t.string  "spcstatus",  :limit => nil
  end

  create_table "plants_synonym_import", :id => false, :force => true do |t|
    t.string  "kingdom",             :limit => nil
    t.string  "taxonorder",          :limit => nil
    t.string  "family",              :limit => nil
    t.string  "genus",               :limit => nil
    t.string  "species",             :limit => nil
    t.string  "spcinfra",            :limit => nil
    t.integer "spcrecid"
    t.string  "spcstatus",           :limit => nil
    t.integer "accepted_species_id"
  end

  create_table "ranks", :force => true do |t|
    t.string   "name",       :null => false
    t.integer  "parent_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "reference_links", :id => false, :force => true do |t|
    t.integer "dslspcrecid"
    t.integer "dsldscrecid"
    t.string  "dslcode",      :limit => nil
    t.integer "dslcoderecid"
  end

  create_table "reference_links_import", :id => false, :force => true do |t|
    t.integer "dslspcrecid"
    t.integer "dsldscrecid"
    t.string  "dslcode",      :limit => nil
    t.integer "dslcoderecid"
  end

  create_table "references", :force => true do |t|
    t.text     "title",       :null => false
    t.string   "year"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.string   "author"
    t.integer  "legacy_id"
    t.string   "legacy_type"
  end

  create_table "references_import", :id => false, :force => true do |t|
    t.integer "dscrecid"
    t.string  "dsctitle",   :limit => nil
    t.string  "dscauthors", :limit => nil
    t.string  "dscpubyear", :limit => nil
  end

  create_table "species_import", :id => false, :force => true do |t|
    t.string  "kingdom",    :limit => nil
    t.string  "taxonorder", :limit => nil
    t.string  "family",     :limit => nil
    t.string  "genus",      :limit => nil
    t.string  "species",    :limit => nil
    t.string  "spcinfra",   :limit => nil
    t.integer "spcrecid"
    t.string  "spcstatus",  :limit => nil
  end

  create_table "species_listings", :force => true do |t|
    t.integer  "designation_id"
    t.string   "name"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
    t.string   "abbreviation"
  end

  create_table "standard_references", :force => true do |t|
    t.string   "author"
    t.text     "title"
    t.integer  "year"
    t.integer  "reference_id"
    t.integer  "reference_legacy_id"
    t.string   "taxon_concept_name"
    t.string   "taxon_concept_rank"
    t.integer  "taxon_concept_id"
    t.integer  "species_legacy_id"
    t.integer  "position"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
  end

  create_table "standard_references_import", :id => false, :force => true do |t|
    t.string  "author",     :limit => nil
    t.integer "year"
    t.text    "title"
    t.string  "kingdom",    :limit => nil
    t.string  "phylum",     :limit => nil
    t.string  "class",      :limit => nil
    t.string  "taxonorder", :limit => nil
    t.string  "family",     :limit => nil
    t.string  "genus",      :limit => nil
    t.string  "species",    :limit => nil
  end

  create_table "synonym_import", :id => false, :force => true do |t|
    t.string  "kingdom",             :limit => nil
    t.string  "taxonorder",          :limit => nil
    t.string  "family",              :limit => nil
    t.string  "genus",               :limit => nil
    t.string  "species",             :limit => nil
    t.string  "spcinfra",            :limit => nil
    t.integer "spcrecid"
    t.string  "spcstatus",           :limit => nil
    t.integer "accepted_species_id"
  end

  create_table "taxon_commons", :force => true do |t|
    t.integer  "taxon_concept_id"
    t.integer  "common_name_id"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  create_table "taxon_concept_geo_entities", :force => true do |t|
    t.integer  "taxon_concept_id", :null => false
    t.integer  "geo_entity_id",    :null => false
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  create_table "taxon_concept_geo_entity_references", :force => true do |t|
    t.integer "taxon_concept_geo_entity_id"
    t.integer "reference_id"
  end

  create_table "taxon_concept_references", :force => true do |t|
    t.integer "taxon_concept_id",                    :null => false
    t.integer "reference_id",                        :null => false
    t.boolean "is_author",        :default => false, :null => false
    t.hstore  "data",                                :null => false
  end

  create_table "taxon_concepts", :force => true do |t|
    t.integer  "parent_id"
    t.integer  "lft"
    t.integer  "rgt"
    t.integer  "rank_id",                                :null => false
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
    t.integer  "depth"
    t.integer  "designation_id",                         :null => false
    t.integer  "taxon_name_id",                          :null => false
    t.integer  "legacy_id"
    t.boolean  "inherit_distribution", :default => true, :null => false
    t.hstore   "data"
    t.boolean  "fully_covered",        :default => true, :null => false
    t.hstore   "listing"
  end

  add_index "taxon_concepts", ["data"], :name => "index_taxon_concepts_on_data"
  add_index "taxon_concepts", ["lft"], :name => "index_taxon_concepts_on_lft"

  create_table "taxon_names", :force => true do |t|
    t.string   "scientific_name", :null => false
    t.integer  "basionym_id"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
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

  add_foreign_key "change_types", "designations", :name => "change_types_designation_id_fk"

  add_foreign_key "common_names", "languages", :name => "common_names_language_id_fk"

  add_foreign_key "geo_entities", "geo_entity_types", :name => "geo_entities_geo_entity_type_id_fk"

  add_foreign_key "geo_relationships", "geo_entities", :name => "geo_relationships_geo_entity_id_fk"
  add_foreign_key "geo_relationships", "geo_entities", :name => "geo_relationships_other_geo_entity_id_fk", :column => "other_geo_entity_id"
  add_foreign_key "geo_relationships", "geo_relationship_types", :name => "geo_relationships_geo_relationship_type_id_fk"

  add_foreign_key "listing_changes", "change_types", :name => "listing_changes_change_type_id_fk"
  add_foreign_key "listing_changes", "listing_changes", :name => "listing_changes_parent_id_fk", :column => "parent_id"
  add_foreign_key "listing_changes", "references", :name => "listing_changes_reference_id_fk"
  add_foreign_key "listing_changes", "species_listings", :name => "listing_changes_species_listing_id_fk"
  add_foreign_key "listing_changes", "taxon_concepts", :name => "listing_changes_taxon_concept_id_fk"

  add_foreign_key "listing_distributions", "geo_entities", :name => "listing_distributions_geo_entity_id_fk"
  add_foreign_key "listing_distributions", "listing_changes", :name => "listing_distributions_listing_change_id_fk"

  add_foreign_key "ranks", "ranks", :name => "ranks_parent_id_fk", :column => "parent_id"

  add_foreign_key "species_listings", "designations", :name => "species_listings_designation_id_fk"

  add_foreign_key "taxon_commons", "common_names", :name => "taxon_commons_common_name_id_fk"
  add_foreign_key "taxon_commons", "taxon_concepts", :name => "taxon_commons_taxon_concept_id_fk"

  add_foreign_key "taxon_concept_geo_entities", "geo_entities", :name => "taxon_concept_geo_entities_geo_entity_id_fk"
  add_foreign_key "taxon_concept_geo_entities", "taxon_concepts", :name => "taxon_concept_geo_entities_taxon_concept_id_fk"

  add_foreign_key "taxon_concept_geo_entity_references", "references", :name => "taxon_concept_geo_entity_references_reference_id_fk"
  add_foreign_key "taxon_concept_geo_entity_references", "taxon_concept_geo_entities", :name => "taxon_concept_geo_entity_references_taxon_concept_geo_entity_fk"

  add_foreign_key "taxon_concept_references", "references", :name => "taxon_concept_references_reference_id_fk"
  add_foreign_key "taxon_concept_references", "taxon_concepts", :name => "taxon_concept_references_taxon_concept_id_fk"

  add_foreign_key "taxon_concepts", "designations", :name => "taxon_concepts_designation_id_fk"
  add_foreign_key "taxon_concepts", "ranks", :name => "taxon_concepts_rank_id_fk"
  add_foreign_key "taxon_concepts", "taxon_concepts", :name => "taxon_concepts_parent_id_fk", :column => "parent_id"
  add_foreign_key "taxon_concepts", "taxon_names", :name => "taxon_concepts_taxon_name_id_fk"

  add_foreign_key "taxon_names", "taxon_names", :name => "taxon_names_basionym_id_fk", :column => "basionym_id"

  add_foreign_key "taxon_relationships", "taxon_concepts", :name => "taxon_relationships_taxon_concept_id_fk"
  add_foreign_key "taxon_relationships", "taxon_relationship_types", :name => "taxon_relationships_taxon_relationship_type_id_fk"

end
