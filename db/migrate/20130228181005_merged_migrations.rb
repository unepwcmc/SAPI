class MergedMigrations < ActiveRecord::Migration
  def change


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
    t.text     "short_note_en"
    t.text     "full_note_en"
    t.text     "short_note_fr"
    t.text     "full_note_fr"
    t.text     "short_note_es"
    t.text     "full_note_es"
    t.boolean  "display_in_index",    :default => false, :null => false
    t.boolean  "display_in_footnote", :default => false, :null => false
  end

  add_index "annotations", ["listing_change_id"], :name => "index_annotations_on_listing_change_id"

  create_table "change_types", :force => true do |t|
    t.string   "name",           :null => false
    t.integer  "designation_id", :null => false
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  create_table "common_names", :force => true do |t|
    t.string   "name",        :null => false
    t.integer  "language_id", :null => false
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "designations", :force => true do |t|
    t.string   "name",                       :null => false
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
    t.integer  "taxonomy_id", :default => 1, :null => false
  end

  create_table "distribution_references", :force => true do |t|
    t.integer "distribution_id", :null => false
    t.integer "reference_id",    :null => false
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

  create_table "events", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
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
    t.integer  "taxon_concept_id",                                              :null => false
    t.integer  "species_listing_id"
    t.integer  "change_type_id",                                                :null => false
    t.datetime "effective_at",               :default => '2012-09-21 07:32:20', :null => false
    t.boolean  "is_current",                 :default => false,                 :null => false
    t.integer  "annotation_id"
    t.integer  "parent_id"
    t.integer  "inclusion_taxon_concept_id"
    t.datetime "created_at",                                                    :null => false
    t.datetime "updated_at",                                                    :null => false
    t.integer  "hash_annotation_id"
    t.boolean  "explicit_change",            :default => true
  end

  add_index "listing_changes", ["annotation_id"], :name => "index_listing_changes_on_annotation_id"
  add_index "listing_changes", ["hash_annotation_id"], :name => "index_listing_changes_on_hash_annotation_id"
  add_index "listing_changes", ["parent_id"], :name => "index_listing_changes_on_parent_id"

  create_table "listing_distributions", :force => true do |t|
    t.integer  "listing_change_id",                   :null => false
    t.integer  "geo_entity_id",                       :null => false
    t.boolean  "is_party",          :default => true, :null => false
    t.datetime "created_at",                          :null => false
    t.datetime "updated_at",                          :null => false
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
    t.text     "title",       :null => false
    t.string   "year"
    t.string   "author"
    t.integer  "legacy_id"
    t.string   "legacy_type"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "species_listings", :force => true do |t|
    t.integer  "designation_id", :null => false
    t.string   "name",           :null => false
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
  end

  create_table "taxon_concept_references", :force => true do |t|
    t.integer "taxon_concept_id", :null => false
    t.integer "reference_id",     :null => false
    t.hstore  "data"
  end

  create_table "taxon_concepts", :force => true do |t|
    t.integer  "parent_id"
    t.integer  "rank_id",                                     :null => false
    t.integer  "taxon_name_id",                               :null => false
    t.string   "author_year"
    t.integer  "legacy_id"
    t.string   "legacy_type"
    t.hstore   "data"
    t.hstore   "listing"
    t.text     "notes"
    t.string   "taxonomic_position",         :default => "0", :null => false
    t.string   "full_name"
    t.string   "name_status",                :default => "A", :null => false
    t.datetime "created_at",                                  :null => false
    t.datetime "updated_at",                                  :null => false
    t.integer  "taxonomy_id",                :default => 1,   :null => false
    t.integer  "closest_listed_ancestor_id"
  end

  add_index "taxon_concepts", ["parent_id"], :name => "index_taxon_concepts_on_parent_id"

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
  end

  create_table "taxonomies", :force => true do |t|
    t.string   "name",       :default => "DEAFAULT TAXONOMY", :null => false
    t.datetime "created_at",                                  :null => false
    t.datetime "updated_at",                                  :null => false
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
  add_foreign_key "taxon_concepts", "taxon_concepts", :name => "taxon_concepts_closest_listed_ancestor_id_fk", :column => "closest_listed_ancestor_id"
  add_foreign_key "taxon_concepts", "taxon_concepts", :name => "taxon_concepts_parent_id_fk", :column => "parent_id"
  add_foreign_key "taxon_concepts", "taxon_names", :name => "taxon_concepts_taxon_name_id_fk"
  add_foreign_key "taxon_concepts", "taxonomies", :name => "taxon_concepts_taxonomy_id_fk"

  add_foreign_key "taxon_relationships", "taxon_concepts", :name => "taxon_relationships_taxon_concept_id_fk"
  add_foreign_key "taxon_relationships", "taxon_relationship_types", :name => "taxon_relationships_taxon_relationship_type_id_fk"


  execute <<-SQL
      DROP VIEW IF EXISTS listing_changes_view;
      CREATE VIEW listing_changes_view AS
      SELECT
        listing_changes.id AS id,
        taxon_concept_id, effective_at,
        species_listing_id,
        species_listings.abbreviation AS species_listing_name,
        change_type_id, change_types.name AS change_type_name,
        listing_distributions.geo_entity_id AS party_id,
        geo_entities.iso_code2 AS party_name,
        annotations.symbol AS ann_symbol,
        annotations.full_note_en,
        annotations.full_note_es,
        annotations.full_note_fr,
        annotations.short_note_en,
        annotations.short_note_es,
        annotations.short_note_fr,
        annotations.display_in_index,
        annotations.display_in_footnote,
        hash_annotations.symbol AS hash_ann_symbol,
        hash_annotations.parent_symbol AS hash_ann_parent_symbol,
        hash_annotations.full_note_en AS hash_full_note_en,
        hash_annotations.full_note_es AS hash_full_note_es,
        hash_annotations.full_note_fr AS hash_full_note_fr,
        listing_changes.is_current,
        listing_changes.explicit_change,
        populations.countries_ids_ary
      FROM
        listing_changes
        INNER JOIN change_types
          ON listing_changes.change_type_id = change_types.id
        LEFT JOIN species_listings
          ON listing_changes.species_listing_id = species_listings.id
        LEFT JOIN listing_distributions
          ON listing_changes.id = listing_distributions.listing_change_id
          AND listing_distributions.is_party = 't'
        LEFT JOIN geo_entities ON
          geo_entities.id = listing_distributions.geo_entity_id
        LEFT JOIN annotations ON
          annotations.id = listing_changes.annotation_id
        LEFT JOIN annotations hash_annotations ON
          hash_annotations.id = listing_changes.hash_annotation_id
        LEFT JOIN (
          SELECT listing_change_id, ARRAY_AGG(geo_entities.id) AS countries_ids_ary
          FROM listing_distributions
          INNER JOIN geo_entities
          ON geo_entities.id = listing_distributions.geo_entity_id
          WHERE NOT is_party
          GROUP BY listing_change_id
        ) populations ON populations.listing_change_id = listing_changes.id
      ORDER BY taxon_concept_id, effective_at,
      CASE
        WHEN change_types.name = 'ADDITION' THEN 0
        WHEN change_types.name = 'RESERVATION' THEN 1
        WHEN change_types.name = 'RESERVATION_WITHDRAWAL' THEN 2
        WHEN change_types.name = 'DELETION' THEN 3
      END
    SQL

  Sapi::rebuild_listing_changes_mview

  execute "CREATE UNIQUE INDEX listing_changes_mview_on_id ON listing_changes_mview (id)"
  execute "CREATE INDEX listing_changes_mview_on_taxon_concept_id ON listing_changes_mview (taxon_concept_id)"

 execute <<-SQL
    DROP VIEW IF EXISTS taxon_concepts_view;
    CREATE OR REPLACE VIEW taxon_concepts_view AS
    SELECT taxon_concepts.id,
    taxon_concepts.parent_id,
    CASE
    WHEN taxonomies.name = 'CITES_EU' THEN TRUE
    ELSE FALSE
    END AS taxonomy_is_cites_eu,
    full_name,
    name_status,
    data->'rank_name' AS rank_name,
    (data->'cites_accepted')::BOOLEAN AS cites_accepted,
    CASE
    WHEN data->'kingdom_name' = 'Animalia' THEN 0
    ELSE 1
    END AS kingdom_position,
    taxonomic_position,
    data->'kingdom_name' AS kingdom_name,
    data->'phylum_name' AS phylum_name,
    data->'class_name' AS class_name,
    data->'order_name' AS order_name,
    data->'family_name' AS family_name,
    data->'genus_name' AS genus_name,
    data->'species_name' AS species_name,
    data->'subspecies_name' AS subspecies_name,
    (data->'kingdom_id')::INTEGER AS kingdom_id,
    (data->'phylum_id')::INTEGER AS phylum_id,
    (data->'class_id')::INTEGER AS class_id,
    (data->'order_id')::INTEGER AS order_id,
    (data->'family_id')::INTEGER AS family_id,
    (data->'genus_id')::INTEGER AS genus_id,
    (data->'species_id')::INTEGER AS species_id,
    (data->'subspecies_id')::INTEGER AS subspecies_id,
    (listing->'cites_fully_covered')::BOOLEAN AS cites_fully_covered,
    CASE
    WHEN listing->'cites_status' = 'LISTED' AND listing->'cites_status_original' = 't'
    THEN TRUE
    WHEN listing->'cites_status' = 'LISTED'
    THEN FALSE
    ELSE NULL
    END AS cites_listed,
    CASE
    WHEN listing->'cites_status' = 'DELETED'
    THEN TRUE
    ELSE FALSE
    END AS cites_deleted,
    CASE
    WHEN listing->'cites_status' = 'EXCLUDED'
    THEN TRUE
    ELSE FALSE
    END AS cites_excluded,
    (listing->'cites_show')::BOOLEAN AS cites_show,
    CASE
    WHEN listing->'cites_I' = 'I' THEN TRUE
    ELSE FALSE
    END AS cites_I,
    CASE
    WHEN listing->'cites_II' = 'II' THEN TRUE
    ELSE FALSE
    END AS cites_II,
    CASE
    WHEN listing->'cites_III' = 'III' THEN TRUE
    ELSE FALSE
    END AS cites_III,
    listing->'cites_listing' AS current_listing,
    closest_listed_ancestor_id,
    (listing->'listing_updated_at')::TIMESTAMP AS listing_updated_at,
    (listing->'ann_symbol') AS ann_symbol,
    (listing->'hash_ann_symbol') AS hash_ann_symbol,
    (listing->'hash_ann_parent_symbol') AS hash_ann_parent_symbol,
    author_year,
    taxon_concepts.created_at,
    taxon_concepts.updated_at,
    common_names.*,
    synonyms.*,
    countries_ids_ary,
    standard_references_ids_ary
    FROM taxon_concepts
    LEFT JOIN taxonomies
    ON taxonomies.id = taxon_concepts.taxonomy_id
    LEFT JOIN (
    SELECT *
    FROM
    CROSSTAB(
    'SELECT taxon_concepts.id AS taxon_concept_id_com,
    SUBSTRING(languages.name_en FROM 1 FOR 1) AS lng,
    ARRAY_AGG(common_names.name ORDER BY common_names.id) AS common_names_ary
    FROM "taxon_concepts"
    INNER JOIN "taxon_commons"
    ON "taxon_commons"."taxon_concept_id" = "taxon_concepts"."id"
    INNER JOIN "common_names"
    ON "common_names"."id" = "taxon_commons"."common_name_id"
    INNER JOIN "languages"
    ON "languages"."id" = "common_names"."language_id"
    GROUP BY taxon_concepts.id, SUBSTRING(languages.name_en FROM 1 FOR 1)
    ORDER BY 1,2'
    ) AS ct(
    taxon_concept_id_com INTEGER,
    english_names_ary VARCHAR[], french_names_ary VARCHAR[], spanish_names_ary VARCHAR[]
    )
    ) common_names ON taxon_concepts.id = common_names.taxon_concept_id_com
    LEFT JOIN (
    SELECT taxon_concepts.id AS taxon_concept_id_syn,
    ARRAY_AGG(synonym_tc.full_name) AS synonyms_ary,
    ARRAY_AGG(synonym_tc.author_year) AS synonyms_author_years_ary
    FROM taxon_concepts
    LEFT JOIN taxon_relationships
    ON "taxon_relationships"."taxon_concept_id" = "taxon_concepts"."id"
    LEFT JOIN "taxon_relationship_types"
    ON "taxon_relationship_types"."id" = "taxon_relationships"."taxon_relationship_type_id"
    LEFT JOIN taxon_concepts AS synonym_tc
    ON synonym_tc.id = taxon_relationships.other_taxon_concept_id
    GROUP BY taxon_concepts.id
    ) synonyms ON taxon_concepts.id = synonyms.taxon_concept_id_syn
    LEFT JOIN (
    SELECT taxon_concepts.id AS taxon_concept_id_cnt,
    ARRAY_AGG(geo_entities.id ORDER BY geo_entities.name_en) AS countries_ids_ary
    FROM taxon_concepts
    LEFT JOIN distributions
    ON "distributions"."taxon_concept_id" = "taxon_concepts"."id"
    LEFT JOIN geo_entities
    ON distributions.geo_entity_id = geo_entities.id
    LEFT JOIN "geo_entity_types"
    ON "geo_entity_types"."id" = "geo_entities"."geo_entity_type_id"
    AND geo_entity_types.name = 'COUNTRY'
    GROUP BY taxon_concepts.id
    ) countries_ids ON taxon_concepts.id = countries_ids.taxon_concept_id_cnt
    LEFT JOIN (
    WITH taxa_with_std_refs AS (
    WITH RECURSIVE q AS (
    SELECT h, h.id, ARRAY_AGG(reference_id) AS standard_references_ids_ary
    FROM taxon_concepts h
    LEFT JOIN taxon_concept_references
    ON h.id = taxon_concept_references.taxon_concept_id
    AND taxon_concept_references.data->'usr_is_std_ref' = 't'
    WHERE h.parent_id IS NULL
    GROUP BY h.id

    UNION ALL

    SELECT hi, hi.id,
    CASE
    WHEN (hi.data->'usr_no_std_ref')::BOOLEAN = 't' THEN ARRAY[]::INTEGER[]
    ELSE standard_references_ids_ary || reference_id
    END
    FROM q
    JOIN taxon_concepts hi ON hi.parent_id = (q.h).id
    LEFT JOIN taxon_concept_references
    ON hi.id = taxon_concept_references.taxon_concept_id
    AND taxon_concept_references.data->'usr_is_std_ref' = 't'
    )
    SELECT DISTINCT id,
    UNNEST(standard_references_ids_ary) AS std_ref_id
    FROM q
    )
    SELECT id AS taxon_concept_id_sr, ARRAY_AGG(std_ref_id) AS standard_references_ids_ary
    FROM taxa_with_std_refs
    WHERE std_ref_id IS NOT NULL
    GROUP BY id
    ) standard_references_ids ON taxon_concepts.id = standard_references_ids.taxon_concept_id_sr
  SQL

  Sapi::rebuild_taxon_concepts_mview

  execute "CREATE UNIQUE INDEX taxon_concepts_mview_on_id ON taxon_concepts_mview (id)"
  execute "CREATE INDEX taxon_concepts_mview_on_history_filter ON taxon_concepts_mview (taxonomy_is_cites_eu, cites_listed, kingdom_position)"
  execute "CREATE INDEX taxon_concepts_mview_on_full_name ON taxon_concepts_mview (full_name)"
  execute "CREATE INDEX taxon_concepts_mview_on_parent_id ON taxon_concepts_mview (parent_id)"

  end
end
