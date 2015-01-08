SELECT
  listing_changes_mview.id,
  event_id,
  taxon_concept_id,
  original_taxon_concept_id,
  CASE
    WHEN listing_changes_mview.change_type_name = 'DELETION'
      OR listing_changes_mview.change_type_name = 'RESERVATION_WITHDRAWAL'
    THEN FALSE
    ELSE listing_changes_mview.is_current
  END AS is_current,
  listing_changes_mview.effective_at::DATE,
  listing_changes_mview.species_listing_name,
  listing_changes_mview.change_type_name,
  CASE
    WHEN listing_changes_mview.change_type_name = 'ADDITION' THEN '+'
    WHEN listing_changes_mview.change_type_name = 'DELETION' THEN '-'
    WHEN listing_changes_mview.change_type_name = 'RESERVATION' THEN 'R+'
    WHEN listing_changes_mview.change_type_name = 'RESERVATION_WITHDRAWAL' THEN 'R-'
    ELSE ''
  END AS change_type,
  listing_changes_mview.inclusion_taxon_concept_id,
  listing_changes_mview.party_id,
  CASE
    WHEN party_id IS NULL THEN NULL::JSON
    ELSE
      ROW_TO_JSON(
        ROW(
          party_iso_code,
          party_full_name_en,
          geo_entity_type
        )::api_geo_entity
      )
  END AS party_en,
  CASE
    WHEN party_id IS NULL THEN NULL::JSON
    ELSE
      ROW_TO_JSON(
        ROW(
          party_iso_code,
          party_full_name_es,
          geo_entity_type
        )::api_geo_entity
      )
  END AS party_es,
  CASE
    WHEN party_id IS NULL THEN NULL::JSON
    ELSE
      ROW_TO_JSON(
        ROW(
          party_iso_code,
          party_full_name_fr,
          geo_entity_type
        )::api_geo_entity
      )
  END AS party_fr,
  CASE
    WHEN listing_changes_mview.auto_note_en IS NULL
      AND listing_changes_mview.inherited_full_note_en IS NULL
      AND listing_changes_mview.inherited_short_note_en IS NULL
      AND listing_changes_mview.full_note_en IS NULL
      AND listing_changes_mview.short_note_en IS NULL
      AND listing_changes_mview.nomenclature_note_en IS NULL
    THEN NULL
    ELSE
      CASE
        WHEN LENGTH(listing_changes_mview.auto_note_en) > 0 THEN '[' || listing_changes_mview.auto_note_en || '] '
        ELSE ''
      END
      || CASE
        WHEN LENGTH(listing_changes_mview.inherited_full_note_en) > 0 THEN strip_tags(listing_changes_mview.inherited_full_note_en)
        WHEN LENGTH(listing_changes_mview.inherited_short_note_en) > 0 THEN strip_tags(listing_changes_mview.inherited_short_note_en)
        WHEN LENGTH(listing_changes_mview.full_note_en) > 0 THEN strip_tags(listing_changes_mview.full_note_en)
        WHEN LENGTH(listing_changes_mview.short_note_en) > 0 THEN strip_tags(listing_changes_mview.short_note_en)
        ELSE ''
      END
      || CASE
        WHEN LENGTH(listing_changes_mview.nomenclature_note_en) > 0 THEN strip_tags(listing_changes_mview.nomenclature_note_en)
        ELSE ''
      END
  END AS annotation_en,
  CASE
    WHEN listing_changes_mview.auto_note_es IS NULL
      AND listing_changes_mview.inherited_full_note_es IS NULL
      AND listing_changes_mview.inherited_short_note_es IS NULL
      AND listing_changes_mview.full_note_es IS NULL
      AND listing_changes_mview.short_note_es IS NULL
      AND listing_changes_mview.nomenclature_note_es IS NULL
    THEN NULL
    ELSE
      CASE
        WHEN LENGTH(listing_changes_mview.auto_note_es) > 0 THEN '[' || listing_changes_mview.auto_note_es || '] '
        ELSE ''
      END
      || CASE
        WHEN LENGTH(listing_changes_mview.inherited_full_note_es) > 0 THEN strip_tags(listing_changes_mview.inherited_full_note_es)
        WHEN LENGTH(listing_changes_mview.inherited_short_note_es) > 0 THEN strip_tags(listing_changes_mview.inherited_short_note_es)
        WHEN LENGTH(listing_changes_mview.full_note_es) > 0 THEN strip_tags(listing_changes_mview.full_note_es)
        WHEN LENGTH(listing_changes_mview.short_note_es) > 0 THEN strip_tags(listing_changes_mview.short_note_es)
        ELSE ''
      END
      || CASE
        WHEN LENGTH(listing_changes_mview.nomenclature_note_en) > 0 THEN strip_tags(listing_changes_mview.nomenclature_note_en)
        ELSE ''
      END
  END AS annotation_es,
  CASE
    WHEN listing_changes_mview.auto_note_fr IS NULL
      AND listing_changes_mview.inherited_full_note_fr IS NULL
      AND listing_changes_mview.inherited_short_note_fr IS NULL
      AND listing_changes_mview.full_note_fr IS NULL
      AND listing_changes_mview.short_note_fr IS NULL
      AND listing_changes_mview.nomenclature_note_fr IS NULL
    THEN NULL
    ELSE
      CASE
        WHEN LENGTH(listing_changes_mview.auto_note_fr) > 0 THEN '[' || listing_changes_mview.auto_note_fr || '] '
        ELSE ''
      END
      || CASE
        WHEN LENGTH(listing_changes_mview.inherited_full_note_fr) > 0 THEN strip_tags(listing_changes_mview.inherited_full_note_fr)
        WHEN LENGTH(listing_changes_mview.inherited_short_note_fr) > 0 THEN strip_tags(listing_changes_mview.inherited_short_note_fr)
        WHEN LENGTH(listing_changes_mview.full_note_fr) > 0 THEN strip_tags(listing_changes_mview.full_note_fr)
        WHEN LENGTH(listing_changes_mview.short_note_fr) > 0 THEN strip_tags(listing_changes_mview.short_note_fr)
        ELSE ''
      END
      || CASE
        WHEN LENGTH(listing_changes_mview.nomenclature_note_fr) > 0 THEN strip_tags(listing_changes_mview.nomenclature_note_fr)
        ELSE ''
      END
  END AS annotation_fr,
  CASE
    WHEN listing_changes_mview.hash_ann_symbol IS NULL
      AND listing_changes_mview.hash_full_note_en IS NULL
    THEN NULL::JSON
    ELSE
      ROW_TO_JSON(
        ROW(
          listing_changes_mview.hash_ann_symbol,
          strip_tags(listing_changes_mview.hash_full_note_en)
        )::api_annotation
      )
  END AS hash_annotation_en,
  CASE
    WHEN listing_changes_mview.hash_ann_symbol IS NULL
      AND listing_changes_mview.hash_full_note_es IS NULL
    THEN NULL::JSON
    ELSE
      ROW_TO_JSON(
        ROW(
          listing_changes_mview.hash_ann_parent_symbol || ' ' || listing_changes_mview.hash_ann_symbol,
          strip_tags(listing_changes_mview.hash_full_note_es)
        )::api_annotation
      )
  END AS hash_annotation_es,
  CASE
    WHEN listing_changes_mview.hash_ann_symbol IS NULL
      AND listing_changes_mview.hash_full_note_fr IS NULL
    THEN NULL::JSON
    ELSE
      ROW_TO_JSON(
        ROW(
          listing_changes_mview.hash_ann_symbol,
          strip_tags(listing_changes_mview.hash_full_note_fr)
        )::api_annotation
      )
  END AS hash_annotation_fr,
  listing_changes_mview.show_in_history,
  listing_changes_mview.full_note_en,
  listing_changes_mview.short_note_en,
  listing_changes_mview.auto_note_en,
  listing_changes_mview.hash_full_note_en,
  listing_changes_mview.hash_ann_parent_symbol,
  listing_changes_mview.hash_ann_symbol,
  listing_changes_mview.inherited_full_note_en,
  listing_changes_mview.inherited_short_note_en,
  listing_changes_mview.nomenclature_note_en,
  listing_changes_mview.nomenclature_note_fr,
  listing_changes_mview.nomenclature_note_es,
  CASE
    WHEN change_type_name = 'ADDITION' THEN 0
    WHEN change_type_name = 'RESERVATION' THEN 1
    WHEN change_type_name = 'RESERVATION_WITHDRAWAL' THEN 2
    WHEN change_type_name = 'DELETION' THEN 3
  END AS change_type_order
FROM cites_listing_changes_mview listing_changes_mview
WHERE "listing_changes_mview"."show_in_history";
