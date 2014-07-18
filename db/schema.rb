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

ActiveRecord::Schema.define(:version => 20140710095812) do

# Could not dump table "ahoy_events" because of following StandardError
#   Unknown type 'json' for column 'properties'

  create_table "ahoy_visits", :id => false, :force => true do |t|
    t.uuid     "id",               :null => false
    t.uuid     "visitor_id"
    t.string   "ip"
    t.text     "user_agent"
    t.text     "referrer"
    t.text     "landing_page"
    t.integer  "user_id"
    t.string   "referring_domain"
    t.string   "search_keyword"
    t.string   "browser"
    t.string   "os"
    t.string   "device_type"
    t.string   "country"
    t.string   "region"
    t.string   "city"
    t.string   "utm_source"
    t.string   "utm_medium"
    t.string   "utm_term"
    t.string   "utm_content"
    t.string   "utm_campaign"
    t.datetime "started_at"
  end

  add_index "ahoy_visits", ["user_id"], :name => "index_ahoy_visits_on_user_id"

  create_table "annotations", :force => true do |t|
    t.string   "symbol"
    t.string   "parent_symbol"
    t.boolean  "display_in_index",    :default => false, :null => false
    t.boolean  "display_in_footnote", :default => false, :null => false
    t.text     "short_note_en"
    t.text     "full_note_en"
    t.text     "short_note_fr"
    t.text     "full_note_fr"
    t.text     "short_note_es"
    t.text     "full_note_es"
    t.integer  "original_id"
    t.integer  "event_id"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
    t.integer  "import_row_id"
    t.integer  "created_by_id"
    t.integer  "updated_by_id"
  end

  create_table "auto_complete_taxon_concepts_mview", :id => false, :force => true do |t|
    t.integer "id"
    t.boolean "taxonomy_is_cites_eu"
    t.string  "name_status"
    t.string  "rank_name"
    t.string  "rank_order"
    t.string  "taxonomic_position"
    t.boolean "show_in_species_plus_ac"
    t.boolean "show_in_checklist_ac"
    t.boolean "show_in_trade_ac"
    t.text    "name_for_matching"
    t.integer "matched_id"
    t.string  "matched_name",            :limit => nil
    t.string  "full_name"
  end

  add_index "auto_complete_taxon_concepts_mview", ["name_for_matching", "taxonomy_is_cites_eu", "rank_name", "show_in_checklist_ac"], :name => "auto_complete_taxon_concepts__name_for_matching_taxonomy_i_idx1"
  add_index "auto_complete_taxon_concepts_mview", ["name_for_matching", "taxonomy_is_cites_eu", "rank_name", "show_in_species_plus_ac"], :name => "auto_complete_taxon_concepts__name_for_matching_taxonomy_is_idx"
  add_index "auto_complete_taxon_concepts_mview", ["name_for_matching", "taxonomy_is_cites_eu", "rank_name", "show_in_trade_ac"], :name => "auto_complete_taxon_concepts__name_for_matching_taxonomy_i_idx2"

  create_table "change_types", :force => true do |t|
    t.string   "name",           :null => false
    t.integer  "designation_id", :null => false
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  create_table "cites_listing_changes_mview", :id => false, :force => true do |t|
    t.integer  "taxon_concept_id"
    t.integer  "id"
    t.integer  "original_taxon_concept_id"
    t.datetime "effective_at"
    t.integer  "species_listing_id"
    t.string   "species_listing_name"
    t.integer  "change_type_id"
    t.string   "change_type_name"
    t.integer  "designation_id"
    t.string   "designation_name"
    t.integer  "parent_id"
    t.integer  "party_id"
    t.string   "party_iso_code"
    t.string   "ann_symbol"
    t.text     "full_note_en"
    t.text     "full_note_es"
    t.text     "full_note_fr"
    t.text     "short_note_en"
    t.text     "short_note_es"
    t.text     "short_note_fr"
    t.boolean  "display_in_index"
    t.boolean  "display_in_footnote"
    t.string   "hash_ann_symbol"
    t.string   "hash_ann_parent_symbol"
    t.text     "hash_full_note_en"
    t.text     "hash_full_note_es"
    t.text     "hash_full_note_fr"
    t.integer  "inclusion_taxon_concept_id"
    t.text     "inherited_short_note_en"
    t.text     "inherited_full_note_en"
    t.text     "auto_note"
    t.boolean  "is_current"
    t.boolean  "explicit_change"
    t.datetime "updated_at"
    t.boolean  "show_in_history"
    t.boolean  "show_in_downloads"
    t.boolean  "show_in_timeline"
    t.string   "listed_geo_entities_ids",    :limit => nil
    t.string   "excluded_geo_entities_ids",  :limit => nil
    t.string   "excluded_taxon_concept_ids", :limit => nil
    t.boolean  "dirty"
    t.datetime "expiry"
  end

  add_index "cites_listing_changes_mview", ["excluded_geo_entities_ids"], :name => "tmp_cascaded_cites_listing_chang_excluded_geo_entities_ids_idx1"
  add_index "cites_listing_changes_mview", ["id", "taxon_concept_id"], :name => "tmp_cascaded_cites_listing_changes_mvi_id_taxon_concept_id_idx1"
  add_index "cites_listing_changes_mview", ["inclusion_taxon_concept_id"], :name => "tmp_cascaded_cites_listing_chan_inclusion_taxon_concept_id_idx1"
  add_index "cites_listing_changes_mview", ["is_current", "change_type_name"], :name => "tmp_cascaded_cites_listing_cha_is_current_change_type_name_idx1"
  add_index "cites_listing_changes_mview", ["listed_geo_entities_ids"], :name => "tmp_cascaded_cites_listing_changes_listed_geo_entities_ids_idx1"
  add_index "cites_listing_changes_mview", ["original_taxon_concept_id"], :name => "tmp_cascaded_cites_listing_chang_original_taxon_concept_id_idx1"
  add_index "cites_listing_changes_mview", ["show_in_downloads", "taxon_concept_id"], :name => "tmp_cascaded_cites_listing_ch_show_in_downloads_taxon_conc_idx1"
  add_index "cites_listing_changes_mview", ["show_in_timeline", "taxon_concept_id"], :name => "tmp_cascaded_cites_listing_ch_show_in_timeline_taxon_conce_idx1"
  add_index "cites_listing_changes_mview", ["taxon_concept_id", "original_taxon_concept_id", "change_type_id", "effective_at"], :name => "tmp_cascaded_cites_listing_ch_taxon_concept_id_original_ta_idx1"

  create_table "cites_species_listing_mview", :id => false, :force => true do |t|
    t.integer "id"
    t.string  "taxonomic_position"
    t.integer "kingdom_id"
    t.integer "phylum_id"
    t.integer "class_id"
    t.integer "order_id"
    t.integer "family_id"
    t.integer "genus_id"
    t.text    "kingdom_name"
    t.text    "phylum_name"
    t.text    "class_name"
    t.text    "order_name"
    t.text    "family_name"
    t.text    "genus_name"
    t.text    "species_name"
    t.text    "subspecies_name"
    t.string  "full_name"
    t.string  "author_year"
    t.text    "rank_name"
    t.boolean "cites_listed"
    t.boolean "cites_nc"
    t.text    "cites_listing_original"
    t.text    "original_taxon_concept_party_iso_code"
    t.text    "original_taxon_concept_full_name_with_spp"
    t.text    "original_taxon_concept_full_note_en"
    t.text    "original_taxon_concept_hash_full_note_en"
    t.string  "countries_ids_ary",                         :limit => nil
    t.text    "all_distribution"
    t.text    "all_distribution_iso_codes"
    t.text    "native_distribution"
    t.text    "introduced_distribution"
    t.text    "introduced_uncertain_distribution"
    t.text    "reintroduced_distribution"
    t.text    "extinct_distribution"
    t.text    "extinct_uncertain_distribution"
    t.text    "uncertain_distribution"
  end

  add_index "cites_species_listing_mview", ["countries_ids_ary"], :name => "cites_species_listing_mview_tmp_countries_ids_ary_idx1"

  create_table "cites_suspension_confirmations", :force => true do |t|
    t.integer  "cites_suspension_id",              :null => false
    t.integer  "cites_suspension_notification_id", :null => false
    t.datetime "created_at",                       :null => false
    t.datetime "updated_at",                       :null => false
  end

  create_table "cms_listing_changes_mview", :id => false, :force => true do |t|
    t.integer  "taxon_concept_id"
    t.integer  "id"
    t.integer  "original_taxon_concept_id"
    t.datetime "effective_at"
    t.integer  "species_listing_id"
    t.string   "species_listing_name"
    t.integer  "change_type_id"
    t.string   "change_type_name"
    t.integer  "designation_id"
    t.string   "designation_name"
    t.integer  "parent_id"
    t.integer  "party_id"
    t.string   "party_iso_code"
    t.string   "ann_symbol"
    t.text     "full_note_en"
    t.text     "full_note_es"
    t.text     "full_note_fr"
    t.text     "short_note_en"
    t.text     "short_note_es"
    t.text     "short_note_fr"
    t.boolean  "display_in_index"
    t.boolean  "display_in_footnote"
    t.string   "hash_ann_symbol"
    t.string   "hash_ann_parent_symbol"
    t.text     "hash_full_note_en"
    t.text     "hash_full_note_es"
    t.text     "hash_full_note_fr"
    t.integer  "inclusion_taxon_concept_id"
    t.text     "inherited_short_note_en"
    t.text     "inherited_full_note_en"
    t.text     "auto_note"
    t.boolean  "is_current"
    t.boolean  "explicit_change"
    t.datetime "updated_at"
    t.boolean  "show_in_history"
    t.boolean  "show_in_downloads"
    t.boolean  "show_in_timeline"
    t.string   "listed_geo_entities_ids",    :limit => nil
    t.string   "excluded_geo_entities_ids",  :limit => nil
    t.string   "excluded_taxon_concept_ids", :limit => nil
    t.boolean  "dirty"
    t.datetime "expiry"
  end

  add_index "cms_listing_changes_mview", ["excluded_geo_entities_ids"], :name => "tmp_cascaded_cms_listing_changes_excluded_geo_entities_ids_idx1"
  add_index "cms_listing_changes_mview", ["id", "taxon_concept_id"], :name => "tmp_cascaded_cms_listing_changes_mview_id_taxon_concept_id_idx1"
  add_index "cms_listing_changes_mview", ["inclusion_taxon_concept_id"], :name => "tmp_cascaded_cms_listing_change_inclusion_taxon_concept_id_idx1"
  add_index "cms_listing_changes_mview", ["is_current", "change_type_name"], :name => "tmp_cascaded_cms_listing_chang_is_current_change_type_name_idx1"
  add_index "cms_listing_changes_mview", ["listed_geo_entities_ids"], :name => "tmp_cascaded_cms_listing_changes_m_listed_geo_entities_ids_idx1"
  add_index "cms_listing_changes_mview", ["original_taxon_concept_id"], :name => "tmp_cascaded_cms_listing_changes_original_taxon_concept_id_idx1"
  add_index "cms_listing_changes_mview", ["show_in_downloads", "taxon_concept_id"], :name => "tmp_cascaded_cms_listing_chan_show_in_downloads_taxon_conc_idx1"
  add_index "cms_listing_changes_mview", ["show_in_timeline", "taxon_concept_id"], :name => "tmp_cascaded_cms_listing_chan_show_in_timeline_taxon_conce_idx1"
  add_index "cms_listing_changes_mview", ["taxon_concept_id", "original_taxon_concept_id", "change_type_id", "effective_at"], :name => "tmp_cascaded_cms_listing_chan_taxon_concept_id_original_ta_idx1"

  create_table "cms_mappings", :force => true do |t|
    t.integer  "taxon_concept_id"
    t.string   "cms_uuid"
    t.string   "cms_taxon_name"
    t.string   "cms_author"
    t.hstore   "details"
    t.integer  "accepted_name_id"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  create_table "cms_species_listing_mview", :id => false, :force => true do |t|
    t.integer "id"
    t.string  "taxonomic_position"
    t.integer "kingdom_id"
    t.integer "phylum_id"
    t.integer "class_id"
    t.integer "order_id"
    t.integer "family_id"
    t.integer "genus_id"
    t.text    "phylum_name"
    t.text    "class_name"
    t.text    "order_name"
    t.text    "family_name"
    t.text    "genus_name"
    t.string  "full_name"
    t.string  "author_year"
    t.text    "rank_name"
    t.string  "agreement",                                 :limit => nil
    t.boolean "cms_listed"
    t.text    "cms_listing_original"
    t.text    "original_taxon_concept_full_name_with_spp"
    t.text    "original_taxon_concept_effective_at"
    t.text    "original_taxon_concept_full_note_en"
    t.string  "countries_ids_ary",                         :limit => nil
    t.text    "all_distribution"
    t.text    "all_distribution_iso_codes"
    t.text    "native_distribution"
    t.text    "introduced_distribution"
    t.text    "introduced_uncertain_distribution"
    t.text    "reintroduced_distribution"
    t.text    "extinct_distribution"
    t.text    "extinct_uncertain_distribution"
    t.text    "uncertain_distribution"
  end

  add_index "cms_species_listing_mview", ["countries_ids_ary"], :name => "cms_species_listing_mview_tmp_countries_ids_ary_idx1"

  create_table "common_names", :force => true do |t|
    t.string   "name",          :null => false
    t.integer  "language_id",   :null => false
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.integer  "created_by_id"
    t.integer  "updated_by_id"
  end

  create_table "designation_geo_entities", :force => true do |t|
    t.integer  "designation_id", :null => false
    t.integer  "geo_entity_id",  :null => false
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  create_table "designations", :force => true do |t|
    t.string   "name",                       :null => false
    t.integer  "taxonomy_id", :default => 1, :null => false
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
  end

  create_table "distribution_references", :force => true do |t|
    t.integer  "distribution_id", :null => false
    t.integer  "reference_id",    :null => false
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.integer  "updated_by_id"
    t.integer  "created_by_id"
  end

  add_index "distribution_references", ["distribution_id", "reference_id"], :name => "index_distribution_refs_on_distribution_id_reference_id", :unique => true
  add_index "distribution_references", ["distribution_id"], :name => "index_distribution_references_on_distribution_id"
  add_index "distribution_references", ["reference_id"], :name => "index_distribution_references_on_reference_id"

  create_table "distributions", :force => true do |t|
    t.integer  "taxon_concept_id", :null => false
    t.integer  "geo_entity_id",    :null => false
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
    t.integer  "created_by_id"
    t.integer  "updated_by_id"
  end

  add_index "distributions", ["taxon_concept_id"], :name => "index_distributions_on_taxon_concept_id"

  create_table "downloads", :force => true do |t|
    t.string   "doc_type"
    t.string   "format"
    t.string   "status",       :default => "working"
    t.string   "path"
    t.string   "filename"
    t.string   "display_name"
    t.datetime "created_at",                          :null => false
    t.datetime "updated_at",                          :null => false
  end

  create_table "eu_41_55_listing_changes_mview", :id => false, :force => true do |t|
    t.integer  "taxon_concept_id"
    t.integer  "id"
    t.integer  "original_taxon_concept_id"
    t.datetime "effective_at"
    t.integer  "species_listing_id"
    t.string   "species_listing_name"
    t.integer  "change_type_id"
    t.string   "change_type_name"
    t.integer  "designation_id"
    t.string   "designation_name"
    t.integer  "parent_id"
    t.integer  "party_id"
    t.string   "party_iso_code"
    t.string   "ann_symbol"
    t.text     "full_note_en"
    t.text     "full_note_es"
    t.text     "full_note_fr"
    t.text     "short_note_en"
    t.text     "short_note_es"
    t.text     "short_note_fr"
    t.boolean  "display_in_index"
    t.boolean  "display_in_footnote"
    t.string   "hash_ann_symbol"
    t.string   "hash_ann_parent_symbol"
    t.text     "hash_full_note_en"
    t.text     "hash_full_note_es"
    t.text     "hash_full_note_fr"
    t.integer  "inclusion_taxon_concept_id"
    t.text     "inherited_short_note_en"
    t.text     "inherited_full_note_en"
    t.text     "auto_note"
    t.boolean  "is_current"
    t.boolean  "explicit_change"
    t.datetime "updated_at"
    t.boolean  "show_in_history"
    t.boolean  "show_in_downloads"
    t.boolean  "show_in_timeline"
    t.string   "listed_geo_entities_ids",    :limit => nil
    t.string   "excluded_geo_entities_ids",  :limit => nil
    t.string   "excluded_taxon_concept_ids", :limit => nil
    t.boolean  "dirty"
    t.datetime "expiry"
  end

  add_index "eu_41_55_listing_changes_mview", ["excluded_geo_entities_ids"], :name => "tmp_cascaded_eu_41_55_listing_cha_excluded_geo_entities_ids_idx"
  add_index "eu_41_55_listing_changes_mview", ["id", "taxon_concept_id"], :name => "tmp_cascaded_eu_41_55_listing_changes_m_id_taxon_concept_id_idx"
  add_index "eu_41_55_listing_changes_mview", ["inclusion_taxon_concept_id"], :name => "tmp_cascaded_eu_41_55_listing_ch_inclusion_taxon_concept_id_idx"
  add_index "eu_41_55_listing_changes_mview", ["is_current", "change_type_name"], :name => "tmp_cascaded_eu_41_55_listing_c_is_current_change_type_name_idx"
  add_index "eu_41_55_listing_changes_mview", ["listed_geo_entities_ids"], :name => "tmp_cascaded_eu_41_55_listing_chang_listed_geo_entities_ids_idx"
  add_index "eu_41_55_listing_changes_mview", ["original_taxon_concept_id"], :name => "tmp_cascaded_eu_41_55_listing_cha_original_taxon_concept_id_idx"
  add_index "eu_41_55_listing_changes_mview", ["show_in_downloads", "taxon_concept_id"], :name => "tmp_cascaded_eu_41_55_listing_show_in_downloads_taxon_conce_idx"
  add_index "eu_41_55_listing_changes_mview", ["show_in_timeline", "taxon_concept_id"], :name => "tmp_cascaded_eu_41_55_listing_show_in_timeline_taxon_concep_idx"
  add_index "eu_41_55_listing_changes_mview", ["taxon_concept_id", "original_taxon_concept_id", "change_type_id", "effective_at"], :name => "tmp_cascaded_eu_41_55_listing_taxon_concept_id_original_tax_idx"

  create_table "eu_42_listing_changes_mview", :id => false, :force => true do |t|
    t.integer  "taxon_concept_id"
    t.integer  "id"
    t.integer  "original_taxon_concept_id"
    t.datetime "effective_at"
    t.integer  "species_listing_id"
    t.string   "species_listing_name"
    t.integer  "change_type_id"
    t.string   "change_type_name"
    t.integer  "designation_id"
    t.string   "designation_name"
    t.integer  "parent_id"
    t.integer  "party_id"
    t.string   "party_iso_code"
    t.string   "ann_symbol"
    t.text     "full_note_en"
    t.text     "full_note_es"
    t.text     "full_note_fr"
    t.text     "short_note_en"
    t.text     "short_note_es"
    t.text     "short_note_fr"
    t.boolean  "display_in_index"
    t.boolean  "display_in_footnote"
    t.string   "hash_ann_symbol"
    t.string   "hash_ann_parent_symbol"
    t.text     "hash_full_note_en"
    t.text     "hash_full_note_es"
    t.text     "hash_full_note_fr"
    t.integer  "inclusion_taxon_concept_id"
    t.text     "inherited_short_note_en"
    t.text     "inherited_full_note_en"
    t.text     "auto_note"
    t.boolean  "is_current"
    t.boolean  "explicit_change"
    t.datetime "updated_at"
    t.boolean  "show_in_history"
    t.boolean  "show_in_downloads"
    t.boolean  "show_in_timeline"
    t.string   "listed_geo_entities_ids",    :limit => nil
    t.string   "excluded_geo_entities_ids",  :limit => nil
    t.string   "excluded_taxon_concept_ids", :limit => nil
    t.boolean  "dirty"
    t.datetime "expiry"
  end

  add_index "eu_42_listing_changes_mview", ["excluded_geo_entities_ids"], :name => "tmp_cascaded_eu_42_listing_change_excluded_geo_entities_ids_idx"
  add_index "eu_42_listing_changes_mview", ["id", "taxon_concept_id"], :name => "tmp_cascaded_eu_42_listing_changes_mvie_id_taxon_concept_id_idx"
  add_index "eu_42_listing_changes_mview", ["inclusion_taxon_concept_id"], :name => "tmp_cascaded_eu_42_listing_chang_inclusion_taxon_concept_id_idx"
  add_index "eu_42_listing_changes_mview", ["is_current", "change_type_name"], :name => "tmp_cascaded_eu_42_listing_chan_is_current_change_type_name_idx"
  add_index "eu_42_listing_changes_mview", ["listed_geo_entities_ids"], :name => "tmp_cascaded_eu_42_listing_changes__listed_geo_entities_ids_idx"
  add_index "eu_42_listing_changes_mview", ["original_taxon_concept_id"], :name => "tmp_cascaded_eu_42_listing_change_original_taxon_concept_id_idx"
  add_index "eu_42_listing_changes_mview", ["show_in_downloads", "taxon_concept_id"], :name => "tmp_cascaded_eu_42_listing_ch_show_in_downloads_taxon_conce_idx"
  add_index "eu_42_listing_changes_mview", ["show_in_timeline", "taxon_concept_id"], :name => "tmp_cascaded_eu_42_listing_ch_show_in_timeline_taxon_concep_idx"
  add_index "eu_42_listing_changes_mview", ["taxon_concept_id", "original_taxon_concept_id", "change_type_id", "effective_at"], :name => "tmp_cascaded_eu_42_listing_ch_taxon_concept_id_original_tax_idx"

  create_table "eu_44_42_listing_changes_mview", :id => false, :force => true do |t|
    t.integer  "taxon_concept_id"
    t.integer  "id"
    t.integer  "original_taxon_concept_id"
    t.datetime "effective_at"
    t.integer  "species_listing_id"
    t.string   "species_listing_name"
    t.integer  "change_type_id"
    t.string   "change_type_name"
    t.integer  "designation_id"
    t.string   "designation_name"
    t.integer  "parent_id"
    t.integer  "party_id"
    t.string   "party_iso_code"
    t.string   "ann_symbol"
    t.text     "full_note_en"
    t.text     "full_note_es"
    t.text     "full_note_fr"
    t.text     "short_note_en"
    t.text     "short_note_es"
    t.text     "short_note_fr"
    t.boolean  "display_in_index"
    t.boolean  "display_in_footnote"
    t.string   "hash_ann_symbol"
    t.string   "hash_ann_parent_symbol"
    t.text     "hash_full_note_en"
    t.text     "hash_full_note_es"
    t.text     "hash_full_note_fr"
    t.integer  "inclusion_taxon_concept_id"
    t.text     "inherited_short_note_en"
    t.text     "inherited_full_note_en"
    t.text     "auto_note"
    t.boolean  "is_current"
    t.boolean  "explicit_change"
    t.datetime "updated_at"
    t.boolean  "show_in_history"
    t.boolean  "show_in_downloads"
    t.boolean  "show_in_timeline"
    t.string   "listed_geo_entities_ids",    :limit => nil
    t.string   "excluded_geo_entities_ids",  :limit => nil
    t.string   "excluded_taxon_concept_ids", :limit => nil
    t.boolean  "dirty"
    t.datetime "expiry"
  end

  add_index "eu_44_42_listing_changes_mview", ["excluded_geo_entities_ids"], :name => "tmp_cascaded_eu_44_42_listing_cha_excluded_geo_entities_ids_idx"
  add_index "eu_44_42_listing_changes_mview", ["id", "taxon_concept_id"], :name => "tmp_cascaded_eu_44_42_listing_changes_m_id_taxon_concept_id_idx"
  add_index "eu_44_42_listing_changes_mview", ["inclusion_taxon_concept_id"], :name => "tmp_cascaded_eu_44_42_listing_ch_inclusion_taxon_concept_id_idx"
  add_index "eu_44_42_listing_changes_mview", ["is_current", "change_type_name"], :name => "tmp_cascaded_eu_44_42_listing_c_is_current_change_type_name_idx"
  add_index "eu_44_42_listing_changes_mview", ["listed_geo_entities_ids"], :name => "tmp_cascaded_eu_44_42_listing_chang_listed_geo_entities_ids_idx"
  add_index "eu_44_42_listing_changes_mview", ["original_taxon_concept_id"], :name => "tmp_cascaded_eu_44_42_listing_cha_original_taxon_concept_id_idx"
  add_index "eu_44_42_listing_changes_mview", ["show_in_downloads", "taxon_concept_id"], :name => "tmp_cascaded_eu_44_42_listing_show_in_downloads_taxon_conce_idx"
  add_index "eu_44_42_listing_changes_mview", ["show_in_timeline", "taxon_concept_id"], :name => "tmp_cascaded_eu_44_42_listing_show_in_timeline_taxon_concep_idx"
  add_index "eu_44_42_listing_changes_mview", ["taxon_concept_id", "original_taxon_concept_id", "change_type_id", "effective_at"], :name => "tmp_cascaded_eu_44_42_listing_taxon_concept_id_original_tax_idx"

  create_table "eu_47_61_44_42_listing_changes_mview", :id => false, :force => true do |t|
    t.integer  "taxon_concept_id"
    t.integer  "id"
    t.integer  "original_taxon_concept_id"
    t.datetime "effective_at"
    t.integer  "species_listing_id"
    t.string   "species_listing_name"
    t.integer  "change_type_id"
    t.string   "change_type_name"
    t.integer  "designation_id"
    t.string   "designation_name"
    t.integer  "parent_id"
    t.integer  "party_id"
    t.string   "party_iso_code"
    t.string   "ann_symbol"
    t.text     "full_note_en"
    t.text     "full_note_es"
    t.text     "full_note_fr"
    t.text     "short_note_en"
    t.text     "short_note_es"
    t.text     "short_note_fr"
    t.boolean  "display_in_index"
    t.boolean  "display_in_footnote"
    t.string   "hash_ann_symbol"
    t.string   "hash_ann_parent_symbol"
    t.text     "hash_full_note_en"
    t.text     "hash_full_note_es"
    t.text     "hash_full_note_fr"
    t.integer  "inclusion_taxon_concept_id"
    t.text     "inherited_short_note_en"
    t.text     "inherited_full_note_en"
    t.text     "auto_note"
    t.boolean  "is_current"
    t.boolean  "explicit_change"
    t.datetime "updated_at"
    t.boolean  "show_in_history"
    t.boolean  "show_in_downloads"
    t.boolean  "show_in_timeline"
    t.string   "listed_geo_entities_ids",    :limit => nil
    t.string   "excluded_geo_entities_ids",  :limit => nil
    t.string   "excluded_taxon_concept_ids", :limit => nil
    t.boolean  "dirty"
    t.datetime "expiry"
  end

  add_index "eu_47_61_44_42_listing_changes_mview", ["excluded_geo_entities_ids"], :name => "tmp_cascaded_eu_47_61_44_42_listi_excluded_geo_entities_ids_idx"
  add_index "eu_47_61_44_42_listing_changes_mview", ["id", "taxon_concept_id"], :name => "tmp_cascaded_eu_47_61_44_42_listing_cha_id_taxon_concept_id_idx"
  add_index "eu_47_61_44_42_listing_changes_mview", ["inclusion_taxon_concept_id"], :name => "tmp_cascaded_eu_47_61_44_42_list_inclusion_taxon_concept_id_idx"
  add_index "eu_47_61_44_42_listing_changes_mview", ["is_current", "change_type_name"], :name => "tmp_cascaded_eu_47_61_44_42_lis_is_current_change_type_name_idx"
  add_index "eu_47_61_44_42_listing_changes_mview", ["listed_geo_entities_ids"], :name => "tmp_cascaded_eu_47_61_44_42_listing_listed_geo_entities_ids_idx"
  add_index "eu_47_61_44_42_listing_changes_mview", ["original_taxon_concept_id"], :name => "tmp_cascaded_eu_47_61_44_42_listi_original_taxon_concept_id_idx"
  add_index "eu_47_61_44_42_listing_changes_mview", ["show_in_downloads", "taxon_concept_id"], :name => "tmp_cascaded_eu_47_61_44_42_l_show_in_downloads_taxon_conce_idx"
  add_index "eu_47_61_44_42_listing_changes_mview", ["show_in_timeline", "taxon_concept_id"], :name => "tmp_cascaded_eu_47_61_44_42_l_show_in_timeline_taxon_concep_idx"
  add_index "eu_47_61_44_42_listing_changes_mview", ["taxon_concept_id", "original_taxon_concept_id", "change_type_id", "effective_at"], :name => "tmp_cascaded_eu_47_61_44_42_l_taxon_concept_id_original_tax_idx"

  create_table "eu_48_66_41_55_listing_changes_mview", :id => false, :force => true do |t|
    t.integer  "taxon_concept_id"
    t.integer  "id"
    t.integer  "original_taxon_concept_id"
    t.datetime "effective_at"
    t.integer  "species_listing_id"
    t.string   "species_listing_name"
    t.integer  "change_type_id"
    t.string   "change_type_name"
    t.integer  "designation_id"
    t.string   "designation_name"
    t.integer  "parent_id"
    t.integer  "party_id"
    t.string   "party_iso_code"
    t.string   "ann_symbol"
    t.text     "full_note_en"
    t.text     "full_note_es"
    t.text     "full_note_fr"
    t.text     "short_note_en"
    t.text     "short_note_es"
    t.text     "short_note_fr"
    t.boolean  "display_in_index"
    t.boolean  "display_in_footnote"
    t.string   "hash_ann_symbol"
    t.string   "hash_ann_parent_symbol"
    t.text     "hash_full_note_en"
    t.text     "hash_full_note_es"
    t.text     "hash_full_note_fr"
    t.integer  "inclusion_taxon_concept_id"
    t.text     "inherited_short_note_en"
    t.text     "inherited_full_note_en"
    t.text     "auto_note"
    t.boolean  "is_current"
    t.boolean  "explicit_change"
    t.datetime "updated_at"
    t.boolean  "show_in_history"
    t.boolean  "show_in_downloads"
    t.boolean  "show_in_timeline"
    t.string   "listed_geo_entities_ids",    :limit => nil
    t.string   "excluded_geo_entities_ids",  :limit => nil
    t.string   "excluded_taxon_concept_ids", :limit => nil
    t.boolean  "dirty"
    t.datetime "expiry"
  end

  add_index "eu_48_66_41_55_listing_changes_mview", ["excluded_geo_entities_ids"], :name => "tmp_cascaded_eu_48_66_41_55_listi_excluded_geo_entities_ids_idx"
  add_index "eu_48_66_41_55_listing_changes_mview", ["id", "taxon_concept_id"], :name => "tmp_cascaded_eu_48_66_41_55_listing_cha_id_taxon_concept_id_idx"
  add_index "eu_48_66_41_55_listing_changes_mview", ["inclusion_taxon_concept_id"], :name => "tmp_cascaded_eu_48_66_41_55_list_inclusion_taxon_concept_id_idx"
  add_index "eu_48_66_41_55_listing_changes_mview", ["is_current", "change_type_name"], :name => "tmp_cascaded_eu_48_66_41_55_lis_is_current_change_type_name_idx"
  add_index "eu_48_66_41_55_listing_changes_mview", ["listed_geo_entities_ids"], :name => "tmp_cascaded_eu_48_66_41_55_listing_listed_geo_entities_ids_idx"
  add_index "eu_48_66_41_55_listing_changes_mview", ["original_taxon_concept_id"], :name => "tmp_cascaded_eu_48_66_41_55_listi_original_taxon_concept_id_idx"
  add_index "eu_48_66_41_55_listing_changes_mview", ["show_in_downloads", "taxon_concept_id"], :name => "tmp_cascaded_eu_48_66_41_55_l_show_in_downloads_taxon_conce_idx"
  add_index "eu_48_66_41_55_listing_changes_mview", ["show_in_timeline", "taxon_concept_id"], :name => "tmp_cascaded_eu_48_66_41_55_l_show_in_timeline_taxon_concep_idx"
  add_index "eu_48_66_41_55_listing_changes_mview", ["taxon_concept_id", "original_taxon_concept_id", "change_type_id", "effective_at"], :name => "tmp_cascaded_eu_48_66_41_55_l_taxon_concept_id_original_tax_idx"

  create_table "eu_49_48_66_41_55_listing_changes_mview", :id => false, :force => true do |t|
    t.integer  "taxon_concept_id"
    t.integer  "id"
    t.integer  "original_taxon_concept_id"
    t.datetime "effective_at"
    t.integer  "species_listing_id"
    t.string   "species_listing_name"
    t.integer  "change_type_id"
    t.string   "change_type_name"
    t.integer  "designation_id"
    t.string   "designation_name"
    t.integer  "parent_id"
    t.integer  "party_id"
    t.string   "party_iso_code"
    t.string   "ann_symbol"
    t.text     "full_note_en"
    t.text     "full_note_es"
    t.text     "full_note_fr"
    t.text     "short_note_en"
    t.text     "short_note_es"
    t.text     "short_note_fr"
    t.boolean  "display_in_index"
    t.boolean  "display_in_footnote"
    t.string   "hash_ann_symbol"
    t.string   "hash_ann_parent_symbol"
    t.text     "hash_full_note_en"
    t.text     "hash_full_note_es"
    t.text     "hash_full_note_fr"
    t.integer  "inclusion_taxon_concept_id"
    t.text     "inherited_short_note_en"
    t.text     "inherited_full_note_en"
    t.text     "auto_note"
    t.boolean  "is_current"
    t.boolean  "explicit_change"
    t.datetime "updated_at"
    t.boolean  "show_in_history"
    t.boolean  "show_in_downloads"
    t.boolean  "show_in_timeline"
    t.string   "listed_geo_entities_ids",    :limit => nil
    t.string   "excluded_geo_entities_ids",  :limit => nil
    t.string   "excluded_taxon_concept_ids", :limit => nil
    t.boolean  "dirty"
    t.datetime "expiry"
  end

  add_index "eu_49_48_66_41_55_listing_changes_mview", ["excluded_geo_entities_ids"], :name => "tmp_cascaded_eu_49_48_66_41_55_li_excluded_geo_entities_ids_idx"
  add_index "eu_49_48_66_41_55_listing_changes_mview", ["id", "taxon_concept_id"], :name => "tmp_cascaded_eu_49_48_66_41_55_listing__id_taxon_concept_id_idx"
  add_index "eu_49_48_66_41_55_listing_changes_mview", ["inclusion_taxon_concept_id"], :name => "tmp_cascaded_eu_49_48_66_41_55_l_inclusion_taxon_concept_id_idx"
  add_index "eu_49_48_66_41_55_listing_changes_mview", ["is_current", "change_type_name"], :name => "tmp_cascaded_eu_49_48_66_41_55__is_current_change_type_name_idx"
  add_index "eu_49_48_66_41_55_listing_changes_mview", ["listed_geo_entities_ids"], :name => "tmp_cascaded_eu_49_48_66_41_55_list_listed_geo_entities_ids_idx"
  add_index "eu_49_48_66_41_55_listing_changes_mview", ["original_taxon_concept_id"], :name => "tmp_cascaded_eu_49_48_66_41_55_li_original_taxon_concept_id_idx"
  add_index "eu_49_48_66_41_55_listing_changes_mview", ["show_in_downloads", "taxon_concept_id"], :name => "tmp_cascaded_eu_49_48_66_41_5_show_in_downloads_taxon_conce_idx"
  add_index "eu_49_48_66_41_55_listing_changes_mview", ["show_in_timeline", "taxon_concept_id"], :name => "tmp_cascaded_eu_49_48_66_41_5_show_in_timeline_taxon_concep_idx"
  add_index "eu_49_48_66_41_55_listing_changes_mview", ["taxon_concept_id", "original_taxon_concept_id", "change_type_id", "effective_at"], :name => "tmp_cascaded_eu_49_48_66_41_5_taxon_concept_id_original_tax_idx"

  create_table "eu_54_listing_changes_mview", :id => false, :force => true do |t|
    t.integer  "taxon_concept_id"
    t.integer  "id"
    t.integer  "original_taxon_concept_id"
    t.datetime "effective_at"
    t.integer  "species_listing_id"
    t.string   "species_listing_name"
    t.integer  "change_type_id"
    t.string   "change_type_name"
    t.integer  "designation_id"
    t.string   "designation_name"
    t.integer  "parent_id"
    t.integer  "party_id"
    t.string   "party_iso_code"
    t.string   "ann_symbol"
    t.text     "full_note_en"
    t.text     "full_note_es"
    t.text     "full_note_fr"
    t.text     "short_note_en"
    t.text     "short_note_es"
    t.text     "short_note_fr"
    t.boolean  "display_in_index"
    t.boolean  "display_in_footnote"
    t.string   "hash_ann_symbol"
    t.string   "hash_ann_parent_symbol"
    t.text     "hash_full_note_en"
    t.text     "hash_full_note_es"
    t.text     "hash_full_note_fr"
    t.integer  "inclusion_taxon_concept_id"
    t.text     "inherited_short_note_en"
    t.text     "inherited_full_note_en"
    t.text     "auto_note"
    t.boolean  "is_current"
    t.boolean  "explicit_change"
    t.datetime "updated_at"
    t.boolean  "show_in_history"
    t.boolean  "show_in_downloads"
    t.boolean  "show_in_timeline"
    t.string   "listed_geo_entities_ids",    :limit => nil
    t.string   "excluded_geo_entities_ids",  :limit => nil
    t.string   "excluded_taxon_concept_ids", :limit => nil
    t.boolean  "dirty"
    t.datetime "expiry"
  end

  add_index "eu_54_listing_changes_mview", ["excluded_geo_entities_ids"], :name => "tmp_cascaded_eu_54_listing_change_excluded_geo_entities_ids_idx"
  add_index "eu_54_listing_changes_mview", ["id", "taxon_concept_id"], :name => "tmp_cascaded_eu_54_listing_changes_mvie_id_taxon_concept_id_idx"
  add_index "eu_54_listing_changes_mview", ["inclusion_taxon_concept_id"], :name => "tmp_cascaded_eu_54_listing_chang_inclusion_taxon_concept_id_idx"
  add_index "eu_54_listing_changes_mview", ["is_current", "change_type_name"], :name => "tmp_cascaded_eu_54_listing_chan_is_current_change_type_name_idx"
  add_index "eu_54_listing_changes_mview", ["listed_geo_entities_ids"], :name => "tmp_cascaded_eu_54_listing_changes__listed_geo_entities_ids_idx"
  add_index "eu_54_listing_changes_mview", ["original_taxon_concept_id"], :name => "tmp_cascaded_eu_54_listing_change_original_taxon_concept_id_idx"
  add_index "eu_54_listing_changes_mview", ["show_in_downloads", "taxon_concept_id"], :name => "tmp_cascaded_eu_54_listing_ch_show_in_downloads_taxon_conce_idx"
  add_index "eu_54_listing_changes_mview", ["show_in_timeline", "taxon_concept_id"], :name => "tmp_cascaded_eu_54_listing_ch_show_in_timeline_taxon_concep_idx"
  add_index "eu_54_listing_changes_mview", ["taxon_concept_id", "original_taxon_concept_id", "change_type_id", "effective_at"], :name => "tmp_cascaded_eu_54_listing_ch_taxon_concept_id_original_tax_idx"

  create_table "eu_61_44_42_listing_changes_mview", :id => false, :force => true do |t|
    t.integer  "taxon_concept_id"
    t.integer  "id"
    t.integer  "original_taxon_concept_id"
    t.datetime "effective_at"
    t.integer  "species_listing_id"
    t.string   "species_listing_name"
    t.integer  "change_type_id"
    t.string   "change_type_name"
    t.integer  "designation_id"
    t.string   "designation_name"
    t.integer  "parent_id"
    t.integer  "party_id"
    t.string   "party_iso_code"
    t.string   "ann_symbol"
    t.text     "full_note_en"
    t.text     "full_note_es"
    t.text     "full_note_fr"
    t.text     "short_note_en"
    t.text     "short_note_es"
    t.text     "short_note_fr"
    t.boolean  "display_in_index"
    t.boolean  "display_in_footnote"
    t.string   "hash_ann_symbol"
    t.string   "hash_ann_parent_symbol"
    t.text     "hash_full_note_en"
    t.text     "hash_full_note_es"
    t.text     "hash_full_note_fr"
    t.integer  "inclusion_taxon_concept_id"
    t.text     "inherited_short_note_en"
    t.text     "inherited_full_note_en"
    t.text     "auto_note"
    t.boolean  "is_current"
    t.boolean  "explicit_change"
    t.datetime "updated_at"
    t.boolean  "show_in_history"
    t.boolean  "show_in_downloads"
    t.boolean  "show_in_timeline"
    t.string   "listed_geo_entities_ids",    :limit => nil
    t.string   "excluded_geo_entities_ids",  :limit => nil
    t.string   "excluded_taxon_concept_ids", :limit => nil
    t.boolean  "dirty"
    t.datetime "expiry"
  end

  add_index "eu_61_44_42_listing_changes_mview", ["excluded_geo_entities_ids"], :name => "tmp_cascaded_eu_61_44_42_listing__excluded_geo_entities_ids_idx"
  add_index "eu_61_44_42_listing_changes_mview", ["id", "taxon_concept_id"], :name => "tmp_cascaded_eu_61_44_42_listing_change_id_taxon_concept_id_idx"
  add_index "eu_61_44_42_listing_changes_mview", ["inclusion_taxon_concept_id"], :name => "tmp_cascaded_eu_61_44_42_listing_inclusion_taxon_concept_id_idx"
  add_index "eu_61_44_42_listing_changes_mview", ["is_current", "change_type_name"], :name => "tmp_cascaded_eu_61_44_42_listin_is_current_change_type_name_idx"
  add_index "eu_61_44_42_listing_changes_mview", ["listed_geo_entities_ids"], :name => "tmp_cascaded_eu_61_44_42_listing_ch_listed_geo_entities_ids_idx"
  add_index "eu_61_44_42_listing_changes_mview", ["original_taxon_concept_id"], :name => "tmp_cascaded_eu_61_44_42_listing__original_taxon_concept_id_idx"
  add_index "eu_61_44_42_listing_changes_mview", ["show_in_downloads", "taxon_concept_id"], :name => "tmp_cascaded_eu_61_44_42_list_show_in_downloads_taxon_conce_idx"
  add_index "eu_61_44_42_listing_changes_mview", ["show_in_timeline", "taxon_concept_id"], :name => "tmp_cascaded_eu_61_44_42_list_show_in_timeline_taxon_concep_idx"
  add_index "eu_61_44_42_listing_changes_mview", ["taxon_concept_id", "original_taxon_concept_id", "change_type_id", "effective_at"], :name => "tmp_cascaded_eu_61_44_42_list_taxon_concept_id_original_tax_idx"

  create_table "eu_62_54_listing_changes_mview", :id => false, :force => true do |t|
    t.integer  "taxon_concept_id"
    t.integer  "id"
    t.integer  "original_taxon_concept_id"
    t.datetime "effective_at"
    t.integer  "species_listing_id"
    t.string   "species_listing_name"
    t.integer  "change_type_id"
    t.string   "change_type_name"
    t.integer  "designation_id"
    t.string   "designation_name"
    t.integer  "parent_id"
    t.integer  "party_id"
    t.string   "party_iso_code"
    t.string   "ann_symbol"
    t.text     "full_note_en"
    t.text     "full_note_es"
    t.text     "full_note_fr"
    t.text     "short_note_en"
    t.text     "short_note_es"
    t.text     "short_note_fr"
    t.boolean  "display_in_index"
    t.boolean  "display_in_footnote"
    t.string   "hash_ann_symbol"
    t.string   "hash_ann_parent_symbol"
    t.text     "hash_full_note_en"
    t.text     "hash_full_note_es"
    t.text     "hash_full_note_fr"
    t.integer  "inclusion_taxon_concept_id"
    t.text     "inherited_short_note_en"
    t.text     "inherited_full_note_en"
    t.text     "auto_note"
    t.boolean  "is_current"
    t.boolean  "explicit_change"
    t.datetime "updated_at"
    t.boolean  "show_in_history"
    t.boolean  "show_in_downloads"
    t.boolean  "show_in_timeline"
    t.string   "listed_geo_entities_ids",    :limit => nil
    t.string   "excluded_geo_entities_ids",  :limit => nil
    t.string   "excluded_taxon_concept_ids", :limit => nil
    t.boolean  "dirty"
    t.datetime "expiry"
  end

  add_index "eu_62_54_listing_changes_mview", ["excluded_geo_entities_ids"], :name => "tmp_cascaded_eu_62_54_listing_cha_excluded_geo_entities_ids_idx"
  add_index "eu_62_54_listing_changes_mview", ["id", "taxon_concept_id"], :name => "tmp_cascaded_eu_62_54_listing_changes_m_id_taxon_concept_id_idx"
  add_index "eu_62_54_listing_changes_mview", ["inclusion_taxon_concept_id"], :name => "tmp_cascaded_eu_62_54_listing_ch_inclusion_taxon_concept_id_idx"
  add_index "eu_62_54_listing_changes_mview", ["is_current", "change_type_name"], :name => "tmp_cascaded_eu_62_54_listing_c_is_current_change_type_name_idx"
  add_index "eu_62_54_listing_changes_mview", ["listed_geo_entities_ids"], :name => "tmp_cascaded_eu_62_54_listing_chang_listed_geo_entities_ids_idx"
  add_index "eu_62_54_listing_changes_mview", ["original_taxon_concept_id"], :name => "tmp_cascaded_eu_62_54_listing_cha_original_taxon_concept_id_idx"
  add_index "eu_62_54_listing_changes_mview", ["show_in_downloads", "taxon_concept_id"], :name => "tmp_cascaded_eu_62_54_listing_show_in_downloads_taxon_conce_idx"
  add_index "eu_62_54_listing_changes_mview", ["show_in_timeline", "taxon_concept_id"], :name => "tmp_cascaded_eu_62_54_listing_show_in_timeline_taxon_concep_idx"
  add_index "eu_62_54_listing_changes_mview", ["taxon_concept_id", "original_taxon_concept_id", "change_type_id", "effective_at"], :name => "tmp_cascaded_eu_62_54_listing_taxon_concept_id_original_tax_idx"

  create_table "eu_65_listing_changes_mview", :id => false, :force => true do |t|
    t.integer  "taxon_concept_id"
    t.integer  "id"
    t.integer  "original_taxon_concept_id"
    t.datetime "effective_at"
    t.integer  "species_listing_id"
    t.string   "species_listing_name"
    t.integer  "change_type_id"
    t.string   "change_type_name"
    t.integer  "designation_id"
    t.string   "designation_name"
    t.integer  "parent_id"
    t.integer  "party_id"
    t.string   "party_iso_code"
    t.string   "ann_symbol"
    t.text     "full_note_en"
    t.text     "full_note_es"
    t.text     "full_note_fr"
    t.text     "short_note_en"
    t.text     "short_note_es"
    t.text     "short_note_fr"
    t.boolean  "display_in_index"
    t.boolean  "display_in_footnote"
    t.string   "hash_ann_symbol"
    t.string   "hash_ann_parent_symbol"
    t.text     "hash_full_note_en"
    t.text     "hash_full_note_es"
    t.text     "hash_full_note_fr"
    t.integer  "inclusion_taxon_concept_id"
    t.text     "inherited_short_note_en"
    t.text     "inherited_full_note_en"
    t.text     "auto_note"
    t.boolean  "is_current"
    t.boolean  "explicit_change"
    t.datetime "updated_at"
    t.boolean  "show_in_history"
    t.boolean  "show_in_downloads"
    t.boolean  "show_in_timeline"
    t.string   "listed_geo_entities_ids",    :limit => nil
    t.string   "excluded_geo_entities_ids",  :limit => nil
    t.string   "excluded_taxon_concept_ids", :limit => nil
    t.boolean  "dirty"
    t.datetime "expiry"
  end

  add_index "eu_65_listing_changes_mview", ["excluded_geo_entities_ids"], :name => "tmp_cascaded_eu_65_listing_change_excluded_geo_entities_ids_idx"
  add_index "eu_65_listing_changes_mview", ["id", "taxon_concept_id"], :name => "tmp_cascaded_eu_65_listing_changes_mvie_id_taxon_concept_id_idx"
  add_index "eu_65_listing_changes_mview", ["inclusion_taxon_concept_id"], :name => "tmp_cascaded_eu_65_listing_chang_inclusion_taxon_concept_id_idx"
  add_index "eu_65_listing_changes_mview", ["is_current", "change_type_name"], :name => "tmp_cascaded_eu_65_listing_chan_is_current_change_type_name_idx"
  add_index "eu_65_listing_changes_mview", ["listed_geo_entities_ids"], :name => "tmp_cascaded_eu_65_listing_changes__listed_geo_entities_ids_idx"
  add_index "eu_65_listing_changes_mview", ["original_taxon_concept_id"], :name => "tmp_cascaded_eu_65_listing_change_original_taxon_concept_id_idx"
  add_index "eu_65_listing_changes_mview", ["show_in_downloads", "taxon_concept_id"], :name => "tmp_cascaded_eu_65_listing_ch_show_in_downloads_taxon_conce_idx"
  add_index "eu_65_listing_changes_mview", ["show_in_timeline", "taxon_concept_id"], :name => "tmp_cascaded_eu_65_listing_ch_show_in_timeline_taxon_concep_idx"
  add_index "eu_65_listing_changes_mview", ["taxon_concept_id", "original_taxon_concept_id", "change_type_id", "effective_at"], :name => "tmp_cascaded_eu_65_listing_ch_taxon_concept_id_original_tax_idx"

  create_table "eu_66_41_55_listing_changes_mview", :id => false, :force => true do |t|
    t.integer  "taxon_concept_id"
    t.integer  "id"
    t.integer  "original_taxon_concept_id"
    t.datetime "effective_at"
    t.integer  "species_listing_id"
    t.string   "species_listing_name"
    t.integer  "change_type_id"
    t.string   "change_type_name"
    t.integer  "designation_id"
    t.string   "designation_name"
    t.integer  "parent_id"
    t.integer  "party_id"
    t.string   "party_iso_code"
    t.string   "ann_symbol"
    t.text     "full_note_en"
    t.text     "full_note_es"
    t.text     "full_note_fr"
    t.text     "short_note_en"
    t.text     "short_note_es"
    t.text     "short_note_fr"
    t.boolean  "display_in_index"
    t.boolean  "display_in_footnote"
    t.string   "hash_ann_symbol"
    t.string   "hash_ann_parent_symbol"
    t.text     "hash_full_note_en"
    t.text     "hash_full_note_es"
    t.text     "hash_full_note_fr"
    t.integer  "inclusion_taxon_concept_id"
    t.text     "inherited_short_note_en"
    t.text     "inherited_full_note_en"
    t.text     "auto_note"
    t.boolean  "is_current"
    t.boolean  "explicit_change"
    t.datetime "updated_at"
    t.boolean  "show_in_history"
    t.boolean  "show_in_downloads"
    t.boolean  "show_in_timeline"
    t.string   "listed_geo_entities_ids",    :limit => nil
    t.string   "excluded_geo_entities_ids",  :limit => nil
    t.string   "excluded_taxon_concept_ids", :limit => nil
    t.boolean  "dirty"
    t.datetime "expiry"
  end

  add_index "eu_66_41_55_listing_changes_mview", ["excluded_geo_entities_ids"], :name => "tmp_cascaded_eu_66_41_55_listing__excluded_geo_entities_ids_idx"
  add_index "eu_66_41_55_listing_changes_mview", ["id", "taxon_concept_id"], :name => "tmp_cascaded_eu_66_41_55_listing_change_id_taxon_concept_id_idx"
  add_index "eu_66_41_55_listing_changes_mview", ["inclusion_taxon_concept_id"], :name => "tmp_cascaded_eu_66_41_55_listing_inclusion_taxon_concept_id_idx"
  add_index "eu_66_41_55_listing_changes_mview", ["is_current", "change_type_name"], :name => "tmp_cascaded_eu_66_41_55_listin_is_current_change_type_name_idx"
  add_index "eu_66_41_55_listing_changes_mview", ["listed_geo_entities_ids"], :name => "tmp_cascaded_eu_66_41_55_listing_ch_listed_geo_entities_ids_idx"
  add_index "eu_66_41_55_listing_changes_mview", ["original_taxon_concept_id"], :name => "tmp_cascaded_eu_66_41_55_listing__original_taxon_concept_id_idx"
  add_index "eu_66_41_55_listing_changes_mview", ["show_in_downloads", "taxon_concept_id"], :name => "tmp_cascaded_eu_66_41_55_list_show_in_downloads_taxon_conce_idx"
  add_index "eu_66_41_55_listing_changes_mview", ["show_in_timeline", "taxon_concept_id"], :name => "tmp_cascaded_eu_66_41_55_list_show_in_timeline_taxon_concep_idx"
  add_index "eu_66_41_55_listing_changes_mview", ["taxon_concept_id", "original_taxon_concept_id", "change_type_id", "effective_at"], :name => "tmp_cascaded_eu_66_41_55_list_taxon_concept_id_original_tax_idx"

  create_table "eu_67_listing_changes_mview", :id => false, :force => true do |t|
    t.integer  "taxon_concept_id"
    t.integer  "id"
    t.integer  "original_taxon_concept_id"
    t.datetime "effective_at"
    t.integer  "species_listing_id"
    t.string   "species_listing_name"
    t.integer  "change_type_id"
    t.string   "change_type_name"
    t.integer  "designation_id"
    t.string   "designation_name"
    t.integer  "parent_id"
    t.integer  "party_id"
    t.string   "party_iso_code"
    t.string   "ann_symbol"
    t.text     "full_note_en"
    t.text     "full_note_es"
    t.text     "full_note_fr"
    t.text     "short_note_en"
    t.text     "short_note_es"
    t.text     "short_note_fr"
    t.boolean  "display_in_index"
    t.boolean  "display_in_footnote"
    t.string   "hash_ann_symbol"
    t.string   "hash_ann_parent_symbol"
    t.text     "hash_full_note_en"
    t.text     "hash_full_note_es"
    t.text     "hash_full_note_fr"
    t.integer  "inclusion_taxon_concept_id"
    t.text     "inherited_short_note_en"
    t.text     "inherited_full_note_en"
    t.text     "auto_note"
    t.boolean  "is_current"
    t.boolean  "explicit_change"
    t.datetime "updated_at"
    t.boolean  "show_in_history"
    t.boolean  "show_in_downloads"
    t.boolean  "show_in_timeline"
    t.string   "listed_geo_entities_ids",    :limit => nil
    t.string   "excluded_geo_entities_ids",  :limit => nil
    t.string   "excluded_taxon_concept_ids", :limit => nil
    t.boolean  "dirty"
    t.datetime "expiry"
  end

  add_index "eu_67_listing_changes_mview", ["excluded_geo_entities_ids"], :name => "tmp_cascaded_eu_67_listing_change_excluded_geo_entities_ids_idx"
  add_index "eu_67_listing_changes_mview", ["id", "taxon_concept_id"], :name => "tmp_cascaded_eu_67_listing_changes_mvie_id_taxon_concept_id_idx"
  add_index "eu_67_listing_changes_mview", ["inclusion_taxon_concept_id"], :name => "tmp_cascaded_eu_67_listing_chang_inclusion_taxon_concept_id_idx"
  add_index "eu_67_listing_changes_mview", ["is_current", "change_type_name"], :name => "tmp_cascaded_eu_67_listing_chan_is_current_change_type_name_idx"
  add_index "eu_67_listing_changes_mview", ["listed_geo_entities_ids"], :name => "tmp_cascaded_eu_67_listing_changes__listed_geo_entities_ids_idx"
  add_index "eu_67_listing_changes_mview", ["original_taxon_concept_id"], :name => "tmp_cascaded_eu_67_listing_change_original_taxon_concept_id_idx"
  add_index "eu_67_listing_changes_mview", ["show_in_downloads", "taxon_concept_id"], :name => "tmp_cascaded_eu_67_listing_ch_show_in_downloads_taxon_conce_idx"
  add_index "eu_67_listing_changes_mview", ["show_in_timeline", "taxon_concept_id"], :name => "tmp_cascaded_eu_67_listing_ch_show_in_timeline_taxon_concep_idx"
  add_index "eu_67_listing_changes_mview", ["taxon_concept_id", "original_taxon_concept_id", "change_type_id", "effective_at"], :name => "tmp_cascaded_eu_67_listing_ch_taxon_concept_id_original_tax_idx"

  create_table "eu_71_listing_changes_mview", :id => false, :force => true do |t|
    t.integer  "taxon_concept_id"
    t.integer  "id"
    t.integer  "original_taxon_concept_id"
    t.datetime "effective_at"
    t.integer  "species_listing_id"
    t.string   "species_listing_name"
    t.integer  "change_type_id"
    t.string   "change_type_name"
    t.integer  "designation_id"
    t.string   "designation_name"
    t.integer  "parent_id"
    t.integer  "party_id"
    t.string   "party_iso_code"
    t.string   "ann_symbol"
    t.text     "full_note_en"
    t.text     "full_note_es"
    t.text     "full_note_fr"
    t.text     "short_note_en"
    t.text     "short_note_es"
    t.text     "short_note_fr"
    t.boolean  "display_in_index"
    t.boolean  "display_in_footnote"
    t.string   "hash_ann_symbol"
    t.string   "hash_ann_parent_symbol"
    t.text     "hash_full_note_en"
    t.text     "hash_full_note_es"
    t.text     "hash_full_note_fr"
    t.integer  "inclusion_taxon_concept_id"
    t.text     "inherited_short_note_en"
    t.text     "inherited_full_note_en"
    t.text     "auto_note"
    t.boolean  "is_current"
    t.boolean  "explicit_change"
    t.datetime "updated_at"
    t.boolean  "show_in_history"
    t.boolean  "show_in_downloads"
    t.boolean  "show_in_timeline"
    t.string   "listed_geo_entities_ids",    :limit => nil
    t.string   "excluded_geo_entities_ids",  :limit => nil
    t.string   "excluded_taxon_concept_ids", :limit => nil
    t.boolean  "dirty"
    t.datetime "expiry"
  end

  add_index "eu_71_listing_changes_mview", ["excluded_geo_entities_ids"], :name => "tmp_cascaded_eu_71_listing_change_excluded_geo_entities_ids_idx"
  add_index "eu_71_listing_changes_mview", ["id", "taxon_concept_id"], :name => "tmp_cascaded_eu_71_listing_changes_mvie_id_taxon_concept_id_idx"
  add_index "eu_71_listing_changes_mview", ["inclusion_taxon_concept_id"], :name => "tmp_cascaded_eu_71_listing_chang_inclusion_taxon_concept_id_idx"
  add_index "eu_71_listing_changes_mview", ["is_current", "change_type_name"], :name => "tmp_cascaded_eu_71_listing_chan_is_current_change_type_name_idx"
  add_index "eu_71_listing_changes_mview", ["listed_geo_entities_ids"], :name => "tmp_cascaded_eu_71_listing_changes__listed_geo_entities_ids_idx"
  add_index "eu_71_listing_changes_mview", ["original_taxon_concept_id"], :name => "tmp_cascaded_eu_71_listing_change_original_taxon_concept_id_idx"
  add_index "eu_71_listing_changes_mview", ["show_in_downloads", "taxon_concept_id"], :name => "tmp_cascaded_eu_71_listing_ch_show_in_downloads_taxon_conce_idx"
  add_index "eu_71_listing_changes_mview", ["show_in_timeline", "taxon_concept_id"], :name => "tmp_cascaded_eu_71_listing_ch_show_in_timeline_taxon_concep_idx"
  add_index "eu_71_listing_changes_mview", ["taxon_concept_id", "original_taxon_concept_id", "change_type_id", "effective_at"], :name => "tmp_cascaded_eu_71_listing_ch_taxon_concept_id_original_tax_idx"

  create_table "eu_72_listing_changes_mview", :id => false, :force => true do |t|
    t.integer  "taxon_concept_id"
    t.integer  "id"
    t.integer  "original_taxon_concept_id"
    t.datetime "effective_at"
    t.integer  "species_listing_id"
    t.string   "species_listing_name"
    t.integer  "change_type_id"
    t.string   "change_type_name"
    t.integer  "designation_id"
    t.string   "designation_name"
    t.integer  "parent_id"
    t.integer  "party_id"
    t.string   "party_iso_code"
    t.string   "ann_symbol"
    t.text     "full_note_en"
    t.text     "full_note_es"
    t.text     "full_note_fr"
    t.text     "short_note_en"
    t.text     "short_note_es"
    t.text     "short_note_fr"
    t.boolean  "display_in_index"
    t.boolean  "display_in_footnote"
    t.string   "hash_ann_symbol"
    t.string   "hash_ann_parent_symbol"
    t.text     "hash_full_note_en"
    t.text     "hash_full_note_es"
    t.text     "hash_full_note_fr"
    t.integer  "inclusion_taxon_concept_id"
    t.text     "inherited_short_note_en"
    t.text     "inherited_full_note_en"
    t.text     "auto_note"
    t.boolean  "is_current"
    t.boolean  "explicit_change"
    t.datetime "updated_at"
    t.boolean  "show_in_history"
    t.boolean  "show_in_downloads"
    t.boolean  "show_in_timeline"
    t.string   "listed_geo_entities_ids",    :limit => nil
    t.string   "excluded_geo_entities_ids",  :limit => nil
    t.string   "excluded_taxon_concept_ids", :limit => nil
    t.boolean  "dirty"
    t.datetime "expiry"
  end

  add_index "eu_72_listing_changes_mview", ["excluded_geo_entities_ids"], :name => "tmp_cascaded_eu_72_listing_change_excluded_geo_entities_ids_idx"
  add_index "eu_72_listing_changes_mview", ["id", "taxon_concept_id"], :name => "tmp_cascaded_eu_72_listing_changes_mvie_id_taxon_concept_id_idx"
  add_index "eu_72_listing_changes_mview", ["inclusion_taxon_concept_id"], :name => "tmp_cascaded_eu_72_listing_chang_inclusion_taxon_concept_id_idx"
  add_index "eu_72_listing_changes_mview", ["is_current", "change_type_name"], :name => "tmp_cascaded_eu_72_listing_chan_is_current_change_type_name_idx"
  add_index "eu_72_listing_changes_mview", ["listed_geo_entities_ids"], :name => "tmp_cascaded_eu_72_listing_changes__listed_geo_entities_ids_idx"
  add_index "eu_72_listing_changes_mview", ["original_taxon_concept_id"], :name => "tmp_cascaded_eu_72_listing_change_original_taxon_concept_id_idx"
  add_index "eu_72_listing_changes_mview", ["show_in_downloads", "taxon_concept_id"], :name => "tmp_cascaded_eu_72_listing_ch_show_in_downloads_taxon_conce_idx"
  add_index "eu_72_listing_changes_mview", ["show_in_timeline", "taxon_concept_id"], :name => "tmp_cascaded_eu_72_listing_ch_show_in_timeline_taxon_concep_idx"
  add_index "eu_72_listing_changes_mview", ["taxon_concept_id", "original_taxon_concept_id", "change_type_id", "effective_at"], :name => "tmp_cascaded_eu_72_listing_ch_taxon_concept_id_original_tax_idx"

  create_table "eu_73_listing_changes_mview", :id => false, :force => true do |t|
    t.integer  "taxon_concept_id"
    t.integer  "id"
    t.integer  "original_taxon_concept_id"
    t.datetime "effective_at"
    t.integer  "species_listing_id"
    t.string   "species_listing_name"
    t.integer  "change_type_id"
    t.string   "change_type_name"
    t.integer  "designation_id"
    t.string   "designation_name"
    t.integer  "parent_id"
    t.integer  "party_id"
    t.string   "party_iso_code"
    t.string   "ann_symbol"
    t.text     "full_note_en"
    t.text     "full_note_es"
    t.text     "full_note_fr"
    t.text     "short_note_en"
    t.text     "short_note_es"
    t.text     "short_note_fr"
    t.boolean  "display_in_index"
    t.boolean  "display_in_footnote"
    t.string   "hash_ann_symbol"
    t.string   "hash_ann_parent_symbol"
    t.text     "hash_full_note_en"
    t.text     "hash_full_note_es"
    t.text     "hash_full_note_fr"
    t.integer  "inclusion_taxon_concept_id"
    t.text     "inherited_short_note_en"
    t.text     "inherited_full_note_en"
    t.text     "auto_note"
    t.boolean  "is_current"
    t.boolean  "explicit_change"
    t.datetime "updated_at"
    t.boolean  "show_in_history"
    t.boolean  "show_in_downloads"
    t.boolean  "show_in_timeline"
    t.string   "listed_geo_entities_ids",    :limit => nil
    t.string   "excluded_geo_entities_ids",  :limit => nil
    t.string   "excluded_taxon_concept_ids", :limit => nil
    t.boolean  "dirty"
    t.datetime "expiry"
  end

  add_index "eu_73_listing_changes_mview", ["excluded_geo_entities_ids"], :name => "tmp_cascaded_eu_73_listing_change_excluded_geo_entities_ids_idx"
  add_index "eu_73_listing_changes_mview", ["id", "taxon_concept_id"], :name => "tmp_cascaded_eu_73_listing_changes_mvie_id_taxon_concept_id_idx"
  add_index "eu_73_listing_changes_mview", ["inclusion_taxon_concept_id"], :name => "tmp_cascaded_eu_73_listing_chang_inclusion_taxon_concept_id_idx"
  add_index "eu_73_listing_changes_mview", ["is_current", "change_type_name"], :name => "tmp_cascaded_eu_73_listing_chan_is_current_change_type_name_idx"
  add_index "eu_73_listing_changes_mview", ["listed_geo_entities_ids"], :name => "tmp_cascaded_eu_73_listing_changes__listed_geo_entities_ids_idx"
  add_index "eu_73_listing_changes_mview", ["original_taxon_concept_id"], :name => "tmp_cascaded_eu_73_listing_change_original_taxon_concept_id_idx"
  add_index "eu_73_listing_changes_mview", ["show_in_downloads", "taxon_concept_id"], :name => "tmp_cascaded_eu_73_listing_ch_show_in_downloads_taxon_conce_idx"
  add_index "eu_73_listing_changes_mview", ["show_in_timeline", "taxon_concept_id"], :name => "tmp_cascaded_eu_73_listing_ch_show_in_timeline_taxon_concep_idx"
  add_index "eu_73_listing_changes_mview", ["taxon_concept_id", "original_taxon_concept_id", "change_type_id", "effective_at"], :name => "tmp_cascaded_eu_73_listing_ch_taxon_concept_id_original_tax_idx"

  create_table "eu_74_listing_changes_mview", :id => false, :force => true do |t|
    t.integer  "taxon_concept_id"
    t.integer  "id"
    t.integer  "original_taxon_concept_id"
    t.datetime "effective_at"
    t.integer  "species_listing_id"
    t.string   "species_listing_name"
    t.integer  "change_type_id"
    t.string   "change_type_name"
    t.integer  "designation_id"
    t.string   "designation_name"
    t.integer  "parent_id"
    t.integer  "party_id"
    t.string   "party_iso_code"
    t.string   "ann_symbol"
    t.text     "full_note_en"
    t.text     "full_note_es"
    t.text     "full_note_fr"
    t.text     "short_note_en"
    t.text     "short_note_es"
    t.text     "short_note_fr"
    t.boolean  "display_in_index"
    t.boolean  "display_in_footnote"
    t.string   "hash_ann_symbol"
    t.string   "hash_ann_parent_symbol"
    t.text     "hash_full_note_en"
    t.text     "hash_full_note_es"
    t.text     "hash_full_note_fr"
    t.integer  "inclusion_taxon_concept_id"
    t.text     "inherited_short_note_en"
    t.text     "inherited_full_note_en"
    t.text     "auto_note"
    t.boolean  "is_current"
    t.boolean  "explicit_change"
    t.datetime "updated_at"
    t.boolean  "show_in_history"
    t.boolean  "show_in_downloads"
    t.boolean  "show_in_timeline"
    t.string   "listed_geo_entities_ids",    :limit => nil
    t.string   "excluded_geo_entities_ids",  :limit => nil
    t.string   "excluded_taxon_concept_ids", :limit => nil
    t.boolean  "dirty"
    t.datetime "expiry"
  end

  add_index "eu_74_listing_changes_mview", ["excluded_geo_entities_ids"], :name => "tmp_cascaded_eu_74_listing_change_excluded_geo_entities_ids_idx"
  add_index "eu_74_listing_changes_mview", ["id", "taxon_concept_id"], :name => "tmp_cascaded_eu_74_listing_changes_mvie_id_taxon_concept_id_idx"
  add_index "eu_74_listing_changes_mview", ["inclusion_taxon_concept_id"], :name => "tmp_cascaded_eu_74_listing_chang_inclusion_taxon_concept_id_idx"
  add_index "eu_74_listing_changes_mview", ["is_current", "change_type_name"], :name => "tmp_cascaded_eu_74_listing_chan_is_current_change_type_name_idx"
  add_index "eu_74_listing_changes_mview", ["listed_geo_entities_ids"], :name => "tmp_cascaded_eu_74_listing_changes__listed_geo_entities_ids_idx"
  add_index "eu_74_listing_changes_mview", ["original_taxon_concept_id"], :name => "tmp_cascaded_eu_74_listing_change_original_taxon_concept_id_idx"
  add_index "eu_74_listing_changes_mview", ["show_in_downloads", "taxon_concept_id"], :name => "tmp_cascaded_eu_74_listing_ch_show_in_downloads_taxon_conce_idx"
  add_index "eu_74_listing_changes_mview", ["show_in_timeline", "taxon_concept_id"], :name => "tmp_cascaded_eu_74_listing_ch_show_in_timeline_taxon_concep_idx"
  add_index "eu_74_listing_changes_mview", ["taxon_concept_id", "original_taxon_concept_id", "change_type_id", "effective_at"], :name => "tmp_cascaded_eu_74_listing_ch_taxon_concept_id_original_tax_idx"

  create_table "eu_76_listing_changes_mview", :id => false, :force => true do |t|
    t.integer  "taxon_concept_id"
    t.integer  "id"
    t.integer  "original_taxon_concept_id"
    t.datetime "effective_at"
    t.integer  "species_listing_id"
    t.string   "species_listing_name"
    t.integer  "change_type_id"
    t.string   "change_type_name"
    t.integer  "designation_id"
    t.string   "designation_name"
    t.integer  "parent_id"
    t.integer  "party_id"
    t.string   "party_iso_code"
    t.string   "ann_symbol"
    t.text     "full_note_en"
    t.text     "full_note_es"
    t.text     "full_note_fr"
    t.text     "short_note_en"
    t.text     "short_note_es"
    t.text     "short_note_fr"
    t.boolean  "display_in_index"
    t.boolean  "display_in_footnote"
    t.string   "hash_ann_symbol"
    t.string   "hash_ann_parent_symbol"
    t.text     "hash_full_note_en"
    t.text     "hash_full_note_es"
    t.text     "hash_full_note_fr"
    t.integer  "inclusion_taxon_concept_id"
    t.text     "inherited_short_note_en"
    t.text     "inherited_full_note_en"
    t.text     "auto_note"
    t.boolean  "is_current"
    t.boolean  "explicit_change"
    t.datetime "updated_at"
    t.boolean  "show_in_history"
    t.boolean  "show_in_downloads"
    t.boolean  "show_in_timeline"
    t.string   "listed_geo_entities_ids",    :limit => nil
    t.string   "excluded_geo_entities_ids",  :limit => nil
    t.string   "excluded_taxon_concept_ids", :limit => nil
    t.boolean  "dirty"
    t.datetime "expiry"
  end

  add_index "eu_76_listing_changes_mview", ["excluded_geo_entities_ids"], :name => "tmp_cascaded_eu_76_listing_change_excluded_geo_entities_ids_idx"
  add_index "eu_76_listing_changes_mview", ["id", "taxon_concept_id"], :name => "tmp_cascaded_eu_76_listing_changes_mvie_id_taxon_concept_id_idx"
  add_index "eu_76_listing_changes_mview", ["inclusion_taxon_concept_id"], :name => "tmp_cascaded_eu_76_listing_chang_inclusion_taxon_concept_id_idx"
  add_index "eu_76_listing_changes_mview", ["is_current", "change_type_name"], :name => "tmp_cascaded_eu_76_listing_chan_is_current_change_type_name_idx"
  add_index "eu_76_listing_changes_mview", ["listed_geo_entities_ids"], :name => "tmp_cascaded_eu_76_listing_changes__listed_geo_entities_ids_idx"
  add_index "eu_76_listing_changes_mview", ["original_taxon_concept_id"], :name => "tmp_cascaded_eu_76_listing_change_original_taxon_concept_id_idx"
  add_index "eu_76_listing_changes_mview", ["show_in_downloads", "taxon_concept_id"], :name => "tmp_cascaded_eu_76_listing_ch_show_in_downloads_taxon_conce_idx"
  add_index "eu_76_listing_changes_mview", ["show_in_timeline", "taxon_concept_id"], :name => "tmp_cascaded_eu_76_listing_ch_show_in_timeline_taxon_concep_idx"
  add_index "eu_76_listing_changes_mview", ["taxon_concept_id", "original_taxon_concept_id", "change_type_id", "effective_at"], :name => "tmp_cascaded_eu_76_listing_ch_taxon_concept_id_original_tax_idx"

  create_table "eu_decision_confirmations", :force => true do |t|
    t.integer  "eu_decision_id"
    t.integer  "event_id"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  create_table "eu_decision_types", :force => true do |t|
    t.string   "name"
    t.string   "tooltip"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.string   "decision_type"
  end

  create_table "eu_decisions", :force => true do |t|
    t.boolean  "is_current",          :default => true
    t.text     "notes"
    t.text     "internal_notes"
    t.integer  "taxon_concept_id"
    t.integer  "geo_entity_id"
    t.datetime "start_date"
    t.integer  "start_event_id"
    t.datetime "end_date"
    t.integer  "end_event_id"
    t.string   "type"
    t.boolean  "conditions_apply"
    t.datetime "created_at",                            :null => false
    t.datetime "updated_at",                            :null => false
    t.integer  "eu_decision_type_id"
    t.integer  "term_id"
    t.integer  "source_id"
    t.integer  "created_by_id"
    t.integer  "updated_by_id"
  end

  create_table "eu_listing_changes_mview", :id => false, :force => true do |t|
    t.integer  "taxon_concept_id"
    t.integer  "id"
    t.integer  "original_taxon_concept_id"
    t.datetime "effective_at"
    t.integer  "species_listing_id"
    t.string   "species_listing_name"
    t.integer  "change_type_id"
    t.string   "change_type_name"
    t.integer  "designation_id"
    t.string   "designation_name"
    t.integer  "parent_id"
    t.integer  "party_id"
    t.string   "party_iso_code"
    t.string   "ann_symbol"
    t.text     "full_note_en"
    t.text     "full_note_es"
    t.text     "full_note_fr"
    t.text     "short_note_en"
    t.text     "short_note_es"
    t.text     "short_note_fr"
    t.boolean  "display_in_index"
    t.boolean  "display_in_footnote"
    t.string   "hash_ann_symbol"
    t.string   "hash_ann_parent_symbol"
    t.text     "hash_full_note_en"
    t.text     "hash_full_note_es"
    t.text     "hash_full_note_fr"
    t.integer  "inclusion_taxon_concept_id"
    t.text     "inherited_short_note_en"
    t.text     "inherited_full_note_en"
    t.text     "auto_note"
    t.boolean  "is_current"
    t.boolean  "explicit_change"
    t.datetime "updated_at"
    t.boolean  "show_in_history"
    t.boolean  "show_in_downloads"
    t.boolean  "show_in_timeline"
    t.string   "listed_geo_entities_ids",    :limit => nil
    t.string   "excluded_geo_entities_ids",  :limit => nil
    t.string   "excluded_taxon_concept_ids", :limit => nil
    t.boolean  "dirty"
    t.datetime "expiry"
  end

  add_index "eu_listing_changes_mview", ["excluded_geo_entities_ids"], :name => "tmp_cascaded_eu_listing_changes__excluded_geo_entities_ids_idx1"
  add_index "eu_listing_changes_mview", ["inclusion_taxon_concept_id"], :name => "tmp_cascaded_eu_listing_changes_inclusion_taxon_concept_id_idx1"
  add_index "eu_listing_changes_mview", ["is_current", "change_type_name"], :name => "tmp_cascaded_eu_listing_change_is_current_change_type_name_idx1"
  add_index "eu_listing_changes_mview", ["listed_geo_entities_ids"], :name => "tmp_cascaded_eu_listing_changes_mv_listed_geo_entities_ids_idx1"
  add_index "eu_listing_changes_mview", ["original_taxon_concept_id"], :name => "tmp_cascaded_eu_listing_changes__original_taxon_concept_id_idx1"
  add_index "eu_listing_changes_mview", ["show_in_downloads", "taxon_concept_id"], :name => "tmp_cascaded_eu_listing_chang_show_in_downloads_taxon_conc_idx1"
  add_index "eu_listing_changes_mview", ["show_in_timeline", "taxon_concept_id"], :name => "tmp_cascaded_eu_listing_chang_show_in_timeline_taxon_conce_idx1"
  add_index "eu_listing_changes_mview", ["taxon_concept_id", "original_taxon_concept_id", "change_type_id", "effective_at"], :name => "tmp_cascaded_eu_listing_chang_taxon_concept_id_original_ta_idx1"

  create_table "eu_species_listing_mview", :id => false, :force => true do |t|
    t.integer "id"
    t.string  "taxonomic_position"
    t.integer "kingdom_id"
    t.integer "phylum_id"
    t.integer "class_id"
    t.integer "order_id"
    t.integer "family_id"
    t.integer "genus_id"
    t.text    "kingdom_name"
    t.text    "phylum_name"
    t.text    "class_name"
    t.text    "order_name"
    t.text    "family_name"
    t.text    "genus_name"
    t.text    "species_name"
    t.text    "subspecies_name"
    t.string  "full_name"
    t.string  "author_year"
    t.text    "rank_name"
    t.boolean "eu_listed"
    t.text    "eu_listing_original"
    t.text    "cites_listing_original"
    t.text    "original_taxon_concept_party_iso_code"
    t.text    "original_taxon_concept_full_name_with_spp"
    t.text    "original_taxon_concept_full_note_en"
    t.text    "original_taxon_concept_hash_full_note_en"
    t.string  "countries_ids_ary",                         :limit => nil
    t.text    "all_distribution"
    t.text    "all_distribution_iso_codes"
    t.text    "native_distribution"
    t.text    "introduced_distribution"
    t.text    "introduced_uncertain_distribution"
    t.text    "reintroduced_distribution"
    t.text    "extinct_distribution"
    t.text    "extinct_uncertain_distribution"
    t.text    "uncertain_distribution"
  end

  add_index "eu_species_listing_mview", ["countries_ids_ary"], :name => "eu_species_listing_mview_tmp_countries_ids_ary_idx1"

  create_table "events", :force => true do |t|
    t.string   "name"
    t.integer  "designation_id"
    t.text     "description"
    t.text     "url"
    t.boolean  "is_current",     :default => false,   :null => false
    t.string   "type",           :default => "Event", :null => false
    t.datetime "effective_at"
    t.datetime "published_at"
    t.datetime "created_at",                          :null => false
    t.datetime "updated_at",                          :null => false
    t.integer  "legacy_id"
    t.datetime "end_date"
    t.string   "subtype"
    t.integer  "updated_by_id"
    t.integer  "created_by_id"
  end

  create_table "geo_entities", :force => true do |t|
    t.integer  "geo_entity_type_id",                   :null => false
    t.string   "name_en",                              :null => false
    t.string   "name_fr"
    t.string   "name_es"
    t.string   "long_name"
    t.string   "iso_code2"
    t.string   "iso_code3"
    t.integer  "legacy_id"
    t.string   "legacy_type"
    t.boolean  "is_current",         :default => true
    t.datetime "created_at",                           :null => false
    t.datetime "updated_at",                           :null => false
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

  create_table "impressions", :force => true do |t|
    t.string   "impressionable_type"
    t.integer  "impressionable_id"
    t.integer  "user_id"
    t.string   "controller_name"
    t.string   "action_name"
    t.string   "view_name"
    t.string   "request_hash"
    t.string   "ip_address"
    t.string   "session_hash"
    t.text     "message"
    t.text     "referrer"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
  end

  add_index "impressions", ["controller_name", "action_name", "ip_address"], :name => "controlleraction_ip_index"
  add_index "impressions", ["controller_name", "action_name", "request_hash"], :name => "controlleraction_request_index"
  add_index "impressions", ["controller_name", "action_name", "session_hash"], :name => "controlleraction_session_index"
  add_index "impressions", ["impressionable_type", "impressionable_id", "ip_address"], :name => "poly_ip_index"
  add_index "impressions", ["impressionable_type", "impressionable_id", "request_hash"], :name => "poly_request_index"
  add_index "impressions", ["impressionable_type", "impressionable_id", "session_hash"], :name => "poly_session_index"
  add_index "impressions", ["impressionable_type", "message", "impressionable_id"], :name => "impressionable_type_message_index"
  add_index "impressions", ["user_id"], :name => "index_impressions_on_user_id"

  create_table "instruments", :force => true do |t|
    t.integer  "designation_id"
    t.string   "name"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  create_table "iucn_mappings", :force => true do |t|
    t.integer  "taxon_concept_id"
    t.integer  "iucn_taxon_id"
    t.string   "iucn_taxon_name"
    t.string   "iucn_author"
    t.string   "iucn_category"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
    t.hstore   "details"
    t.integer  "accepted_name_id"
  end

  create_table "languages", :force => true do |t|
    t.string   "name_en",    :null => false
    t.string   "name_fr"
    t.string   "name_es"
    t.string   "iso_code1"
    t.string   "iso_code3",  :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "listing_changes", :force => true do |t|
    t.integer  "taxon_concept_id",                                              :null => false
    t.integer  "species_listing_id"
    t.integer  "change_type_id",                                                :null => false
    t.integer  "annotation_id"
    t.integer  "hash_annotation_id"
    t.datetime "effective_at",               :default => '2012-09-21 07:32:20', :null => false
    t.boolean  "is_current",                 :default => false,                 :null => false
    t.integer  "parent_id"
    t.integer  "inclusion_taxon_concept_id"
    t.integer  "event_id"
    t.integer  "original_id"
    t.boolean  "explicit_change",            :default => true
    t.datetime "created_at",                                                    :null => false
    t.datetime "updated_at",                                                    :null => false
    t.integer  "import_row_id"
    t.integer  "created_by_id"
    t.integer  "updated_by_id"
  end

  add_index "listing_changes", ["annotation_id"], :name => "index_listing_changes_on_annotation_id"
  add_index "listing_changes", ["event_id"], :name => "index_listing_changes_on_event_id"
  add_index "listing_changes", ["hash_annotation_id"], :name => "index_listing_changes_on_hash_annotation_id"
  add_index "listing_changes", ["inclusion_taxon_concept_id"], :name => "index_listing_changes_on_inclusion_taxon_concept_id"
  add_index "listing_changes", ["parent_id"], :name => "index_listing_changes_on_parent_id"
  add_index "listing_changes", ["taxon_concept_id"], :name => "index_listing_changes_on_taxon_concept_id"

  create_table "listing_changes_mview", :id => false, :force => true do |t|
    t.integer  "taxon_concept_id"
    t.integer  "id"
    t.integer  "original_taxon_concept_id"
    t.datetime "effective_at"
    t.integer  "species_listing_id"
    t.string   "species_listing_name"
    t.integer  "change_type_id"
    t.string   "change_type_name"
    t.integer  "designation_id"
    t.string   "designation_name"
    t.integer  "parent_id"
    t.integer  "party_id"
    t.string   "party_iso_code"
    t.string   "ann_symbol"
    t.text     "full_note_en"
    t.text     "full_note_es"
    t.text     "full_note_fr"
    t.text     "short_note_en"
    t.text     "short_note_es"
    t.text     "short_note_fr"
    t.boolean  "display_in_index"
    t.boolean  "display_in_footnote"
    t.string   "hash_ann_symbol"
    t.string   "hash_ann_parent_symbol"
    t.text     "hash_full_note_en"
    t.text     "hash_full_note_es"
    t.text     "hash_full_note_fr"
    t.integer  "inclusion_taxon_concept_id"
    t.text     "inherited_short_note_en"
    t.text     "inherited_full_note_en"
    t.text     "auto_note"
    t.boolean  "is_current"
    t.boolean  "explicit_change"
    t.string   "countries_ids_ary",          :limit => nil
    t.datetime "updated_at"
    t.boolean  "show_in_history"
    t.boolean  "show_in_downloads"
    t.boolean  "show_in_timeline"
    t.boolean  "dirty"
    t.datetime "expiry"
  end

  add_index "listing_changes_mview", ["id", "taxon_concept_id"], :name => "listing_changes_mview_tmp_id_taxon_concept_id_idx1"
  add_index "listing_changes_mview", ["inclusion_taxon_concept_id"], :name => "listing_changes_mview_tmp_inclusion_taxon_concept_id_idx1"
  add_index "listing_changes_mview", ["is_current", "designation_name", "change_type_name"], :name => "listing_changes_mview_tmp_is_current_designation_name_chan_idx1"
  add_index "listing_changes_mview", ["original_taxon_concept_id"], :name => "listing_changes_mview_tmp_original_taxon_concept_id_idx1"
  add_index "listing_changes_mview", ["show_in_downloads", "taxon_concept_id", "designation_id"], :name => "listing_changes_mview_tmp_show_in_downloads_taxon_concept__idx1"
  add_index "listing_changes_mview", ["show_in_timeline", "taxon_concept_id", "designation_id"], :name => "listing_changes_mview_tmp_show_in_timeline_taxon_concept_i_idx1"

  create_table "listing_distributions", :force => true do |t|
    t.integer  "listing_change_id",                   :null => false
    t.integer  "geo_entity_id",                       :null => false
    t.boolean  "is_party",          :default => true, :null => false
    t.integer  "original_id"
    t.datetime "created_at",                          :null => false
    t.datetime "updated_at",                          :null => false
    t.integer  "created_by_id"
    t.integer  "updated_by_id"
  end

  add_index "listing_distributions", ["geo_entity_id"], :name => "index_listing_distributions_on_geo_entity_id"
  add_index "listing_distributions", ["listing_change_id"], :name => "index_listing_distributions_on_listing_change_id"

  create_table "preset_tags", :force => true do |t|
    t.string   "name"
    t.string   "model"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "ranks", :force => true do |t|
    t.string   "name",                                  :null => false
    t.string   "taxonomic_position", :default => "0",   :null => false
    t.boolean  "fixed_order",        :default => false, :null => false
    t.datetime "created_at",                            :null => false
    t.datetime "updated_at",                            :null => false
  end

  create_table "references", :force => true do |t|
    t.text     "title"
    t.string   "year"
    t.string   "author"
    t.text     "citation",      :null => false
    t.text     "publisher"
    t.integer  "legacy_id"
    t.string   "legacy_type"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.integer  "updated_by_id"
    t.integer  "created_by_id"
  end

  create_table "references_legacy_id_mapping", :force => true do |t|
    t.integer "legacy_id",       :null => false
    t.text    "legacy_type",     :null => false
    t.integer "alias_legacy_id", :null => false
  end

  create_table "species_listings", :force => true do |t|
    t.integer  "designation_id", :null => false
    t.string   "name",           :null => false
    t.string   "abbreviation"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
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
    t.integer  "taxon_concept_id", :null => false
    t.integer  "common_name_id",   :null => false
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
    t.integer  "created_by_id"
    t.integer  "updated_by_id"
  end

  create_table "taxon_concept_references", :force => true do |t|
    t.integer  "taxon_concept_id",                                              :null => false
    t.integer  "reference_id",                                                  :null => false
    t.boolean  "is_standard",                                :default => false, :null => false
    t.boolean  "is_cascaded",                                :default => false, :null => false
    t.datetime "created_at",                                                    :null => false
    t.datetime "updated_at",                                                    :null => false
    t.string   "excluded_taxon_concepts_ids", :limit => nil
    t.integer  "created_by_id"
    t.integer  "updated_by_id"
  end

  add_index "taxon_concept_references", ["taxon_concept_id", "reference_id"], :name => "index_taxon_concept_references_on_taxon_concept_id_and_ref_id"

  create_table "taxon_concepts", :force => true do |t|
    t.integer  "taxonomy_id",           :default => 1,   :null => false
    t.integer  "parent_id"
    t.integer  "rank_id",                                :null => false
    t.integer  "taxon_name_id",                          :null => false
    t.string   "author_year"
    t.integer  "legacy_id"
    t.string   "legacy_type"
    t.hstore   "data"
    t.hstore   "listing"
    t.text     "notes"
    t.string   "taxonomic_position",    :default => "0", :null => false
    t.string   "full_name"
    t.string   "name_status",           :default => "A", :null => false
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
    t.datetime "touched_at"
    t.string   "legacy_trade_code"
    t.integer  "updated_by_id"
    t.integer  "created_by_id"
    t.datetime "dependents_updated_at"
  end

  add_index "taxon_concepts", ["legacy_trade_code"], :name => "index_taxon_concepts_on_legacy_trade_code"
  add_index "taxon_concepts", ["name_status"], :name => "index_taxon_concepts_on_name_status"
  add_index "taxon_concepts", ["parent_id"], :name => "index_taxon_concepts_on_parent_id"
  add_index "taxon_concepts", ["taxonomy_id"], :name => "index_taxon_concepts_on_taxonomy_id"

  create_table "taxon_concepts_and_terms_pairs_import", :id => false, :force => true do |t|
    t.string "rank",         :limit => nil
    t.string "taxon_family", :limit => nil
    t.string "term_code",    :limit => nil
  end

  create_table "taxon_concepts_mview", :id => false, :force => true do |t|
    t.integer  "id"
    t.integer  "parent_id"
    t.integer  "taxonomy_id"
    t.boolean  "taxonomy_is_cites_eu"
    t.string   "full_name"
    t.string   "name_status"
    t.text     "rank_name"
    t.boolean  "spp"
    t.boolean  "cites_accepted"
    t.integer  "kingdom_position"
    t.string   "taxonomic_position"
    t.text     "kingdom_name"
    t.text     "phylum_name"
    t.text     "class_name"
    t.text     "order_name"
    t.text     "family_name"
    t.text     "subfamily_name"
    t.text     "genus_name"
    t.text     "species_name"
    t.text     "subspecies_name"
    t.integer  "kingdom_id"
    t.integer  "phylum_id"
    t.integer  "class_id"
    t.integer  "order_id"
    t.integer  "family_id"
    t.integer  "subfamily_id"
    t.integer  "genus_id"
    t.integer  "species_id"
    t.integer  "subspecies_id"
    t.boolean  "cites_i"
    t.boolean  "cites_ii"
    t.boolean  "cites_iii"
    t.boolean  "cites_listed"
    t.boolean  "cites_listed_descendants"
    t.boolean  "cites_show"
    t.text     "cites_status"
    t.text     "cites_listing_original"
    t.text     "cites_listing"
    t.datetime "cites_listing_updated_at"
    t.text     "ann_symbol"
    t.text     "hash_ann_symbol"
    t.text     "hash_ann_parent_symbol"
    t.boolean  "eu_listed"
    t.boolean  "eu_show"
    t.text     "eu_status"
    t.text     "eu_listing_original"
    t.text     "eu_listing"
    t.datetime "eu_listing_updated_at"
    t.boolean  "cms_listed"
    t.boolean  "cms_show"
    t.text     "cms_status"
    t.text     "cms_listing_original"
    t.text     "cms_listing"
    t.datetime "cms_listing_updated_at"
    t.string   "species_listings_ids",                  :limit => nil
    t.string   "species_listings_ids_aggregated",       :limit => nil
    t.string   "author_year"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "taxon_concept_id_com"
    t.string   "english_names_ary",                     :limit => nil
    t.string   "spanish_names_ary",                     :limit => nil
    t.string   "french_names_ary",                      :limit => nil
    t.integer  "taxon_concept_id_syn"
    t.string   "synonyms_ary",                          :limit => nil
    t.string   "synonyms_author_years_ary",             :limit => nil
    t.string   "subspecies_not_listed_ary",             :limit => nil
    t.string   "countries_ids_ary",                     :limit => nil
    t.string   "all_distribution_ary",                  :limit => nil
    t.string   "all_distribution_iso_codes_ary",        :limit => nil
    t.string   "native_distribution_ary",               :limit => nil
    t.string   "introduced_distribution_ary",           :limit => nil
    t.string   "introduced_uncertain_distribution_ary", :limit => nil
    t.string   "reintroduced_distribution_ary",         :limit => nil
    t.string   "extinct_distribution_ary",              :limit => nil
    t.string   "extinct_uncertain_distribution_ary",    :limit => nil
    t.string   "uncertain_distribution_ary",            :limit => nil
    t.boolean  "show_in_species_plus"
    t.boolean  "dirty"
    t.datetime "expiry"
  end

  add_index "taxon_concepts_mview", ["cites_show", "name_status", "cites_listing_original", "taxonomy_is_cites_eu", "rank_name"], :name => "taxon_concepts_mview_tmp_cites_show_name_status_cites_listi_idx"
  add_index "taxon_concepts_mview", ["cms_show", "name_status", "cms_listing_original", "taxonomy_is_cites_eu", "rank_name"], :name => "taxon_concepts_mview_tmp_cms_show_name_status_cms_listing_o_idx"
  add_index "taxon_concepts_mview", ["countries_ids_ary"], :name => "taxon_concepts_mview_tmp_countries_ids_ary_idx1"
  add_index "taxon_concepts_mview", ["eu_show", "name_status", "eu_listing_original", "taxonomy_is_cites_eu", "rank_name"], :name => "taxon_concepts_mview_tmp_eu_show_name_status_eu_listing_ori_idx"
  add_index "taxon_concepts_mview", ["id"], :name => "taxon_concepts_mview_tmp_id_idx"
  add_index "taxon_concepts_mview", ["parent_id"], :name => "taxon_concepts_mview_tmp_parent_id_idx"
  add_index "taxon_concepts_mview", ["taxonomy_is_cites_eu", "cites_listed", "kingdom_position"], :name => "taxon_concepts_mview_tmp_taxonomy_is_cites_eu_cites_listed__idx"

  create_table "taxon_instruments", :force => true do |t|
    t.integer  "taxon_concept_id"
    t.integer  "instrument_id"
    t.datetime "effective_from"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
    t.integer  "created_by_id"
    t.integer  "updated_by_id"
  end

  add_index "taxon_instruments", ["taxon_concept_id"], :name => "index_taxon_instruments_on_taxon_concept_id"

  create_table "taxon_names", :force => true do |t|
    t.string   "scientific_name", :null => false
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  create_table "taxon_relationship_types", :force => true do |t|
    t.string   "name",                                 :null => false
    t.boolean  "is_intertaxonomic", :default => false, :null => false
    t.boolean  "is_bidirectional",  :default => false, :null => false
    t.datetime "created_at",                           :null => false
    t.datetime "updated_at",                           :null => false
  end

  create_table "taxon_relationships", :force => true do |t|
    t.integer  "taxon_concept_id",           :null => false
    t.integer  "other_taxon_concept_id",     :null => false
    t.integer  "taxon_relationship_type_id", :null => false
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
    t.integer  "created_by_id"
    t.integer  "updated_by_id"
  end

  create_table "taxonomies", :force => true do |t|
    t.string   "name",       :default => "DEAFAULT TAXONOMY", :null => false
    t.datetime "created_at",                                  :null => false
    t.datetime "updated_at",                                  :null => false
  end

  create_table "term_trade_codes_pairs", :force => true do |t|
    t.integer  "term_id",         :null => false
    t.integer  "trade_code_id"
    t.string   "trade_code_type"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  add_index "term_trade_codes_pairs", ["term_id", "trade_code_id", "trade_code_type"], :name => "index_term_trade_codes_pairs_on_term_and_trade_code", :unique => true

  create_table "terms_and_purpose_pairs_import", :id => false, :force => true do |t|
    t.string "term_code",    :limit => nil
    t.string "purpose_code", :limit => nil
  end

  create_table "terms_and_unit_pairs_import", :id => false, :force => true do |t|
    t.string "term_code", :limit => nil
    t.string "unit_code", :limit => nil
  end

  create_table "trade_annual_report_uploads", :force => true do |t|
    t.integer  "created_by"
    t.integer  "updated_by"
    t.datetime "created_at",                            :null => false
    t.datetime "updated_at",                            :null => false
    t.boolean  "is_done",            :default => false
    t.integer  "number_of_rows"
    t.text     "csv_source_file"
    t.integer  "trading_country_id",                    :null => false
    t.string   "point_of_view",      :default => "E",   :null => false
    t.integer  "created_by_id"
    t.integer  "updated_by_id"
  end

  create_table "trade_codes", :force => true do |t|
    t.string   "code",       :null => false
    t.string   "type",       :null => false
    t.string   "name_en",    :null => false
    t.string   "name_es"
    t.string   "name_fr"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "trade_permits", :force => true do |t|
    t.string   "number",     :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "trade_permits", ["number"], :name => "trade_permits_number_idx", :unique => true

  create_table "trade_restriction_purposes", :force => true do |t|
    t.integer  "trade_restriction_id"
    t.integer  "purpose_id"
    t.datetime "created_at",           :null => false
    t.datetime "updated_at",           :null => false
    t.integer  "created_by_id"
    t.integer  "updated_by_id"
  end

  create_table "trade_restriction_sources", :force => true do |t|
    t.integer  "trade_restriction_id"
    t.integer  "source_id"
    t.datetime "created_at",           :null => false
    t.datetime "updated_at",           :null => false
    t.integer  "created_by_id"
    t.integer  "updated_by_id"
  end

  create_table "trade_restriction_terms", :force => true do |t|
    t.integer  "trade_restriction_id"
    t.integer  "term_id"
    t.datetime "created_at",           :null => false
    t.datetime "updated_at",           :null => false
    t.integer  "created_by_id"
    t.integer  "updated_by_id"
  end

  create_table "trade_restrictions", :force => true do |t|
    t.boolean  "is_current",                                 :default => true
    t.datetime "start_date"
    t.datetime "end_date"
    t.integer  "geo_entity_id"
    t.float    "quota"
    t.datetime "publication_date"
    t.text     "notes"
    t.string   "type"
    t.integer  "unit_id"
    t.integer  "taxon_concept_id"
    t.boolean  "public_display",                             :default => true
    t.text     "url"
    t.datetime "created_at",                                                   :null => false
    t.datetime "updated_at",                                                   :null => false
    t.integer  "start_notification_id"
    t.integer  "end_notification_id"
    t.string   "excluded_taxon_concepts_ids", :limit => nil
    t.integer  "original_id"
    t.integer  "updated_by_id"
    t.integer  "created_by_id"
  end

  create_table "trade_sandbox_template", :force => true do |t|
    t.string  "appendix"
    t.string  "taxon_name"
    t.string  "term_code"
    t.string  "quantity"
    t.string  "unit_code"
    t.string  "trading_partner"
    t.string  "country_of_origin"
    t.string  "export_permit"
    t.string  "origin_permit"
    t.string  "purpose_code"
    t.string  "source_code"
    t.string  "year"
    t.string  "import_permit"
    t.integer "reported_taxon_concept_id"
    t.integer "taxon_concept_id"
  end

  create_table "trade_shipments", :force => true do |t|
    t.integer  "source_id"
    t.integer  "unit_id"
    t.integer  "purpose_id"
    t.integer  "term_id",                                                        :null => false
    t.decimal  "quantity",                                                       :null => false
    t.string   "appendix",                                                       :null => false
    t.integer  "trade_annual_report_upload_id"
    t.integer  "exporter_id",                                                    :null => false
    t.integer  "importer_id",                                                    :null => false
    t.integer  "country_of_origin_id"
    t.boolean  "reported_by_exporter",                         :default => true, :null => false
    t.integer  "taxon_concept_id",                                               :null => false
    t.integer  "year",                                                           :null => false
    t.datetime "created_at",                                                     :null => false
    t.datetime "updated_at",                                                     :null => false
    t.integer  "sandbox_id"
    t.integer  "reported_taxon_concept_id"
    t.string   "import_permit_number"
    t.string   "export_permit_number"
    t.string   "origin_permit_number"
    t.integer  "legacy_shipment_number"
    t.string   "import_permits_ids",            :limit => nil
    t.string   "export_permits_ids",            :limit => nil
    t.string   "origin_permits_ids",            :limit => nil
    t.integer  "updated_by_id"
    t.integer  "created_by_id"
  end

  add_index "trade_shipments", ["appendix"], :name => "index_trade_shipments_on_appendix"
  add_index "trade_shipments", ["country_of_origin_id"], :name => "index_trade_shipments_on_country_of_origin_id"
  add_index "trade_shipments", ["export_permits_ids"], :name => "index_trade_shipments_on_export_permits_ids"
  add_index "trade_shipments", ["exporter_id"], :name => "index_trade_shipments_on_exporter_id"
  add_index "trade_shipments", ["import_permits_ids"], :name => "index_trade_shipments_on_import_permits_ids"
  add_index "trade_shipments", ["importer_id"], :name => "index_trade_shipments_on_importer_id"
  add_index "trade_shipments", ["origin_permits_ids"], :name => "index_trade_shipments_on_origin_permits_ids"
  add_index "trade_shipments", ["purpose_id"], :name => "index_trade_shipments_on_purpose_id"
  add_index "trade_shipments", ["quantity"], :name => "index_trade_shipments_on_quantity"
  add_index "trade_shipments", ["reported_taxon_concept_id"], :name => "index_trade_shipments_on_reported_taxon_concept_id"
  add_index "trade_shipments", ["sandbox_id"], :name => "index_trade_shipments_on_sandbox_id"
  add_index "trade_shipments", ["source_id"], :name => "index_trade_shipments_on_source_id"
  add_index "trade_shipments", ["taxon_concept_id"], :name => "index_trade_shipments_on_taxon_concept_id"
  add_index "trade_shipments", ["term_id"], :name => "index_trade_shipments_on_term_id"
  add_index "trade_shipments", ["unit_id"], :name => "index_trade_shipments_on_unit_id"
  add_index "trade_shipments", ["year", "exporter_id"], :name => "index_trade_shipments_on_year_exporter_id"
  add_index "trade_shipments", ["year", "importer_id"], :name => "index_trade_shipments_on_year_importer_id"
  add_index "trade_shipments", ["year"], :name => "index_trade_shipments_on_year"

  create_table "trade_taxon_concept_term_pairs", :force => true do |t|
    t.integer  "taxon_concept_id"
    t.integer  "term_id"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  create_table "trade_trade_data_downloads", :force => true do |t|
    t.string   "user_ip"
    t.string   "report_type"
    t.integer  "year_from"
    t.integer  "year_to"
    t.string   "taxon"
    t.string   "appendix"
    t.string   "importer"
    t.string   "exporter"
    t.string   "origin"
    t.string   "term"
    t.string   "unit"
    t.string   "source"
    t.string   "purpose"
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
    t.integer  "number_of_rows"
    t.string   "city",           :limit => nil
    t.string   "country",        :limit => nil
    t.string   "organization",   :limit => nil
  end

  create_table "trade_validation_rules", :force => true do |t|
    t.string   "valid_values_view"
    t.string   "type",                                 :null => false
    t.datetime "created_at",                           :null => false
    t.datetime "updated_at",                           :null => false
    t.string   "format_re"
    t.integer  "run_order",                            :null => false
    t.string   "column_names"
    t.boolean  "is_primary",        :default => true,  :null => false
    t.hstore   "scope"
    t.boolean  "is_strict",         :default => false, :null => false
  end

  create_table "users", :force => true do |t|
    t.string   "name",                                      :null => false
    t.datetime "created_at",                                :null => false
    t.datetime "updated_at",                                :null => false
    t.string   "email",                  :default => "",    :null => false
    t.string   "encrypted_password",     :default => "",    :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0,     :null => false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.boolean  "is_manager",             :default => false, :null => false
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

  create_table "valid_taxon_concept_annex_year_mview", :id => false, :force => true do |t|
    t.integer  "taxon_concept_id"
    t.string   "annex"
    t.datetime "effective_from"
    t.datetime "effective_to"
  end

  add_index "valid_taxon_concept_annex_year_mview", ["taxon_concept_id", "effective_from", "effective_to", "annex"], :name => "valid_taxon_concept_annex_year_mview_idx"

  create_table "valid_taxon_concept_appendix_year_mview", :id => false, :force => true do |t|
    t.integer  "taxon_concept_id"
    t.string   "appendix"
    t.datetime "effective_from"
    t.datetime "effective_to"
  end

  add_index "valid_taxon_concept_appendix_year_mview", ["taxon_concept_id", "appendix", "effective_from", "effective_to"], :name => "tmp_valid_taxon_concept_appen_taxon_concept_id_appendix_eff_idx"
  add_index "valid_taxon_concept_appendix_year_mview", ["taxon_concept_id", "appendix"], :name => "valid_taxon_concept_appendix_year_mview_year_idx"
  add_index "valid_taxon_concept_appendix_year_mview", ["taxon_concept_id", "effective_from", "effective_to", "appendix"], :name => "valid_taxon_concept_appendix_year_mview_idx"

  create_table "visits", :id => false, :force => true do |t|
    t.uuid     "id"
    t.uuid     "visitor_id"
    t.string   "ip"
    t.text     "user_agent"
    t.text     "referrer"
    t.text     "landing_page"
    t.integer  "user_id"
    t.string   "referring_domain"
    t.string   "search_keyword"
    t.string   "browser"
    t.string   "os"
    t.string   "device_type"
    t.string   "country"
    t.string   "region"
    t.string   "city"
    t.string   "utm_source"
    t.string   "utm_medium"
    t.string   "utm_term"
    t.string   "utm_content"
    t.string   "utm_campaign"
    t.datetime "started_at"
  end

  add_index "visits", ["user_id"], :name => "index_visits_on_user_id"

  add_foreign_key "ahoy_events", "users", name: "ahoy_events_user_id_fk"

  add_foreign_key "ahoy_visits", "users", name: "ahoy_visits_user_id_fk"

  add_foreign_key "annotations", "annotations", name: "annotations_source_id_fk", column: "original_id"
  add_foreign_key "annotations", "events", name: "annotations_event_id_fk"
  add_foreign_key "annotations", "users", name: "annotations_created_by_id_fk", column: "created_by_id"
  add_foreign_key "annotations", "users", name: "annotations_updated_by_id_fk", column: "updated_by_id"

  add_foreign_key "change_types", "designations", name: "change_types_designation_id_fk"

  add_foreign_key "cites_suspension_confirmations", "events", name: "cites_suspension_confirmations_notification_id_fk", column: "cites_suspension_notification_id"
  add_foreign_key "cites_suspension_confirmations", "trade_restrictions", name: "cites_suspension_confirmations_cites_suspension_id_fk", column: "cites_suspension_id"

  add_foreign_key "common_names", "languages", name: "common_names_language_id_fk"
  add_foreign_key "common_names", "users", name: "common_names_created_by_id_fk", column: "created_by_id"
  add_foreign_key "common_names", "users", name: "common_names_updated_by_id_fk", column: "updated_by_id"

  add_foreign_key "designation_geo_entities", "designations", name: "designation_geo_entities_designation_id_fk"
  add_foreign_key "designation_geo_entities", "geo_entities", name: "designation_geo_entities_geo_entity_id_fk"

  add_foreign_key "designations", "taxonomies", name: "designations_taxonomy_id_fk"

  add_foreign_key "distribution_references", "distributions", name: "taxon_concept_geo_entity_references_taxon_concept_geo_entity_fk"
  add_foreign_key "distribution_references", "references", name: "taxon_concept_geo_entity_references_reference_id_fk"
  add_foreign_key "distribution_references", "users", name: "distribution_references_created_by_id_fk", column: "created_by_id"
  add_foreign_key "distribution_references", "users", name: "distribution_references_updated_by_id_fk", column: "updated_by_id"

  add_foreign_key "distributions", "geo_entities", name: "taxon_concept_geo_entities_geo_entity_id_fk"
  add_foreign_key "distributions", "taxon_concepts", name: "taxon_concept_geo_entities_taxon_concept_id_fk"
  add_foreign_key "distributions", "users", name: "distributions_created_by_id_fk", column: "created_by_id"
  add_foreign_key "distributions", "users", name: "distributions_updated_by_id_fk", column: "updated_by_id"

  add_foreign_key "eu_decision_confirmations", "eu_decisions", name: "eu_decision_confirmations_eu_decision_id_fk"
  add_foreign_key "eu_decision_confirmations", "events", name: "eu_decision_confirmations_event_id_fk"

  add_foreign_key "eu_decisions", "eu_decision_types", name: "eu_decisions_eu_decision_type_id_fk"
  add_foreign_key "eu_decisions", "events", name: "eu_decisions_end_event_id_fk", column: "end_event_id"
  add_foreign_key "eu_decisions", "events", name: "eu_decisions_start_event_id_fk", column: "start_event_id"
  add_foreign_key "eu_decisions", "geo_entities", name: "eu_decisions_geo_entity_id_fk"
  add_foreign_key "eu_decisions", "taxon_concepts", name: "eu_decisions_taxon_concept_id_fk"
  add_foreign_key "eu_decisions", "trade_codes", name: "eu_decisions_source_id_fk", column: "source_id"
  add_foreign_key "eu_decisions", "trade_codes", name: "eu_decisions_term_id_fk", column: "term_id"
  add_foreign_key "eu_decisions", "users", name: "eu_decisions_created_by_id_fk", column: "created_by_id"
  add_foreign_key "eu_decisions", "users", name: "eu_decisions_updated_by_id_fk", column: "updated_by_id"

  add_foreign_key "events", "designations", name: "events_designation_id_fk"
  add_foreign_key "events", "users", name: "events_created_by_id_fk", column: "created_by_id"
  add_foreign_key "events", "users", name: "events_updated_by_id_fk", column: "updated_by_id"

  add_foreign_key "geo_entities", "geo_entity_types", name: "geo_entities_geo_entity_type_id_fk"

  add_foreign_key "geo_relationships", "geo_entities", name: "geo_relationships_geo_entity_id_fk"
  add_foreign_key "geo_relationships", "geo_entities", name: "geo_relationships_other_geo_entity_id_fk", column: "other_geo_entity_id"
  add_foreign_key "geo_relationships", "geo_relationship_types", name: "geo_relationships_geo_relationship_type_id_fk"

  add_foreign_key "instruments", "designations", name: "instruments_designation_id_fk"

  add_foreign_key "listing_changes", "annotations", name: "listing_changes_annotation_id_fk"
  add_foreign_key "listing_changes", "annotations", name: "listing_changes_hash_annotation_id_fk", column: "hash_annotation_id"
  add_foreign_key "listing_changes", "change_types", name: "listing_changes_change_type_id_fk"
  add_foreign_key "listing_changes", "events", name: "listing_changes_event_id_fk"
  add_foreign_key "listing_changes", "listing_changes", name: "listing_changes_parent_id_fk", column: "parent_id"
  add_foreign_key "listing_changes", "listing_changes", name: "listing_changes_source_id_fk", column: "original_id"
  add_foreign_key "listing_changes", "species_listings", name: "listing_changes_species_listing_id_fk"
  add_foreign_key "listing_changes", "taxon_concepts", name: "listing_changes_inclusion_taxon_concept_id_fk", column: "inclusion_taxon_concept_id"
  add_foreign_key "listing_changes", "taxon_concepts", name: "listing_changes_taxon_concept_id_fk"
  add_foreign_key "listing_changes", "users", name: "listing_changes_created_by_id_fk", column: "created_by_id"
  add_foreign_key "listing_changes", "users", name: "listing_changes_updated_by_id_fk", column: "updated_by_id"

  add_foreign_key "listing_distributions", "geo_entities", name: "listing_distributions_geo_entity_id_fk"
  add_foreign_key "listing_distributions", "listing_changes", name: "listing_distributions_listing_change_id_fk"
  add_foreign_key "listing_distributions", "listing_distributions", name: "listing_distributions_source_id_fk", column: "original_id"
  add_foreign_key "listing_distributions", "users", name: "listing_distributions_created_by_id_fk", column: "created_by_id"
  add_foreign_key "listing_distributions", "users", name: "listing_distributions_updated_by_id_fk", column: "updated_by_id"

  add_foreign_key "references", "users", name: "references_created_by_id_fk", column: "created_by_id"
  add_foreign_key "references", "users", name: "references_updated_by_id_fk", column: "updated_by_id"

  add_foreign_key "species_listings", "designations", name: "species_listings_designation_id_fk"

  add_foreign_key "taxon_commons", "common_names", name: "taxon_commons_common_name_id_fk"
  add_foreign_key "taxon_commons", "taxon_concepts", name: "taxon_commons_taxon_concept_id_fk"
  add_foreign_key "taxon_commons", "users", name: "taxon_commons_created_by_id_fk", column: "created_by_id"
  add_foreign_key "taxon_commons", "users", name: "taxon_commons_updated_by_id_fk", column: "updated_by_id"

  add_foreign_key "taxon_concept_references", "references", name: "taxon_concept_references_reference_id_fk"
  add_foreign_key "taxon_concept_references", "taxon_concepts", name: "taxon_concept_references_taxon_concept_id_fk"
  add_foreign_key "taxon_concept_references", "users", name: "taxon_concept_references_created_by_id_fk", column: "created_by_id"
  add_foreign_key "taxon_concept_references", "users", name: "taxon_concept_references_updated_by_id_fk", column: "updated_by_id"

  add_foreign_key "taxon_concepts", "ranks", name: "taxon_concepts_rank_id_fk"
  add_foreign_key "taxon_concepts", "taxon_concepts", name: "taxon_concepts_parent_id_fk", column: "parent_id"
  add_foreign_key "taxon_concepts", "taxon_names", name: "taxon_concepts_taxon_name_id_fk"
  add_foreign_key "taxon_concepts", "taxonomies", name: "taxon_concepts_taxonomy_id_fk"
  add_foreign_key "taxon_concepts", "users", name: "taxon_concepts_created_by_id_fk", column: "created_by_id"
  add_foreign_key "taxon_concepts", "users", name: "taxon_concepts_updated_by_id_fk", column: "updated_by_id"

  add_foreign_key "taxon_instruments", "instruments", name: "taxon_instruments_instrument_id_fk"
  add_foreign_key "taxon_instruments", "taxon_concepts", name: "taxon_instruments_taxon_concept_id_fk"
  add_foreign_key "taxon_instruments", "users", name: "taxon_instruments_created_by_id_fk", column: "created_by_id"
  add_foreign_key "taxon_instruments", "users", name: "taxon_instruments_updated_by_id_fk", column: "updated_by_id"

  add_foreign_key "taxon_relationships", "taxon_concepts", name: "taxon_relationships_taxon_concept_id_fk"
  add_foreign_key "taxon_relationships", "taxon_relationship_types", name: "taxon_relationships_taxon_relationship_type_id_fk"
  add_foreign_key "taxon_relationships", "users", name: "taxon_relationships_created_by_id_fk", column: "created_by_id"
  add_foreign_key "taxon_relationships", "users", name: "taxon_relationships_updated_by_id_fk", column: "updated_by_id"

  add_foreign_key "term_trade_codes_pairs", "trade_codes", name: "term_trade_codes_pairs_term_id_fk", column: "term_id"
  add_foreign_key "term_trade_codes_pairs", "trade_codes", name: "term_trade_codes_pairs_trade_code_id_fk"

  add_foreign_key "trade_annual_report_uploads", "geo_entities", name: "trade_annual_report_uploads_trading_country_id_fk", column: "trading_country_id"
  add_foreign_key "trade_annual_report_uploads", "users", name: "trade_annual_report_uploads_created_by_fk", column: "created_by"
  add_foreign_key "trade_annual_report_uploads", "users", name: "trade_annual_report_uploads_created_by_id_fk", column: "created_by_id"
  add_foreign_key "trade_annual_report_uploads", "users", name: "trade_annual_report_uploads_updated_by_fk", column: "updated_by"
  add_foreign_key "trade_annual_report_uploads", "users", name: "trade_annual_report_uploads_updated_by_id_fk", column: "updated_by_id"

  add_foreign_key "trade_restriction_purposes", "trade_codes", name: "trade_restriction_purposes_purpose_id", column: "purpose_id"
  add_foreign_key "trade_restriction_purposes", "trade_restrictions", name: "trade_restriction_purposes_trade_restriction_id"
  add_foreign_key "trade_restriction_purposes", "users", name: "trade_restriction_purposes_created_by_id_fk", column: "created_by_id"
  add_foreign_key "trade_restriction_purposes", "users", name: "trade_restriction_purposes_updated_by_id_fk", column: "updated_by_id"

  add_foreign_key "trade_restriction_sources", "trade_codes", name: "trade_restriction_sources_source_id", column: "source_id"
  add_foreign_key "trade_restriction_sources", "trade_restrictions", name: "trade_restriction_sources_trade_restriction_id"
  add_foreign_key "trade_restriction_sources", "users", name: "trade_restriction_sources_created_by_id_fk", column: "created_by_id"
  add_foreign_key "trade_restriction_sources", "users", name: "trade_restriction_sources_updated_by_id_fk", column: "updated_by_id"

  add_foreign_key "trade_restriction_terms", "trade_codes", name: "trade_restriction_terms_term_id", column: "term_id"
  add_foreign_key "trade_restriction_terms", "trade_restrictions", name: "trade_restriction_terms_trade_restriction_id"
  add_foreign_key "trade_restriction_terms", "users", name: "trade_restriction_terms_created_by_id_fk", column: "created_by_id"
  add_foreign_key "trade_restriction_terms", "users", name: "trade_restriction_terms_updated_by_id_fk", column: "updated_by_id"

  add_foreign_key "trade_restrictions", "events", name: "trade_restrictions_end_notification_id_fk", column: "end_notification_id"
  add_foreign_key "trade_restrictions", "events", name: "trade_restrictions_start_notification_id_fk", column: "start_notification_id"
  add_foreign_key "trade_restrictions", "geo_entities", name: "trade_restrictions_geo_entity_id_fk"
  add_foreign_key "trade_restrictions", "taxon_concepts", name: "trade_restrictions_taxon_concept_id_fk"
  add_foreign_key "trade_restrictions", "trade_codes", name: "trade_restrictions_unit_id_fk", column: "unit_id"
  add_foreign_key "trade_restrictions", "users", name: "trade_restrictions_created_by_id_fk", column: "created_by_id"
  add_foreign_key "trade_restrictions", "users", name: "trade_restrictions_updated_by_id_fk", column: "updated_by_id"

  add_foreign_key "trade_shipments", "geo_entities", name: "trade_shipments_country_of_origin_id_fk", column: "country_of_origin_id"
  add_foreign_key "trade_shipments", "geo_entities", name: "trade_shipments_exporter_id_fk", column: "exporter_id"
  add_foreign_key "trade_shipments", "geo_entities", name: "trade_shipments_importer_id_fk", column: "importer_id"
  add_foreign_key "trade_shipments", "taxon_concepts", name: "trade_shipments_reported_taxon_concept_id_fk", column: "reported_taxon_concept_id"
  add_foreign_key "trade_shipments", "taxon_concepts", name: "trade_shipments_taxon_concept_id_fk"
  add_foreign_key "trade_shipments", "trade_annual_report_uploads", name: "trade_shipments_trade_annual_report_upload_id_fk"
  add_foreign_key "trade_shipments", "trade_codes", name: "trade_shipments_purpose_id_fk", column: "purpose_id"
  add_foreign_key "trade_shipments", "trade_codes", name: "trade_shipments_source_id_fk", column: "source_id"
  add_foreign_key "trade_shipments", "trade_codes", name: "trade_shipments_term_id_fk", column: "term_id"
  add_foreign_key "trade_shipments", "trade_codes", name: "trade_shipments_unit_id_fk", column: "unit_id"
  add_foreign_key "trade_shipments", "users", name: "trade_shipments_created_by_id_fk", column: "created_by_id"
  add_foreign_key "trade_shipments", "users", name: "trade_shipments_updated_by_id_fk", column: "updated_by_id"

  add_foreign_key "trade_taxon_concept_term_pairs", "taxon_concepts", name: "trade_taxon_concept_code_pairs_taxon_concept_id_fk"
  add_foreign_key "trade_taxon_concept_term_pairs", "trade_codes", name: "trade_taxon_concept_code_pairs_term_id_fk", column: "term_id"

end
