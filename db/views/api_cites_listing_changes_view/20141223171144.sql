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
  listing_changes_mview.effective_at,
  listing_changes_mview.species_listing_name,
  listing_changes_mview.change_type_name,
  listing_changes_mview.inclusion_taxon_concept_id,
  listing_changes_mview.party_id,
  ROW_TO_JSON(
    ROW(
      party_id,
      party_iso_code,
      party_full_name_en,
      NULL
    )::api_geo_entity
  ) AS party_en,
  ROW_TO_JSON(
    ROW(
      party_id,
      party_iso_code,
      party_full_name_es,
      NULL
    )::api_geo_entity
  ) AS party_es,
  ROW_TO_JSON(
    ROW(
      party_id,
      party_iso_code,
      party_full_name_fr,
      NULL
    )::api_geo_entity
  ) AS party_fr,
  ROW_TO_JSON(
    ROW(
      NULL,
      CASE
        WHEN LENGTH(listing_changes_mview.auto_note_en) > 0 THEN '[' || listing_changes_mview.auto_note_en || '] '
        ELSE ''
      END
      || CASE
        WHEN LENGTH(listing_changes_mview.inherited_full_note_en) > 0 THEN strip_tags(listing_changes_mview.inherited_full_note_en)
        WHEN LENGTH(listing_changes_mview.inherited_short_note_en) > 0 THEN strip_tags(listing_changes_mview.inherited_short_note_en)
        WHEN LENGTH(listing_changes_mview.full_note_en) > 0 THEN strip_tags(listing_changes_mview.full_note_en)
        ELSE strip_tags(listing_changes_mview.short_note_en)
      END
      || CASE
        WHEN LENGTH(listing_changes_mview.nomenclature_note_en) > 0 THEN strip_tags(listing_changes_mview.nomenclature_note_en)
      END
    )::api_annotation
  ) AS annotation_en,
  ROW_TO_JSON(
    ROW(
      NULL,
      CASE
        WHEN LENGTH(listing_changes_mview.auto_note_es) > 0 THEN '[' || listing_changes_mview.auto_note_es || '] '
        ELSE ''
      END
      || CASE
        WHEN LENGTH(listing_changes_mview.inherited_full_note_es) > 0 THEN strip_tags(listing_changes_mview.inherited_full_note_es)
        WHEN LENGTH(listing_changes_mview.inherited_short_note_es) > 0 THEN strip_tags(listing_changes_mview.inherited_short_note_es)
        WHEN LENGTH(listing_changes_mview.full_note_es) > 0 THEN strip_tags(listing_changes_mview.full_note_es)
        ELSE strip_tags(listing_changes_mview.short_note_es)
      END
      || CASE
        WHEN LENGTH(listing_changes_mview.nomenclature_note_en) > 0 THEN strip_tags(listing_changes_mview.nomenclature_note_en)
      END
    )::api_annotation
  ) AS annotation_es,
  ROW_TO_JSON(
    ROW(
      NULL,
      CASE
        WHEN LENGTH(listing_changes_mview.auto_note_fr) > 0 THEN '[' || listing_changes_mview.auto_note_fr || '] '
        ELSE ''
      END
      || CASE
        WHEN LENGTH(listing_changes_mview.inherited_full_note_fr) > 0 THEN strip_tags(listing_changes_mview.inherited_full_note_fr)
        WHEN LENGTH(listing_changes_mview.inherited_short_note_fr) > 0 THEN strip_tags(listing_changes_mview.inherited_short_note_fr)
        WHEN LENGTH(listing_changes_mview.full_note_fr) > 0 THEN strip_tags(listing_changes_mview.full_note_fr)
        ELSE strip_tags(listing_changes_mview.short_note_fr)
      END
      || CASE
        WHEN LENGTH(listing_changes_mview.nomenclature_note_fr) > 0 THEN strip_tags(listing_changes_mview.nomenclature_note_fr)
      END
    )::api_annotation
  ) AS annotation_fr,
  ROW_TO_JSON(
    ROW(
      listing_changes_mview.hash_ann_symbol,
      strip_tags(listing_changes_mview.hash_full_note_en)
    )::api_annotation
  ) AS hash_annotation_en,
  ROW_TO_JSON(
    ROW(
      listing_changes_mview.hash_ann_parent_symbol || ' ' || listing_changes_mview.hash_ann_symbol,
      strip_tags(listing_changes_mview.hash_full_note_es)
    )::api_annotation
  ) AS hash_annotation_es,
  ROW_TO_JSON(
    ROW(
      listing_changes_mview.hash_ann_symbol,
      strip_tags(listing_changes_mview.hash_full_note_fr)
    )::api_annotation
  ) AS hash_annotation_fr,

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
