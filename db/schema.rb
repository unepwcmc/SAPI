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

ActiveRecord::Schema.define(:version => 20130212181445) do

  create_table "annotation_translations", :force => true do |t|
    t.integer  "annotation_id", :null => false
    t.integer  "language_id",   :null => false
    t.string   "short_note"
    t.text     "full_note",     :null => false
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  create_table "annotations", :force => true do |t|
    t.string   "symbol"
    t.string   "parent_symbol"
    t.integer  "listing_change_id"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
    t.string   "short_note_en"
    t.text     "full_note_en"
    t.string   "short_note_fr"
    t.text     "full_note_fr"
    t.string   "short_note_es"
    t.text     "full_note_es"
    t.boolean  "display_in_index",    :default => false, :null => false
    t.boolean  "display_in_footnote", :default => false, :null => false
  end

  add_index "annotations", ["listing_change_id"], :name => "index_annotations_on_listing_change_id"

  create_table "change_types", :force => true do |t|
    t.string   "name"
    t.integer  "designation_id", :null => false
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  create_table "cites_listings_import", :id => false, :force => true do |t|
    t.string  "rank",                      :limit => nil
    t.integer "legacy_id"
    t.string  "appendix",                  :limit => nil
    t.date    "listing_date"
    t.string  "country_iso2",              :limit => nil
    t.boolean "is_current"
    t.string  "hash_note",                 :limit => nil
    t.string  "populations_iso2",          :limit => nil
    t.string  "excluded_populations_iso2", :limit => nil
    t.boolean "is_inclusion"
    t.integer "included_in_rec_id"
    t.string  "rank_for_inclusions",       :limit => nil
    t.string  "excluded_taxa",             :limit => nil
    t.string  "short_note_en",             :limit => nil
    t.string  "short_note_es",             :limit => nil
    t.string  "short_note_fr",             :limit => nil
    t.string  "full_note_en",              :limit => nil
  end

  create_table "cites_regions_import", :id => false, :force => true do |t|
    t.string "name", :limit => nil
  end

  create_table "common_name_import", :id => false, :force => true do |t|
    t.string  "name",         :limit => nil
    t.string  "language",     :limit => nil
    t.integer "legacy_id"
    t.string  "rank",         :limit => nil
    t.string  "designation",  :limit => nil
    t.string  "reference_id", :limit => nil
  end

  create_table "common_names", :force => true do |t|
    t.string   "name"
    t.integer  "language_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "countries_import", :id => false, :force => true do |t|
    t.integer "legacy_id"
    t.string  "iso2",         :limit => nil
    t.string  "name",         :limit => nil
    t.string  "long_name",    :limit => nil
    t.string  "geo_entity",   :limit => nil
    t.string  "current_name", :limit => nil
    t.string  "bru_under",    :limit => nil
    t.string  "cites_region", :limit => nil
  end

  create_table "designations", :force => true do |t|
    t.string   "name",                       :null => false
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
    t.integer  "taxonomy_id", :default => 2, :null => false
  end

  create_table "distribution_import", :id => false, :force => true do |t|
    t.string  "rank",              :limit => nil
    t.integer "legacy_id"
    t.integer "country_legacy_id"
    t.string  "country_iso2",      :limit => nil
    t.string  "country_name",      :limit => nil
    t.integer "reference_id"
    t.string  "tags",              :limit => nil
    t.string  "designation",       :limit => nil
  end

  create_table "distribution_references", :force => true do |t|
    t.integer "distribution_id"
    t.integer "reference_id"
  end

  create_table "distributions", :force => true do |t|
    t.integer  "taxon_concept_id", :null => false
    t.integer  "geo_entity_id",    :null => false
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  create_table "downloads", :force => true do |t|
    t.string   "doc_type"
    t.string   "format"
    t.string   "status",       :default => "working"
    t.datetime "created_at",                          :null => false
    t.datetime "updated_at",                          :null => false
    t.string   "path"
    t.string   "filename"
    t.string   "display_name"
  end

  create_table "geo_entities", :force => true do |t|
    t.integer  "geo_entity_type_id",                   :null => false
    t.string   "name_en",                              :null => false
    t.string   "long_name"
    t.string   "iso_code2"
    t.string   "iso_code3"
    t.integer  "legacy_id"
    t.string   "legacy_type"
    t.datetime "created_at",                           :null => false
    t.datetime "updated_at",                           :null => false
    t.boolean  "is_current",         :default => true
    t.string   "name_fr"
    t.string   "name_es"
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
    t.string   "name_en"
    t.string   "iso_code1"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.string   "name_fr"
    t.string   "name_es"
  end

  create_table "listing_changes", :force => true do |t|
    t.integer  "species_listing_id"
    t.integer  "taxon_concept_id"
    t.integer  "change_type_id"
    t.integer  "lft"
    t.integer  "rgt"
    t.integer  "parent_id"
    t.datetime "created_at",                                                    :null => false
    t.datetime "updated_at",                                                    :null => false
    t.datetime "effective_at",               :default => '2012-09-21 07:32:20', :null => false
    t.integer  "annotation_id"
    t.boolean  "is_current",                 :default => false,                 :null => false
    t.integer  "inclusion_taxon_concept_id"
    t.integer  "import_row_id"
    t.integer  "hash_annotation_id"
  end

  add_index "listing_changes", ["annotation_id"], :name => "index_listing_changes_on_annotation_id"
  add_index "listing_changes", ["parent_id"], :name => "index_listing_changes_on_parent_id"

  create_table "listing_changes_mview", :id => false, :force => true do |t|
    t.integer  "id"
    t.integer  "taxon_concept_id"
    t.datetime "effective_at"
    t.integer  "species_listing_id"
    t.string   "species_listing_name"
    t.integer  "change_type_id"
    t.string   "change_type_name"
    t.integer  "party_id"
    t.string   "party_name"
    t.text     "full_note_en"
    t.text     "full_note_es"
    t.text     "full_note_fr"
    t.string   "short_note_en"
    t.string   "short_note_es"
    t.string   "short_note_fr"
    t.boolean  "display_in_index"
    t.boolean  "display_in_footnote"
    t.string   "symbol"
    t.string   "parent_symbol"
    t.text     "hash_full_note_en"
    t.text     "hash_full_note_es"
    t.text     "hash_full_note_fr"
    t.boolean  "is_current"
    t.string   "countries_ids_ary",    :limit => nil
    t.boolean  "dirty"
    t.datetime "expiry"
  end

  add_index "listing_changes_mview", ["id"], :name => "listing_changes_mview_on_id", :unique => true
  add_index "listing_changes_mview", ["taxon_concept_id"], :name => "listing_changes_mview_on_taxon_concept_id"

  create_table "listing_distributions", :force => true do |t|
    t.integer  "listing_change_id",                   :null => false
    t.integer  "geo_entity_id",                       :null => false
    t.boolean  "is_party",          :default => true, :null => false
    t.datetime "created_at",                          :null => false
    t.datetime "updated_at",                          :null => false
  end

  add_index "listing_distributions", ["geo_entity_id"], :name => "index_listing_distributions_on_geo_entity_id"
  add_index "listing_distributions", ["listing_change_id"], :name => "index_listing_distributions_on_listing_change_id"

  create_table "ranks", :force => true do |t|
    t.string   "name",                                  :null => false
    t.datetime "created_at",                            :null => false
    t.datetime "updated_at",                            :null => false
    t.string   "taxonomic_position", :default => "0",   :null => false
    t.boolean  "fixed_order",        :default => false, :null => false
  end

  create_table "references", :force => true do |t|
    t.text     "title",       :null => false
    t.string   "year"
    t.string   "author"
    t.integer  "legacy_id"
    t.string   "legacy_type"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "species_import", :id => false, :force => true do |t|
    t.string  "name",             :limit => nil
    t.string  "rank",             :limit => nil
    t.integer "legacy_id"
    t.string  "parent_rank",      :limit => nil
    t.integer "parent_legacy_id"
    t.string  "status",           :limit => nil
    t.string  "author",           :limit => nil
    t.string  "notes",            :limit => nil
    t.string  "taxonomy",         :limit => nil
  end

  create_table "species_listings", :force => true do |t|
    t.integer  "designation_id"
    t.string   "name"
    t.string   "abbreviation"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
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
    t.string  "name",            :limit => nil
    t.string  "rank",            :limit => nil
    t.integer "taxon_legacy_id"
    t.integer "ref_legacy_id"
    t.string  "exclusions",      :limit => nil
    t.boolean "cascade"
    t.string  "designation",     :limit => nil
  end

  create_table "synonym_import", :id => false, :force => true do |t|
    t.string  "name",               :limit => nil
    t.string  "rank",               :limit => nil
    t.integer "legacy_id"
    t.string  "parent_rank",        :limit => nil
    t.integer "parent_legacy_id"
    t.string  "status",             :limit => nil
    t.string  "author",             :limit => nil
    t.string  "notes",              :limit => nil
    t.string  "reference_ids",      :limit => nil
    t.string  "taxonomy",           :limit => nil
    t.string  "accepted_rank",      :limit => nil
    t.integer "accepted_legacy_id"
  end

  create_table "taggings", :force => true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.integer  "tagger_id"
    t.string   "tagger_type"
    t.string   "context",       :limit => 128
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id"], :name => "index_taggings_on_tag_id"
  add_index "taggings", ["taggable_id", "taggable_type", "context"], :name => "index_taggings_on_taggable_id_and_taggable_type_and_context"

  create_table "tags", :force => true do |t|
    t.string "name"
  end

  create_table "taxon_commons", :force => true do |t|
    t.integer  "taxon_concept_id"
    t.integer  "common_name_id"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  create_table "taxon_concept_references", :force => true do |t|
    t.integer "taxon_concept_id", :null => false
    t.integer "reference_id",     :null => false
    t.hstore  "data"
  end

  create_table "taxon_concepts", :force => true do |t|
    t.integer  "parent_id"
    t.integer  "lft"
    t.integer  "rgt"
    t.integer  "rank_id",                             :null => false
    t.integer  "taxon_name_id",                       :null => false
    t.integer  "legacy_id"
    t.string   "legacy_type"
    t.hstore   "data"
    t.hstore   "listing"
    t.datetime "created_at",                          :null => false
    t.datetime "updated_at",                          :null => false
    t.string   "author_year"
    t.text     "notes"
    t.string   "taxonomic_position", :default => "0", :null => false
    t.string   "full_name"
    t.string   "name_status",        :default => "A", :null => false
    t.integer  "taxonomy_id",        :default => 2,   :null => false
  end

  add_index "taxon_concepts", ["lft"], :name => "index_taxon_concepts_on_lft"
  add_index "taxon_concepts", ["parent_id"], :name => "index_taxon_concepts_on_parent_id"

  create_table "taxon_concepts_mview", :id => false, :force => true do |t|
    t.integer  "id"
    t.integer  "parent_id"
    t.boolean  "taxonomy_is_cites_eu"
    t.string   "full_name"
    t.string   "name_status"
    t.text     "rank_name"
    t.boolean  "cites_accepted"
    t.integer  "kingdom_position"
    t.string   "taxonomic_position"
    t.text     "kingdom_name"
    t.text     "phylum_name"
    t.text     "class_name"
    t.text     "order_name"
    t.text     "family_name"
    t.text     "genus_name"
    t.text     "species_name"
    t.text     "subspecies_name"
    t.integer  "kingdom_id"
    t.integer  "phylum_id"
    t.integer  "class_id"
    t.integer  "order_id"
    t.integer  "family_id"
    t.integer  "genus_id"
    t.integer  "species_id"
    t.integer  "subspecies_id"
    t.boolean  "cites_fully_covered"
    t.boolean  "cites_listed"
    t.boolean  "cites_deleted"
    t.boolean  "cites_excluded"
    t.boolean  "cites_show"
    t.boolean  "cites_i"
    t.boolean  "cites_ii"
    t.boolean  "cites_iii"
    t.text     "current_listing"
    t.datetime "listing_updated_at"
    t.text     "ann_symbol"
    t.text     "hash_ann_symbol"
    t.text     "hash_ann_parent_symbol"
    t.string   "author_year"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "taxon_concept_id_com"
    t.string   "english_names_ary",           :limit => nil
    t.string   "french_names_ary",            :limit => nil
    t.string   "spanish_names_ary",           :limit => nil
    t.integer  "taxon_concept_id_syn"
    t.string   "synonyms_ary",                :limit => nil
    t.string   "synonyms_author_years_ary",   :limit => nil
    t.string   "countries_ids_ary",           :limit => nil
    t.string   "standard_references_ids_ary", :limit => nil
    t.boolean  "dirty"
    t.datetime "expiry"
  end

  add_index "taxon_concepts_mview", ["full_name"], :name => "taxon_concepts_mview_on_full_name"
  add_index "taxon_concepts_mview", ["id"], :name => "taxon_concepts_mview_on_id", :unique => true
  add_index "taxon_concepts_mview", ["parent_id"], :name => "taxon_concepts_mview_on_parent_id"
  add_index "taxon_concepts_mview", ["taxonomy_is_cites_eu", "cites_listed", "kingdom_position"], :name => "taxon_concepts_mview_on_history_filter"

  create_table "taxon_names", :force => true do |t|
    t.string   "scientific_name", :null => false
    t.integer  "basionym_id"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  create_table "taxon_relationship_types", :force => true do |t|
    t.string   "name",                                 :null => false
    t.datetime "created_at",                           :null => false
    t.datetime "updated_at",                           :null => false
    t.boolean  "is_intertaxonomic"
    t.boolean  "is_bidirectional",  :default => false
  end

  create_table "taxon_relationships", :force => true do |t|
    t.integer  "taxon_concept_id",           :null => false
    t.integer  "other_taxon_concept_id",     :null => false
    t.integer  "taxon_relationship_type_id", :null => false
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
  end

  create_table "taxonomies", :force => true do |t|
    t.string   "name",       :default => "DEAFAULT TAXONOMY", :null => false
    t.datetime "created_at",                                  :null => false
    t.datetime "updated_at",                                  :null => false
  end

  create_table "trade_codes", :force => true do |t|
    t.string   "code",       :null => false
    t.string   "name_en",    :null => false
    t.string   "type",       :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.string   "name_es"
    t.string   "name_fr"
  end

  create_table "users", :force => true do |t|
    t.string   "name",       :null => false
    t.string   "email",      :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_foreign_key "annotation_translations", "annotations", :name => "annotation_translations_annotation_id_fk"
  add_foreign_key "annotation_translations", "languages", :name => "annotation_translations_language_id_fk"

  add_foreign_key "annotations", "listing_changes", :name => "annotations_listing_changes_id_fk"

  add_foreign_key "change_types", "designations", :name => "change_types_designation_id_fk"

  add_foreign_key "common_names", "languages", :name => "common_names_language_id_fk"

  add_foreign_key "designations", "taxonomies", :name => "designations_taxonomy_id_fk"

  add_foreign_key "distribution_references", "distributions", :name => "taxon_concept_geo_entity_references_taxon_concept_geo_entity_fk"
  add_foreign_key "distribution_references", "references", :name => "taxon_concept_geo_entity_references_reference_id_fk"

  add_foreign_key "distributions", "geo_entities", :name => "taxon_concept_geo_entities_geo_entity_id_fk"
  add_foreign_key "distributions", "taxon_concepts", :name => "taxon_concept_geo_entities_taxon_concept_id_fk"

  add_foreign_key "geo_entities", "geo_entity_types", :name => "geo_entities_geo_entity_type_id_fk"

  add_foreign_key "geo_relationships", "geo_entities", :name => "geo_relationships_geo_entity_id_fk"
  add_foreign_key "geo_relationships", "geo_entities", :name => "geo_relationships_other_geo_entity_id_fk", :column => "other_geo_entity_id"
  add_foreign_key "geo_relationships", "geo_relationship_types", :name => "geo_relationships_geo_relationship_type_id_fk"

  add_foreign_key "listing_changes", "annotations", :name => "listing_changes_annotation_id_fk"
  add_foreign_key "listing_changes", "annotations", :name => "listing_changes_hash_annotation_id_fk"
  add_foreign_key "listing_changes", "change_types", :name => "listing_changes_change_type_id_fk"
  add_foreign_key "listing_changes", "listing_changes", :name => "listing_changes_parent_id_fk", :column => "parent_id"
  add_foreign_key "listing_changes", "species_listings", :name => "listing_changes_species_listing_id_fk"
  add_foreign_key "listing_changes", "taxon_concepts", :name => "listing_changes_inclusion_taxon_concept_id_fk"
  add_foreign_key "listing_changes", "taxon_concepts", :name => "listing_changes_taxon_concept_id_fk"

  add_foreign_key "listing_distributions", "geo_entities", :name => "listing_distributions_geo_entity_id_fk"
  add_foreign_key "listing_distributions", "listing_changes", :name => "listing_distributions_listing_change_id_fk"

  add_foreign_key "species_listings", "designations", :name => "species_listings_designation_id_fk"

  add_foreign_key "taxon_commons", "common_names", :name => "taxon_commons_common_name_id_fk"
  add_foreign_key "taxon_commons", "taxon_concepts", :name => "taxon_commons_taxon_concept_id_fk"

  add_foreign_key "taxon_concept_references", "references", :name => "taxon_concept_references_reference_id_fk"
  add_foreign_key "taxon_concept_references", "taxon_concepts", :name => "taxon_concept_references_taxon_concept_id_fk"

  add_foreign_key "taxon_concepts", "ranks", :name => "taxon_concepts_rank_id_fk"
  add_foreign_key "taxon_concepts", "taxon_concepts", :name => "taxon_concepts_parent_id_fk", :column => "parent_id"
  add_foreign_key "taxon_concepts", "taxon_names", :name => "taxon_concepts_taxon_name_id_fk"
  add_foreign_key "taxon_concepts", "taxonomies", :name => "taxon_concepts_taxonomy_id_fk"

  add_foreign_key "taxon_names", "taxon_names", :name => "taxon_names_basionym_id_fk", :column => "basionym_id"

  add_foreign_key "taxon_relationships", "taxon_concepts", :name => "taxon_relationships_taxon_concept_id_fk"
  add_foreign_key "taxon_relationships", "taxon_relationship_types", :name => "taxon_relationships_taxon_relationship_type_id_fk"

end
