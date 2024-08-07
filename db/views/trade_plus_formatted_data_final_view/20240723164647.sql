            WITH codes_map(rule_id,term_id,term_code,term_name,unit_id,unit_code,unit_name,output_term_id,output_term_code,output_term_name,output_unit_id,output_unit_code,output_unit_name,taxa_field,term_quantity_modifier,term_modifier_value,unit_quantity_modifier,unit_modifier_value) AS (
        VALUES (1,84,'SKI','skins',129,'BSK','bellyskins',84,'SKI','skins',-1,'NULL','NULL',NULL,NULL,NULL,'/',2.0),
(2,84,'SKI','skins',126,'BAK','backskins',84,'SKI','skins',-1,'NULL','NULL',NULL,NULL,NULL,'/',2.0),
(3,84,'SKI','skins',140,'HRN','hornback skins',84,'SKI','skins',-1,'NULL','NULL',NULL,NULL,NULL,'/',2.0),
(4,82,'SKP','skin pieces',129,'BSK','bellyskins',84,'SKI','skins',-1,'NULL','NULL',NULL,NULL,NULL,'/',2.0),
(5,82,'SKP','skin pieces',126,'BAK','backskins',84,'SKI','skins',-1,'NULL','NULL',NULL,NULL,NULL,'/',2.0),
(6,82,'SKP','skin pieces',140,'HRN','hornback skins',84,'SKI','skins',-1,'NULL','NULL',NULL,NULL,NULL,'/',2.0)
      )

      -- Use DISTINCT ON, as it is possible for multiple rules to match,
      -- e.g. term=COR, unit=NAR (* 0.58, kg); unit=NAR (* 1). In this case,
      -- we expect the first matching rule to apply.
      SELECT DISTINCT ON (ts.id)
        ts.id AS id,ts.year AS year,ts.appendix AS appendix,ts.reported_by_exporter AS reported_by_exporter,ts.taxon_id AS taxon_id,ts.author_year AS author_year,ts.name_status AS name_status,ts.taxon_name AS taxon_name,ts.kingdom_name AS kingdom_name,ts.kingdom_id AS kingdom_id,ts.phylum_name AS phylum_name,ts.phylum_id AS phylum_id,ts.class_name AS class_name,ts.class_id AS class_id,ts.order_name AS order_name,ts.order_id AS order_id,ts.family_name AS family_name,ts.family_id AS family_id,ts.genus_name AS genus_name,ts.genus_id AS genus_id,ts.group_name_en AS group_name_en,ts.group_name_es AS group_name_es,ts.group_name_fr AS group_name_fr,ts.quantity AS quantity,ts.exporter_id AS exporter_id,ts.exporter_iso AS exporter_iso,ts.exporter_en AS exporter_en,ts.exporter_es AS exporter_es,ts.exporter_fr AS exporter_fr,ts.importer_id AS importer_id,ts.importer_iso AS importer_iso,ts.importer_en AS importer_en,ts.importer_es AS importer_es,ts.importer_fr AS importer_fr,ts.origin_id AS origin_id,ts.origin_iso AS origin_iso,ts.origin_en AS origin_en,ts.origin_es AS origin_es,ts.origin_fr AS origin_fr,ts.purpose_id AS purpose_id,ts.purpose_en AS purpose_en,ts.purpose_es AS purpose_es,ts.purpose_fr AS purpose_fr,ts.purpose_code AS purpose_code,ts.source_id AS source_id,ts.source_en AS source_en,ts.source_es AS source_es,ts.source_fr AS source_fr,ts.source_code AS source_code,ts.rank_id AS rank_id,ts.rank_name_en AS rank_name_en,ts.rank_name_es AS rank_name_es,ts.rank_name_fr AS rank_name_fr,
        -- Replacing NULLs with values from related rows when possible.
        -- Moreover, if ids are -1 or codes/names are 'NULL' strings, replace those with NULL
        -- after the processing is done. This is to get back to just a unique NULL representation.
        NULLIF(COALESCE(COALESCE(output_term_id,   codes_map.term_id),   ts.term_id),      '-1')::INTEGER AS term_id,
        NULLIF(COALESCE(COALESCE(output_term_code, codes_map.term_code), terms.code),    'NULL') AS term_code,
        NULLIF(COALESCE(COALESCE(output_term_name, codes_map.term_name), terms.name_en), 'NULL') AS term_en,
        NULLIF(COALESCE(COALESCE(output_unit_id,   codes_map.unit_id),   ts.unit_id),        -1) AS unit_id,
        NULLIF(COALESCE(COALESCE(output_unit_code, codes_map.unit_code), units.code),    'NULL') AS unit_code,
        NULLIF(COALESCE(COALESCE(output_unit_name, codes_map.unit_name), units.name_en), 'NULL') AS unit_en,
        COALESCE(codes_map.term_quantity_modifier,     ts.term_quantity_modifier)     AS term_quantity_modifier,
        COALESCE(codes_map.term_modifier_value::FLOAT, ts.term_modifier_value)::FLOAT AS term_modifier_value,
        COALESCE(codes_map.unit_quantity_modifier,     ts.unit_quantity_modifier)     AS unit_quantity_modifier,
        COALESCE(codes_map.unit_modifier_value::FLOAT, ts.unit_modifier_value)::FLOAT AS unit_modifier_value
      FROM trade_plus_formatted_data_view ts
            LEFT OUTER JOIN codes_map ON (
        (
          codes_map.term_id = ts.term_id AND
          (codes_map.unit_id = ts.unit_id OR codes_map.unit_id = -1 AND ts.unit_id IS NULL) AND
          codes_map.taxa_field IS NULL
        ) OR
        (
          codes_map.term_id = ts.term_id AND
          codes_map.unit_id IS NULL AND
          codes_map.taxa_field IS NULL
        ) OR
        (
          (codes_map.unit_id = ts.unit_id OR codes_map.unit_id = -1 AND ts.unit_id IS NULL) AND
          codes_map.term_id IS NULL AND
          codes_map.taxa_field IS NULL
        )
      )

      LEFT OUTER JOIN trade_codes terms ON ts.term_id = terms.id
      LEFT OUTER JOIN trade_codes units ON ts.unit_id = units.id
      ORDER BY ts.id, codes_map.rule_id
