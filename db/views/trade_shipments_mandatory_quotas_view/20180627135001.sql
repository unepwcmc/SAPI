
    (
      SELECT ts.id AS id,ts.year AS year,ts.appendix AS appendix,ts.taxon_concept_author_year AS author_year,ts.taxon_concept_name_status AS name_status,ts.taxon_concept_id,ts.taxon_concept_full_name AS taxon_name,ts.taxon_concept_phylum_id AS phylum_id,ts.taxon_concept_class_id AS class_id,ts.taxon_concept_class_name AS class_name,ts.taxon_concept_order_id AS order_id,ts.taxon_concept_order_name AS order_name,ts.taxon_concept_family_id AS family_id,ts.taxon_concept_family_name AS family_name,ts.taxon_concept_genus_id AS genus_id,ts.taxon_concept_genus_name AS genus_name,CASE WHEN ts.reported_by_exporter THEN ts.quantity ELSE NULL END AS exporter_reported_quantity,CASE WHEN ts.reported_by_exporter THEN NULL ELSE ts.quantity END AS importer_reported_quantity,unit.id AS unit_id,unit.name_en AS unit,importer.id AS importer_id,importer.iso_code2 AS importer_iso,importer.name_en AS importer,exporter.id AS exporter_id,exporter.iso_code2 AS exporter_iso,exporter.name_en AS exporter,NULL AS origin,purpose.id AS purpose_id,purpose.name_en AS purpose,source.id AS source_id,source.name_en AS source,term.id AS term_id,term.name_en AS term,ts.import_permits_ids AS import_permits,ts.export_permits_ids AS export_permits,ts.origin_permits_ids AS origin_permits,ts.import_permit_number AS import_permit,ts.export_permit_number AS export_permit,ts.origin_permit_number AS origin_permit,'Quota' AS issue_type,'CoP_approved' AS details_of_compliance_issue,'09/06/1997' AS compliance_type_start_date,'Present' AS compliance_type_end_date,'Capra falconeri' AS compliance_type_taxon,ts.taxon_concept_rank_id AS rank_id,'SPECIES' AS rank_name,'12' AS quota_quantity,'hunting trophies  Conf. 10.15 (Rev. CoP14)' AS notes
      FROM trade_shipments_with_taxa_view ts
      
      INNER JOIN geo_entities AS exporter ON exporter.id = ts.exporter_id
      INNER JOIN geo_entities AS importer ON importer.id = ts.importer_id
      LEFT OUTER JOIN trade_codes source ON ts.source_id = source.id
      LEFT OUTER JOIN trade_codes purpose ON ts.purpose_id = purpose.id
      LEFT OUTER JOIN trade_codes unit ON ts.unit_id = unit.id
      LEFT OUTER JOIN trade_codes term ON ts.term_id = term.id
    
      WHERE ts.id IN (
        SELECT UNNEST(sub.ids)
        FROM (
          
          SELECT ARRAY_AGG(ts.id) AS ids
          FROM trade_shipments_with_taxa_view ts
          
          INNER JOIN geo_entities AS exporter ON exporter.id = ts.exporter_id
          LEFT OUTER JOIN trade_codes source ON ts.source_id = source.id
          LEFT OUTER JOIN trade_codes purpose ON ts.purpose_id = purpose.id
          LEFT OUTER JOIN trade_codes unit ON ts.unit_id = unit.id
          LEFT OUTER JOIN trade_codes term ON ts.term_id = term.id
    
          WHERE ts.year >= 1997 AND ts.year <= 2018 AND ts.taxon_concept_id = 3780 AND exporter.iso_code2 = 'PK' AND TRUE AND term.code IN ('TRO') AND TRUE AND purpose.code IN ('H','P') AND ts.country_of_origin_id IS NULL
          AND (source.name_en != 'Confiscations/seizures' OR ts.source_id IS NULL)
          GROUP BY year, reported_by_exporter
          HAVING SUM(quantity) > 12
    
        ) sub
      )
      ORDER BY ts.year, ts.taxon_concept_full_name, ts.exporter_id, ts.importer_id
    )
    
    UNION    

    (
      SELECT ts.id AS id,ts.year AS year,ts.appendix AS appendix,ts.taxon_concept_author_year AS author_year,ts.taxon_concept_name_status AS name_status,ts.taxon_concept_id,ts.taxon_concept_full_name AS taxon_name,ts.taxon_concept_phylum_id AS phylum_id,ts.taxon_concept_class_id AS class_id,ts.taxon_concept_class_name AS class_name,ts.taxon_concept_order_id AS order_id,ts.taxon_concept_order_name AS order_name,ts.taxon_concept_family_id AS family_id,ts.taxon_concept_family_name AS family_name,ts.taxon_concept_genus_id AS genus_id,ts.taxon_concept_genus_name AS genus_name,CASE WHEN ts.reported_by_exporter THEN ts.quantity ELSE NULL END AS exporter_reported_quantity,CASE WHEN ts.reported_by_exporter THEN NULL ELSE ts.quantity END AS importer_reported_quantity,unit.id AS unit_id,unit.name_en AS unit,importer.id AS importer_id,importer.iso_code2 AS importer_iso,importer.name_en AS importer,exporter.id AS exporter_id,exporter.iso_code2 AS exporter_iso,exporter.name_en AS exporter,NULL AS origin,purpose.id AS purpose_id,purpose.name_en AS purpose,source.id AS source_id,source.name_en AS source,term.id AS term_id,term.name_en AS term,ts.import_permits_ids AS import_permits,ts.export_permits_ids AS export_permits,ts.origin_permits_ids AS origin_permits,ts.import_permit_number AS import_permit,ts.export_permit_number AS export_permit,ts.origin_permit_number AS origin_permit,'Quota' AS issue_type,'CoP_approved' AS details_of_compliance_issue,'09/06/1997' AS compliance_type_start_date,'Present' AS compliance_type_end_date,'Panthera pardus' AS compliance_type_taxon,ts.taxon_concept_rank_id AS rank_id,'SPECIES' AS rank_name,'500' AS quota_quantity,'Resolution Conf. 10.14 (Rev. CoP16)' AS notes
      FROM trade_shipments_with_taxa_view ts
      
      INNER JOIN geo_entities AS exporter ON exporter.id = ts.exporter_id
      INNER JOIN geo_entities AS importer ON importer.id = ts.importer_id
      LEFT OUTER JOIN trade_codes source ON ts.source_id = source.id
      LEFT OUTER JOIN trade_codes purpose ON ts.purpose_id = purpose.id
      LEFT OUTER JOIN trade_codes unit ON ts.unit_id = unit.id
      LEFT OUTER JOIN trade_codes term ON ts.term_id = term.id
    
      WHERE ts.id IN (
        SELECT UNNEST(sub.ids)
        FROM (
          
          SELECT ARRAY_AGG(ts.id) AS ids
          FROM trade_shipments_with_taxa_view ts
          
          INNER JOIN geo_entities AS exporter ON exporter.id = ts.exporter_id
          LEFT OUTER JOIN trade_codes source ON ts.source_id = source.id
          LEFT OUTER JOIN trade_codes purpose ON ts.purpose_id = purpose.id
          LEFT OUTER JOIN trade_codes unit ON ts.unit_id = unit.id
          LEFT OUTER JOIN trade_codes term ON ts.term_id = term.id
    
          WHERE ts.year >= 1997 AND ts.year <= 2018 AND ts.taxon_concept_id = 8619 AND exporter.iso_code2 = 'ET' AND TRUE AND term.code IN ('SKI','TRO') AND TRUE AND purpose.code IN ('H','P') AND ts.country_of_origin_id IS NULL
          AND (source.name_en != 'Confiscations/seizures' OR ts.source_id IS NULL)
          GROUP BY year, reported_by_exporter
          HAVING SUM(quantity) > 500
    
        ) sub
      )
      ORDER BY ts.year, ts.taxon_concept_full_name, ts.exporter_id, ts.importer_id
    )
    
    UNION    

    (
      SELECT ts.id AS id,ts.year AS year,ts.appendix AS appendix,ts.taxon_concept_author_year AS author_year,ts.taxon_concept_name_status AS name_status,ts.taxon_concept_id,ts.taxon_concept_full_name AS taxon_name,ts.taxon_concept_phylum_id AS phylum_id,ts.taxon_concept_class_id AS class_id,ts.taxon_concept_class_name AS class_name,ts.taxon_concept_order_id AS order_id,ts.taxon_concept_order_name AS order_name,ts.taxon_concept_family_id AS family_id,ts.taxon_concept_family_name AS family_name,ts.taxon_concept_genus_id AS genus_id,ts.taxon_concept_genus_name AS genus_name,CASE WHEN ts.reported_by_exporter THEN ts.quantity ELSE NULL END AS exporter_reported_quantity,CASE WHEN ts.reported_by_exporter THEN NULL ELSE ts.quantity END AS importer_reported_quantity,unit.id AS unit_id,unit.name_en AS unit,importer.id AS importer_id,importer.iso_code2 AS importer_iso,importer.name_en AS importer,exporter.id AS exporter_id,exporter.iso_code2 AS exporter_iso,exporter.name_en AS exporter,NULL AS origin,purpose.id AS purpose_id,purpose.name_en AS purpose,source.id AS source_id,source.name_en AS source,term.id AS term_id,term.name_en AS term,ts.import_permits_ids AS import_permits,ts.export_permits_ids AS export_permits,ts.origin_permits_ids AS origin_permits,ts.import_permit_number AS import_permit,ts.export_permit_number AS export_permit,ts.origin_permit_number AS origin_permit,'Quota' AS issue_type,'CoP_approved' AS details_of_compliance_issue,'10/06/1997' AS compliance_type_start_date,'Present' AS compliance_type_end_date,'Panthera pardus' AS compliance_type_taxon,ts.taxon_concept_rank_id AS rank_id,'SPECIES' AS rank_name,'250' AS quota_quantity,'Resolution Conf. 10.14 (Rev. CoP16)' AS notes
      FROM trade_shipments_with_taxa_view ts
      
      INNER JOIN geo_entities AS exporter ON exporter.id = ts.exporter_id
      INNER JOIN geo_entities AS importer ON importer.id = ts.importer_id
      LEFT OUTER JOIN trade_codes source ON ts.source_id = source.id
      LEFT OUTER JOIN trade_codes purpose ON ts.purpose_id = purpose.id
      LEFT OUTER JOIN trade_codes unit ON ts.unit_id = unit.id
      LEFT OUTER JOIN trade_codes term ON ts.term_id = term.id
    
      WHERE ts.id IN (
        SELECT UNNEST(sub.ids)
        FROM (
          
          SELECT ARRAY_AGG(ts.id) AS ids
          FROM trade_shipments_with_taxa_view ts
          
          INNER JOIN geo_entities AS exporter ON exporter.id = ts.exporter_id
          LEFT OUTER JOIN trade_codes source ON ts.source_id = source.id
          LEFT OUTER JOIN trade_codes purpose ON ts.purpose_id = purpose.id
          LEFT OUTER JOIN trade_codes unit ON ts.unit_id = unit.id
          LEFT OUTER JOIN trade_codes term ON ts.term_id = term.id
    
          WHERE ts.year >= 1997 AND ts.year <= 2018 AND ts.taxon_concept_id = 8619 AND exporter.iso_code2 = 'NA' AND TRUE AND term.code IN ('SKI','TRO') AND TRUE AND purpose.code IN ('H','P') AND ts.country_of_origin_id IS NULL
          AND (source.name_en != 'Confiscations/seizures' OR ts.source_id IS NULL)
          GROUP BY year, reported_by_exporter
          HAVING SUM(quantity) > 250
    
        ) sub
      )
      ORDER BY ts.year, ts.taxon_concept_full_name, ts.exporter_id, ts.importer_id
    )
    
    UNION    

    (
      SELECT ts.id AS id,ts.year AS year,ts.appendix AS appendix,ts.taxon_concept_author_year AS author_year,ts.taxon_concept_name_status AS name_status,ts.taxon_concept_id,ts.taxon_concept_full_name AS taxon_name,ts.taxon_concept_phylum_id AS phylum_id,ts.taxon_concept_class_id AS class_id,ts.taxon_concept_class_name AS class_name,ts.taxon_concept_order_id AS order_id,ts.taxon_concept_order_name AS order_name,ts.taxon_concept_family_id AS family_id,ts.taxon_concept_family_name AS family_name,ts.taxon_concept_genus_id AS genus_id,ts.taxon_concept_genus_name AS genus_name,CASE WHEN ts.reported_by_exporter THEN ts.quantity ELSE NULL END AS exporter_reported_quantity,CASE WHEN ts.reported_by_exporter THEN NULL ELSE ts.quantity END AS importer_reported_quantity,unit.id AS unit_id,unit.name_en AS unit,importer.id AS importer_id,importer.iso_code2 AS importer_iso,importer.name_en AS importer,exporter.id AS exporter_id,exporter.iso_code2 AS exporter_iso,exporter.name_en AS exporter,NULL AS origin,purpose.id AS purpose_id,purpose.name_en AS purpose,source.id AS source_id,source.name_en AS source,term.id AS term_id,term.name_en AS term,ts.import_permits_ids AS import_permits,ts.export_permits_ids AS export_permits,ts.origin_permits_ids AS origin_permits,ts.import_permit_number AS import_permit,ts.export_permit_number AS export_permit,ts.origin_permit_number AS origin_permit,'Quota' AS issue_type,'CoP_approved' AS details_of_compliance_issue,'11/06/1997' AS compliance_type_start_date,'Present' AS compliance_type_end_date,'Panthera pardus' AS compliance_type_taxon,ts.taxon_concept_rank_id AS rank_id,'SPECIES' AS rank_name,'500' AS quota_quantity,'Resolution Conf. 10.14 (Rev. CoP16)' AS notes
      FROM trade_shipments_with_taxa_view ts
      
      INNER JOIN geo_entities AS exporter ON exporter.id = ts.exporter_id
      INNER JOIN geo_entities AS importer ON importer.id = ts.importer_id
      LEFT OUTER JOIN trade_codes source ON ts.source_id = source.id
      LEFT OUTER JOIN trade_codes purpose ON ts.purpose_id = purpose.id
      LEFT OUTER JOIN trade_codes unit ON ts.unit_id = unit.id
      LEFT OUTER JOIN trade_codes term ON ts.term_id = term.id
    
      WHERE ts.id IN (
        SELECT UNNEST(sub.ids)
        FROM (
          
          SELECT ARRAY_AGG(ts.id) AS ids
          FROM trade_shipments_with_taxa_view ts
          
          INNER JOIN geo_entities AS exporter ON exporter.id = ts.exporter_id
          LEFT OUTER JOIN trade_codes source ON ts.source_id = source.id
          LEFT OUTER JOIN trade_codes purpose ON ts.purpose_id = purpose.id
          LEFT OUTER JOIN trade_codes unit ON ts.unit_id = unit.id
          LEFT OUTER JOIN trade_codes term ON ts.term_id = term.id
    
          WHERE ts.year >= 1997 AND ts.year <= 2018 AND ts.taxon_concept_id = 8619 AND exporter.iso_code2 = 'TZ' AND TRUE AND term.code IN ('SKI','TRO') AND TRUE AND purpose.code IN ('H','P') AND ts.country_of_origin_id IS NULL
          AND (source.name_en != 'Confiscations/seizures' OR ts.source_id IS NULL)
          GROUP BY year, reported_by_exporter
          HAVING SUM(quantity) > 500
    
        ) sub
      )
      ORDER BY ts.year, ts.taxon_concept_full_name, ts.exporter_id, ts.importer_id
    )
    
    UNION    

    (
      SELECT ts.id AS id,ts.year AS year,ts.appendix AS appendix,ts.taxon_concept_author_year AS author_year,ts.taxon_concept_name_status AS name_status,ts.taxon_concept_id,ts.taxon_concept_full_name AS taxon_name,ts.taxon_concept_phylum_id AS phylum_id,ts.taxon_concept_class_id AS class_id,ts.taxon_concept_class_name AS class_name,ts.taxon_concept_order_id AS order_id,ts.taxon_concept_order_name AS order_name,ts.taxon_concept_family_id AS family_id,ts.taxon_concept_family_name AS family_name,ts.taxon_concept_genus_id AS genus_id,ts.taxon_concept_genus_name AS genus_name,CASE WHEN ts.reported_by_exporter THEN ts.quantity ELSE NULL END AS exporter_reported_quantity,CASE WHEN ts.reported_by_exporter THEN NULL ELSE ts.quantity END AS importer_reported_quantity,unit.id AS unit_id,unit.name_en AS unit,importer.id AS importer_id,importer.iso_code2 AS importer_iso,importer.name_en AS importer,exporter.id AS exporter_id,exporter.iso_code2 AS exporter_iso,exporter.name_en AS exporter,NULL AS origin,purpose.id AS purpose_id,purpose.name_en AS purpose,source.id AS source_id,source.name_en AS source,term.id AS term_id,term.name_en AS term,ts.import_permits_ids AS import_permits,ts.export_permits_ids AS export_permits,ts.origin_permits_ids AS origin_permits,ts.import_permit_number AS import_permit,ts.export_permit_number AS export_permit,ts.origin_permit_number AS origin_permit,'Quota' AS issue_type,'CoP_approved' AS details_of_compliance_issue,'12/06/1997' AS compliance_type_start_date,'Present' AS compliance_type_end_date,'Panthera pardus' AS compliance_type_taxon,ts.taxon_concept_rank_id AS rank_id,'SPECIES' AS rank_name,'300' AS quota_quantity,'Resolution Conf. 10.14 (Rev. CoP16)' AS notes
      FROM trade_shipments_with_taxa_view ts
      
      INNER JOIN geo_entities AS exporter ON exporter.id = ts.exporter_id
      INNER JOIN geo_entities AS importer ON importer.id = ts.importer_id
      LEFT OUTER JOIN trade_codes source ON ts.source_id = source.id
      LEFT OUTER JOIN trade_codes purpose ON ts.purpose_id = purpose.id
      LEFT OUTER JOIN trade_codes unit ON ts.unit_id = unit.id
      LEFT OUTER JOIN trade_codes term ON ts.term_id = term.id
    
      WHERE ts.id IN (
        SELECT UNNEST(sub.ids)
        FROM (
          
          SELECT ARRAY_AGG(ts.id) AS ids
          FROM trade_shipments_with_taxa_view ts
          
          INNER JOIN geo_entities AS exporter ON exporter.id = ts.exporter_id
          LEFT OUTER JOIN trade_codes source ON ts.source_id = source.id
          LEFT OUTER JOIN trade_codes purpose ON ts.purpose_id = purpose.id
          LEFT OUTER JOIN trade_codes unit ON ts.unit_id = unit.id
          LEFT OUTER JOIN trade_codes term ON ts.term_id = term.id
    
          WHERE ts.year >= 1997 AND ts.year <= 2018 AND ts.taxon_concept_id = 8619 AND exporter.iso_code2 = 'ZM' AND TRUE AND term.code IN ('SKI','TRO') AND TRUE AND purpose.code IN ('H','P') AND ts.country_of_origin_id IS NULL
          AND (source.name_en != 'Confiscations/seizures' OR ts.source_id IS NULL)
          GROUP BY year, reported_by_exporter
          HAVING SUM(quantity) > 300
    
        ) sub
      )
      ORDER BY ts.year, ts.taxon_concept_full_name, ts.exporter_id, ts.importer_id
    )
    
    UNION    

    (
      SELECT ts.id AS id,ts.year AS year,ts.appendix AS appendix,ts.taxon_concept_author_year AS author_year,ts.taxon_concept_name_status AS name_status,ts.taxon_concept_id,ts.taxon_concept_full_name AS taxon_name,ts.taxon_concept_phylum_id AS phylum_id,ts.taxon_concept_class_id AS class_id,ts.taxon_concept_class_name AS class_name,ts.taxon_concept_order_id AS order_id,ts.taxon_concept_order_name AS order_name,ts.taxon_concept_family_id AS family_id,ts.taxon_concept_family_name AS family_name,ts.taxon_concept_genus_id AS genus_id,ts.taxon_concept_genus_name AS genus_name,CASE WHEN ts.reported_by_exporter THEN ts.quantity ELSE NULL END AS exporter_reported_quantity,CASE WHEN ts.reported_by_exporter THEN NULL ELSE ts.quantity END AS importer_reported_quantity,unit.id AS unit_id,unit.name_en AS unit,importer.id AS importer_id,importer.iso_code2 AS importer_iso,importer.name_en AS importer,exporter.id AS exporter_id,exporter.iso_code2 AS exporter_iso,exporter.name_en AS exporter,NULL AS origin,purpose.id AS purpose_id,purpose.name_en AS purpose,source.id AS source_id,source.name_en AS source,term.id AS term_id,term.name_en AS term,ts.import_permits_ids AS import_permits,ts.export_permits_ids AS export_permits,ts.origin_permits_ids AS origin_permits,ts.import_permit_number AS import_permit,ts.export_permit_number AS export_permit,ts.origin_permit_number AS origin_permit,'Quota' AS issue_type,'CoP_approved' AS details_of_compliance_issue,'13/06/1997' AS compliance_type_start_date,'Present' AS compliance_type_end_date,'Panthera pardus' AS compliance_type_taxon,ts.taxon_concept_rank_id AS rank_id,'SPECIES' AS rank_name,'500' AS quota_quantity,'Resolution Conf. 10.14 (Rev. CoP16)' AS notes
      FROM trade_shipments_with_taxa_view ts
      
      INNER JOIN geo_entities AS exporter ON exporter.id = ts.exporter_id
      INNER JOIN geo_entities AS importer ON importer.id = ts.importer_id
      LEFT OUTER JOIN trade_codes source ON ts.source_id = source.id
      LEFT OUTER JOIN trade_codes purpose ON ts.purpose_id = purpose.id
      LEFT OUTER JOIN trade_codes unit ON ts.unit_id = unit.id
      LEFT OUTER JOIN trade_codes term ON ts.term_id = term.id
    
      WHERE ts.id IN (
        SELECT UNNEST(sub.ids)
        FROM (
          
          SELECT ARRAY_AGG(ts.id) AS ids
          FROM trade_shipments_with_taxa_view ts
          
          INNER JOIN geo_entities AS exporter ON exporter.id = ts.exporter_id
          LEFT OUTER JOIN trade_codes source ON ts.source_id = source.id
          LEFT OUTER JOIN trade_codes purpose ON ts.purpose_id = purpose.id
          LEFT OUTER JOIN trade_codes unit ON ts.unit_id = unit.id
          LEFT OUTER JOIN trade_codes term ON ts.term_id = term.id
    
          WHERE ts.year >= 1997 AND ts.year <= 2018 AND ts.taxon_concept_id = 8619 AND exporter.iso_code2 = 'ZW' AND TRUE AND term.code IN ('SKI','TRO') AND TRUE AND purpose.code IN ('H','P') AND ts.country_of_origin_id IS NULL
          AND (source.name_en != 'Confiscations/seizures' OR ts.source_id IS NULL)
          GROUP BY year, reported_by_exporter
          HAVING SUM(quantity) > 500
    
        ) sub
      )
      ORDER BY ts.year, ts.taxon_concept_full_name, ts.exporter_id, ts.importer_id
    )
    
    UNION    

    (
      SELECT ts.id AS id,ts.year AS year,ts.appendix AS appendix,ts.taxon_concept_author_year AS author_year,ts.taxon_concept_name_status AS name_status,ts.taxon_concept_id,ts.taxon_concept_full_name AS taxon_name,ts.taxon_concept_phylum_id AS phylum_id,ts.taxon_concept_class_id AS class_id,ts.taxon_concept_class_name AS class_name,ts.taxon_concept_order_id AS order_id,ts.taxon_concept_order_name AS order_name,ts.taxon_concept_family_id AS family_id,ts.taxon_concept_family_name AS family_name,ts.taxon_concept_genus_id AS genus_id,ts.taxon_concept_genus_name AS genus_name,CASE WHEN ts.reported_by_exporter THEN ts.quantity ELSE NULL END AS exporter_reported_quantity,CASE WHEN ts.reported_by_exporter THEN NULL ELSE ts.quantity END AS importer_reported_quantity,unit.id AS unit_id,unit.name_en AS unit,importer.id AS importer_id,importer.iso_code2 AS importer_iso,importer.name_en AS importer,exporter.id AS exporter_id,exporter.iso_code2 AS exporter_iso,exporter.name_en AS exporter,NULL AS origin,purpose.id AS purpose_id,purpose.name_en AS purpose,source.id AS source_id,source.name_en AS source,term.id AS term_id,term.name_en AS term,ts.import_permits_ids AS import_permits,ts.export_permits_ids AS export_permits,ts.origin_permits_ids AS origin_permits,ts.import_permit_number AS import_permit,ts.export_permit_number AS export_permit,ts.origin_permit_number AS origin_permit,'Quota' AS issue_type,'CoP_approved' AS details_of_compliance_issue,'14/06/1997' AS compliance_type_start_date,'Present' AS compliance_type_end_date,'Panthera pardus' AS compliance_type_taxon,ts.taxon_concept_rank_id AS rank_id,'SPECIES' AS rank_name,'130' AS quota_quantity,'Resolution Conf. 10.14 (Rev. CoP16)' AS notes
      FROM trade_shipments_with_taxa_view ts
      
      INNER JOIN geo_entities AS exporter ON exporter.id = ts.exporter_id
      INNER JOIN geo_entities AS importer ON importer.id = ts.importer_id
      LEFT OUTER JOIN trade_codes source ON ts.source_id = source.id
      LEFT OUTER JOIN trade_codes purpose ON ts.purpose_id = purpose.id
      LEFT OUTER JOIN trade_codes unit ON ts.unit_id = unit.id
      LEFT OUTER JOIN trade_codes term ON ts.term_id = term.id
    
      WHERE ts.id IN (
        SELECT UNNEST(sub.ids)
        FROM (
          
          SELECT ARRAY_AGG(ts.id) AS ids
          FROM trade_shipments_with_taxa_view ts
          
          INNER JOIN geo_entities AS exporter ON exporter.id = ts.exporter_id
          LEFT OUTER JOIN trade_codes source ON ts.source_id = source.id
          LEFT OUTER JOIN trade_codes purpose ON ts.purpose_id = purpose.id
          LEFT OUTER JOIN trade_codes unit ON ts.unit_id = unit.id
          LEFT OUTER JOIN trade_codes term ON ts.term_id = term.id
    
          WHERE ts.year >= 1997 AND ts.year <= 2018 AND ts.taxon_concept_id = 8619 AND exporter.iso_code2 = 'BW' AND TRUE AND term.code IN ('SKI','TRO') AND TRUE AND purpose.code IN ('H','P') AND ts.country_of_origin_id IS NULL
          AND (source.name_en != 'Confiscations/seizures' OR ts.source_id IS NULL)
          GROUP BY year, reported_by_exporter
          HAVING SUM(quantity) > 130
    
        ) sub
      )
      ORDER BY ts.year, ts.taxon_concept_full_name, ts.exporter_id, ts.importer_id
    )
    
    UNION    

    (
      SELECT ts.id AS id,ts.year AS year,ts.appendix AS appendix,ts.taxon_concept_author_year AS author_year,ts.taxon_concept_name_status AS name_status,ts.taxon_concept_id,ts.taxon_concept_full_name AS taxon_name,ts.taxon_concept_phylum_id AS phylum_id,ts.taxon_concept_class_id AS class_id,ts.taxon_concept_class_name AS class_name,ts.taxon_concept_order_id AS order_id,ts.taxon_concept_order_name AS order_name,ts.taxon_concept_family_id AS family_id,ts.taxon_concept_family_name AS family_name,ts.taxon_concept_genus_id AS genus_id,ts.taxon_concept_genus_name AS genus_name,CASE WHEN ts.reported_by_exporter THEN ts.quantity ELSE NULL END AS exporter_reported_quantity,CASE WHEN ts.reported_by_exporter THEN NULL ELSE ts.quantity END AS importer_reported_quantity,unit.id AS unit_id,unit.name_en AS unit,importer.id AS importer_id,importer.iso_code2 AS importer_iso,importer.name_en AS importer,exporter.id AS exporter_id,exporter.iso_code2 AS exporter_iso,exporter.name_en AS exporter,NULL AS origin,purpose.id AS purpose_id,purpose.name_en AS purpose,source.id AS source_id,source.name_en AS source,term.id AS term_id,term.name_en AS term,ts.import_permits_ids AS import_permits,ts.export_permits_ids AS export_permits,ts.origin_permits_ids AS origin_permits,ts.import_permit_number AS import_permit,ts.export_permit_number AS export_permit,ts.origin_permit_number AS origin_permit,'Quota' AS issue_type,'CoP_approved' AS details_of_compliance_issue,'15/06/1997' AS compliance_type_start_date,'Present' AS compliance_type_end_date,'Panthera pardus' AS compliance_type_taxon,ts.taxon_concept_rank_id AS rank_id,'SPECIES' AS rank_name,'40' AS quota_quantity,'Resolution Conf. 10.14 (Rev. CoP16)' AS notes
      FROM trade_shipments_with_taxa_view ts
      
      INNER JOIN geo_entities AS exporter ON exporter.id = ts.exporter_id
      INNER JOIN geo_entities AS importer ON importer.id = ts.importer_id
      LEFT OUTER JOIN trade_codes source ON ts.source_id = source.id
      LEFT OUTER JOIN trade_codes purpose ON ts.purpose_id = purpose.id
      LEFT OUTER JOIN trade_codes unit ON ts.unit_id = unit.id
      LEFT OUTER JOIN trade_codes term ON ts.term_id = term.id
    
      WHERE ts.id IN (
        SELECT UNNEST(sub.ids)
        FROM (
          
          SELECT ARRAY_AGG(ts.id) AS ids
          FROM trade_shipments_with_taxa_view ts
          
          INNER JOIN geo_entities AS exporter ON exporter.id = ts.exporter_id
          LEFT OUTER JOIN trade_codes source ON ts.source_id = source.id
          LEFT OUTER JOIN trade_codes purpose ON ts.purpose_id = purpose.id
          LEFT OUTER JOIN trade_codes unit ON ts.unit_id = unit.id
          LEFT OUTER JOIN trade_codes term ON ts.term_id = term.id
    
          WHERE ts.year >= 1997 AND ts.year <= 2018 AND ts.taxon_concept_id = 8619 AND exporter.iso_code2 = 'CF' AND TRUE AND term.code IN ('SKI','TRO') AND TRUE AND purpose.code IN ('H','P') AND ts.country_of_origin_id IS NULL
          AND (source.name_en != 'Confiscations/seizures' OR ts.source_id IS NULL)
          GROUP BY year, reported_by_exporter
          HAVING SUM(quantity) > 40
    
        ) sub
      )
      ORDER BY ts.year, ts.taxon_concept_full_name, ts.exporter_id, ts.importer_id
    )
    
    UNION    

    (
      SELECT ts.id AS id,ts.year AS year,ts.appendix AS appendix,ts.taxon_concept_author_year AS author_year,ts.taxon_concept_name_status AS name_status,ts.taxon_concept_id,ts.taxon_concept_full_name AS taxon_name,ts.taxon_concept_phylum_id AS phylum_id,ts.taxon_concept_class_id AS class_id,ts.taxon_concept_class_name AS class_name,ts.taxon_concept_order_id AS order_id,ts.taxon_concept_order_name AS order_name,ts.taxon_concept_family_id AS family_id,ts.taxon_concept_family_name AS family_name,ts.taxon_concept_genus_id AS genus_id,ts.taxon_concept_genus_name AS genus_name,CASE WHEN ts.reported_by_exporter THEN ts.quantity ELSE NULL END AS exporter_reported_quantity,CASE WHEN ts.reported_by_exporter THEN NULL ELSE ts.quantity END AS importer_reported_quantity,unit.id AS unit_id,unit.name_en AS unit,importer.id AS importer_id,importer.iso_code2 AS importer_iso,importer.name_en AS importer,exporter.id AS exporter_id,exporter.iso_code2 AS exporter_iso,exporter.name_en AS exporter,NULL AS origin,purpose.id AS purpose_id,purpose.name_en AS purpose,source.id AS source_id,source.name_en AS source,term.id AS term_id,term.name_en AS term,ts.import_permits_ids AS import_permits,ts.export_permits_ids AS export_permits,ts.origin_permits_ids AS origin_permits,ts.import_permit_number AS import_permit,ts.export_permit_number AS export_permit,ts.origin_permit_number AS origin_permit,'Quota' AS issue_type,'CoP_approved' AS details_of_compliance_issue,'16/06/1997' AS compliance_type_start_date,'Present' AS compliance_type_end_date,'Panthera pardus' AS compliance_type_taxon,ts.taxon_concept_rank_id AS rank_id,'SPECIES' AS rank_name,'80' AS quota_quantity,'Resolution Conf. 10.14 (Rev. CoP16)' AS notes
      FROM trade_shipments_with_taxa_view ts
      
      INNER JOIN geo_entities AS exporter ON exporter.id = ts.exporter_id
      INNER JOIN geo_entities AS importer ON importer.id = ts.importer_id
      LEFT OUTER JOIN trade_codes source ON ts.source_id = source.id
      LEFT OUTER JOIN trade_codes purpose ON ts.purpose_id = purpose.id
      LEFT OUTER JOIN trade_codes unit ON ts.unit_id = unit.id
      LEFT OUTER JOIN trade_codes term ON ts.term_id = term.id
    
      WHERE ts.id IN (
        SELECT UNNEST(sub.ids)
        FROM (
          
          SELECT ARRAY_AGG(ts.id) AS ids
          FROM trade_shipments_with_taxa_view ts
          
          INNER JOIN geo_entities AS exporter ON exporter.id = ts.exporter_id
          LEFT OUTER JOIN trade_codes source ON ts.source_id = source.id
          LEFT OUTER JOIN trade_codes purpose ON ts.purpose_id = purpose.id
          LEFT OUTER JOIN trade_codes unit ON ts.unit_id = unit.id
          LEFT OUTER JOIN trade_codes term ON ts.term_id = term.id
    
          WHERE ts.year >= 1997 AND ts.year <= 2018 AND ts.taxon_concept_id = 8619 AND exporter.iso_code2 = 'KE' AND TRUE AND term.code IN ('SKI','TRO') AND TRUE AND purpose.code IN ('H','P') AND ts.country_of_origin_id IS NULL
          AND (source.name_en != 'Confiscations/seizures' OR ts.source_id IS NULL)
          GROUP BY year, reported_by_exporter
          HAVING SUM(quantity) > 80
    
        ) sub
      )
      ORDER BY ts.year, ts.taxon_concept_full_name, ts.exporter_id, ts.importer_id
    )
    
    UNION    

    (
      SELECT ts.id AS id,ts.year AS year,ts.appendix AS appendix,ts.taxon_concept_author_year AS author_year,ts.taxon_concept_name_status AS name_status,ts.taxon_concept_id,ts.taxon_concept_full_name AS taxon_name,ts.taxon_concept_phylum_id AS phylum_id,ts.taxon_concept_class_id AS class_id,ts.taxon_concept_class_name AS class_name,ts.taxon_concept_order_id AS order_id,ts.taxon_concept_order_name AS order_name,ts.taxon_concept_family_id AS family_id,ts.taxon_concept_family_name AS family_name,ts.taxon_concept_genus_id AS genus_id,ts.taxon_concept_genus_name AS genus_name,CASE WHEN ts.reported_by_exporter THEN ts.quantity ELSE NULL END AS exporter_reported_quantity,CASE WHEN ts.reported_by_exporter THEN NULL ELSE ts.quantity END AS importer_reported_quantity,unit.id AS unit_id,unit.name_en AS unit,importer.id AS importer_id,importer.iso_code2 AS importer_iso,importer.name_en AS importer,exporter.id AS exporter_id,exporter.iso_code2 AS exporter_iso,exporter.name_en AS exporter,NULL AS origin,purpose.id AS purpose_id,purpose.name_en AS purpose,source.id AS source_id,source.name_en AS source,term.id AS term_id,term.name_en AS term,ts.import_permits_ids AS import_permits,ts.export_permits_ids AS export_permits,ts.origin_permits_ids AS origin_permits,ts.import_permit_number AS import_permit,ts.export_permit_number AS export_permit,ts.origin_permit_number AS origin_permit,'Quota' AS issue_type,'CoP_approved' AS details_of_compliance_issue,'17/06/1997' AS compliance_type_start_date,'Present' AS compliance_type_end_date,'Panthera pardus' AS compliance_type_taxon,ts.taxon_concept_rank_id AS rank_id,'SPECIES' AS rank_name,'50' AS quota_quantity,'Resolution Conf. 10.14 (Rev. CoP16)' AS notes
      FROM trade_shipments_with_taxa_view ts
      
      INNER JOIN geo_entities AS exporter ON exporter.id = ts.exporter_id
      INNER JOIN geo_entities AS importer ON importer.id = ts.importer_id
      LEFT OUTER JOIN trade_codes source ON ts.source_id = source.id
      LEFT OUTER JOIN trade_codes purpose ON ts.purpose_id = purpose.id
      LEFT OUTER JOIN trade_codes unit ON ts.unit_id = unit.id
      LEFT OUTER JOIN trade_codes term ON ts.term_id = term.id
    
      WHERE ts.id IN (
        SELECT UNNEST(sub.ids)
        FROM (
          
          SELECT ARRAY_AGG(ts.id) AS ids
          FROM trade_shipments_with_taxa_view ts
          
          INNER JOIN geo_entities AS exporter ON exporter.id = ts.exporter_id
          LEFT OUTER JOIN trade_codes source ON ts.source_id = source.id
          LEFT OUTER JOIN trade_codes purpose ON ts.purpose_id = purpose.id
          LEFT OUTER JOIN trade_codes unit ON ts.unit_id = unit.id
          LEFT OUTER JOIN trade_codes term ON ts.term_id = term.id
    
          WHERE ts.year >= 1997 AND ts.year <= 2018 AND ts.taxon_concept_id = 8619 AND exporter.iso_code2 = 'MW' AND TRUE AND term.code IN ('SKI','TRO') AND TRUE AND purpose.code IN ('H','P') AND ts.country_of_origin_id IS NULL
          AND (source.name_en != 'Confiscations/seizures' OR ts.source_id IS NULL)
          GROUP BY year, reported_by_exporter
          HAVING SUM(quantity) > 50
    
        ) sub
      )
      ORDER BY ts.year, ts.taxon_concept_full_name, ts.exporter_id, ts.importer_id
    )
    
    UNION    

    (
      SELECT ts.id AS id,ts.year AS year,ts.appendix AS appendix,ts.taxon_concept_author_year AS author_year,ts.taxon_concept_name_status AS name_status,ts.taxon_concept_id,ts.taxon_concept_full_name AS taxon_name,ts.taxon_concept_phylum_id AS phylum_id,ts.taxon_concept_class_id AS class_id,ts.taxon_concept_class_name AS class_name,ts.taxon_concept_order_id AS order_id,ts.taxon_concept_order_name AS order_name,ts.taxon_concept_family_id AS family_id,ts.taxon_concept_family_name AS family_name,ts.taxon_concept_genus_id AS genus_id,ts.taxon_concept_genus_name AS genus_name,CASE WHEN ts.reported_by_exporter THEN ts.quantity ELSE NULL END AS exporter_reported_quantity,CASE WHEN ts.reported_by_exporter THEN NULL ELSE ts.quantity END AS importer_reported_quantity,unit.id AS unit_id,unit.name_en AS unit,importer.id AS importer_id,importer.iso_code2 AS importer_iso,importer.name_en AS importer,exporter.id AS exporter_id,exporter.iso_code2 AS exporter_iso,exporter.name_en AS exporter,NULL AS origin,purpose.id AS purpose_id,purpose.name_en AS purpose,source.id AS source_id,source.name_en AS source,term.id AS term_id,term.name_en AS term,ts.import_permits_ids AS import_permits,ts.export_permits_ids AS export_permits,ts.origin_permits_ids AS origin_permits,ts.import_permit_number AS import_permit,ts.export_permit_number AS export_permit,ts.origin_permit_number AS origin_permit,'Quota' AS issue_type,'CoP_approved' AS details_of_compliance_issue,'18/06/1997' AS compliance_type_start_date,'Present' AS compliance_type_end_date,'Panthera pardus' AS compliance_type_taxon,ts.taxon_concept_rank_id AS rank_id,'SPECIES' AS rank_name,'120' AS quota_quantity,'Resolution Conf. 10.14 (Rev. CoP16)' AS notes
      FROM trade_shipments_with_taxa_view ts
      
      INNER JOIN geo_entities AS exporter ON exporter.id = ts.exporter_id
      INNER JOIN geo_entities AS importer ON importer.id = ts.importer_id
      LEFT OUTER JOIN trade_codes source ON ts.source_id = source.id
      LEFT OUTER JOIN trade_codes purpose ON ts.purpose_id = purpose.id
      LEFT OUTER JOIN trade_codes unit ON ts.unit_id = unit.id
      LEFT OUTER JOIN trade_codes term ON ts.term_id = term.id
    
      WHERE ts.id IN (
        SELECT UNNEST(sub.ids)
        FROM (
          
          SELECT ARRAY_AGG(ts.id) AS ids
          FROM trade_shipments_with_taxa_view ts
          
          INNER JOIN geo_entities AS exporter ON exporter.id = ts.exporter_id
          LEFT OUTER JOIN trade_codes source ON ts.source_id = source.id
          LEFT OUTER JOIN trade_codes purpose ON ts.purpose_id = purpose.id
          LEFT OUTER JOIN trade_codes unit ON ts.unit_id = unit.id
          LEFT OUTER JOIN trade_codes term ON ts.term_id = term.id
    
          WHERE ts.year >= 1997 AND ts.year <= 2018 AND ts.taxon_concept_id = 8619 AND exporter.iso_code2 = 'MZ' AND TRUE AND term.code IN ('SKI','TRO') AND TRUE AND purpose.code IN ('H','P') AND ts.country_of_origin_id IS NULL
          AND (source.name_en != 'Confiscations/seizures' OR ts.source_id IS NULL)
          GROUP BY year, reported_by_exporter
          HAVING SUM(quantity) > 120
    
        ) sub
      )
      ORDER BY ts.year, ts.taxon_concept_full_name, ts.exporter_id, ts.importer_id
    )
    
    UNION    

    (
      SELECT ts.id AS id,ts.year AS year,ts.appendix AS appendix,ts.taxon_concept_author_year AS author_year,ts.taxon_concept_name_status AS name_status,ts.taxon_concept_id,ts.taxon_concept_full_name AS taxon_name,ts.taxon_concept_phylum_id AS phylum_id,ts.taxon_concept_class_id AS class_id,ts.taxon_concept_class_name AS class_name,ts.taxon_concept_order_id AS order_id,ts.taxon_concept_order_name AS order_name,ts.taxon_concept_family_id AS family_id,ts.taxon_concept_family_name AS family_name,ts.taxon_concept_genus_id AS genus_id,ts.taxon_concept_genus_name AS genus_name,CASE WHEN ts.reported_by_exporter THEN ts.quantity ELSE NULL END AS exporter_reported_quantity,CASE WHEN ts.reported_by_exporter THEN NULL ELSE ts.quantity END AS importer_reported_quantity,unit.id AS unit_id,unit.name_en AS unit,importer.id AS importer_id,importer.iso_code2 AS importer_iso,importer.name_en AS importer,exporter.id AS exporter_id,exporter.iso_code2 AS exporter_iso,exporter.name_en AS exporter,NULL AS origin,purpose.id AS purpose_id,purpose.name_en AS purpose,source.id AS source_id,source.name_en AS source,term.id AS term_id,term.name_en AS term,ts.import_permits_ids AS import_permits,ts.export_permits_ids AS export_permits,ts.origin_permits_ids AS origin_permits,ts.import_permit_number AS import_permit,ts.export_permit_number AS export_permit,ts.origin_permit_number AS origin_permit,'Quota' AS issue_type,'CoP_approved' AS details_of_compliance_issue,'19/06/1997' AS compliance_type_start_date,'Present' AS compliance_type_end_date,'Panthera pardus' AS compliance_type_taxon,ts.taxon_concept_rank_id AS rank_id,'SPECIES' AS rank_name,'150' AS quota_quantity,'Resolution Conf. 10.14 (Rev. CoP16)' AS notes
      FROM trade_shipments_with_taxa_view ts
      
      INNER JOIN geo_entities AS exporter ON exporter.id = ts.exporter_id
      INNER JOIN geo_entities AS importer ON importer.id = ts.importer_id
      LEFT OUTER JOIN trade_codes source ON ts.source_id = source.id
      LEFT OUTER JOIN trade_codes purpose ON ts.purpose_id = purpose.id
      LEFT OUTER JOIN trade_codes unit ON ts.unit_id = unit.id
      LEFT OUTER JOIN trade_codes term ON ts.term_id = term.id
    
      WHERE ts.id IN (
        SELECT UNNEST(sub.ids)
        FROM (
          
          SELECT ARRAY_AGG(ts.id) AS ids
          FROM trade_shipments_with_taxa_view ts
          
          INNER JOIN geo_entities AS exporter ON exporter.id = ts.exporter_id
          LEFT OUTER JOIN trade_codes source ON ts.source_id = source.id
          LEFT OUTER JOIN trade_codes purpose ON ts.purpose_id = purpose.id
          LEFT OUTER JOIN trade_codes unit ON ts.unit_id = unit.id
          LEFT OUTER JOIN trade_codes term ON ts.term_id = term.id
    
          WHERE ts.year >= 1997 AND ts.year <= 2018 AND ts.taxon_concept_id = 8619 AND exporter.iso_code2 = 'ZA' AND TRUE AND term.code IN ('SKI','TRO') AND TRUE AND purpose.code IN ('H','P') AND ts.country_of_origin_id IS NULL
          AND (source.name_en != 'Confiscations/seizures' OR ts.source_id IS NULL)
          GROUP BY year, reported_by_exporter
          HAVING SUM(quantity) > 150
    
        ) sub
      )
      ORDER BY ts.year, ts.taxon_concept_full_name, ts.exporter_id, ts.importer_id
    )
    
    UNION    

    (
      SELECT ts.id AS id,ts.year AS year,ts.appendix AS appendix,ts.taxon_concept_author_year AS author_year,ts.taxon_concept_name_status AS name_status,ts.taxon_concept_id,ts.taxon_concept_full_name AS taxon_name,ts.taxon_concept_phylum_id AS phylum_id,ts.taxon_concept_class_id AS class_id,ts.taxon_concept_class_name AS class_name,ts.taxon_concept_order_id AS order_id,ts.taxon_concept_order_name AS order_name,ts.taxon_concept_family_id AS family_id,ts.taxon_concept_family_name AS family_name,ts.taxon_concept_genus_id AS genus_id,ts.taxon_concept_genus_name AS genus_name,CASE WHEN ts.reported_by_exporter THEN ts.quantity ELSE NULL END AS exporter_reported_quantity,CASE WHEN ts.reported_by_exporter THEN NULL ELSE ts.quantity END AS importer_reported_quantity,unit.id AS unit_id,unit.name_en AS unit,importer.id AS importer_id,importer.iso_code2 AS importer_iso,importer.name_en AS importer,exporter.id AS exporter_id,exporter.iso_code2 AS exporter_iso,exporter.name_en AS exporter,NULL AS origin,purpose.id AS purpose_id,purpose.name_en AS purpose,source.id AS source_id,source.name_en AS source,term.id AS term_id,term.name_en AS term,ts.import_permits_ids AS import_permits,ts.export_permits_ids AS export_permits,ts.origin_permits_ids AS origin_permits,ts.import_permit_number AS import_permit,ts.export_permit_number AS export_permit,ts.origin_permit_number AS origin_permit,'Quota' AS issue_type,'CoP_approved' AS details_of_compliance_issue,'20/06/1997' AS compliance_type_start_date,'Present' AS compliance_type_end_date,'Panthera pardus' AS compliance_type_taxon,ts.taxon_concept_rank_id AS rank_id,'SPECIES' AS rank_name,'28' AS quota_quantity,'Resolution Conf. 10.14 (Rev. CoP16)' AS notes
      FROM trade_shipments_with_taxa_view ts
      
      INNER JOIN geo_entities AS exporter ON exporter.id = ts.exporter_id
      INNER JOIN geo_entities AS importer ON importer.id = ts.importer_id
      LEFT OUTER JOIN trade_codes source ON ts.source_id = source.id
      LEFT OUTER JOIN trade_codes purpose ON ts.purpose_id = purpose.id
      LEFT OUTER JOIN trade_codes unit ON ts.unit_id = unit.id
      LEFT OUTER JOIN trade_codes term ON ts.term_id = term.id
    
      WHERE ts.id IN (
        SELECT UNNEST(sub.ids)
        FROM (
          
          SELECT ARRAY_AGG(ts.id) AS ids
          FROM trade_shipments_with_taxa_view ts
          
          INNER JOIN geo_entities AS exporter ON exporter.id = ts.exporter_id
          LEFT OUTER JOIN trade_codes source ON ts.source_id = source.id
          LEFT OUTER JOIN trade_codes purpose ON ts.purpose_id = purpose.id
          LEFT OUTER JOIN trade_codes unit ON ts.unit_id = unit.id
          LEFT OUTER JOIN trade_codes term ON ts.term_id = term.id
    
          WHERE ts.year >= 1997 AND ts.year <= 2018 AND ts.taxon_concept_id = 8619 AND exporter.iso_code2 = 'UG' AND TRUE AND term.code IN ('SKI','TRO') AND TRUE AND purpose.code IN ('H','P') AND ts.country_of_origin_id IS NULL
          AND (source.name_en != 'Confiscations/seizures' OR ts.source_id IS NULL)
          GROUP BY year, reported_by_exporter
          HAVING SUM(quantity) > 28
    
        ) sub
      )
      ORDER BY ts.year, ts.taxon_concept_full_name, ts.exporter_id, ts.importer_id
    )
    
    UNION    

    (
      SELECT ts.id AS id,ts.year AS year,ts.appendix AS appendix,ts.taxon_concept_author_year AS author_year,ts.taxon_concept_name_status AS name_status,ts.taxon_concept_id,ts.taxon_concept_full_name AS taxon_name,ts.taxon_concept_phylum_id AS phylum_id,ts.taxon_concept_class_id AS class_id,ts.taxon_concept_class_name AS class_name,ts.taxon_concept_order_id AS order_id,ts.taxon_concept_order_name AS order_name,ts.taxon_concept_family_id AS family_id,ts.taxon_concept_family_name AS family_name,ts.taxon_concept_genus_id AS genus_id,ts.taxon_concept_genus_name AS genus_name,CASE WHEN ts.reported_by_exporter THEN ts.quantity ELSE NULL END AS exporter_reported_quantity,CASE WHEN ts.reported_by_exporter THEN NULL ELSE ts.quantity END AS importer_reported_quantity,unit.id AS unit_id,unit.name_en AS unit,importer.id AS importer_id,importer.iso_code2 AS importer_iso,importer.name_en AS importer,exporter.id AS exporter_id,exporter.iso_code2 AS exporter_iso,exporter.name_en AS exporter,NULL AS origin,purpose.id AS purpose_id,purpose.name_en AS purpose,source.id AS source_id,source.name_en AS source,term.id AS term_id,term.name_en AS term,ts.import_permits_ids AS import_permits,ts.export_permits_ids AS export_permits,ts.origin_permits_ids AS origin_permits,ts.import_permit_number AS import_permit,ts.export_permit_number AS export_permit,ts.origin_permit_number AS origin_permit,'Quota' AS issue_type,'CoP_approved' AS details_of_compliance_issue,'14/10/2004' AS compliance_type_start_date,'Present' AS compliance_type_end_date,'Diceros bicornis' AS compliance_type_taxon,ts.taxon_concept_rank_id AS rank_id,'SPECIES' AS rank_name,'5' AS quota_quantity,'hunting trophies from adult males [Note: see Resolution Conf. 13.5(Rev.CoP14)]
Res. Conf. 13.5(Rev.CoP14): "AGREES that hunting trophies of the black rhinoceros are defined as the horns or any other durable part of the body, mounted or loose and that all parts to be exported should be individually marked with reference to the country of origin, species, quota number and year of export;"' AS notes
      FROM trade_shipments_with_taxa_view ts
      
      INNER JOIN geo_entities AS exporter ON exporter.id = ts.exporter_id
      INNER JOIN geo_entities AS importer ON importer.id = ts.importer_id
      LEFT OUTER JOIN trade_codes source ON ts.source_id = source.id
      LEFT OUTER JOIN trade_codes purpose ON ts.purpose_id = purpose.id
      LEFT OUTER JOIN trade_codes unit ON ts.unit_id = unit.id
      LEFT OUTER JOIN trade_codes term ON ts.term_id = term.id
    
      WHERE ts.id IN (
        SELECT UNNEST(sub.ids)
        FROM (
          
          SELECT ARRAY_AGG(ts.id) AS ids
          FROM trade_shipments_with_taxa_view ts
          
          INNER JOIN geo_entities AS exporter ON exporter.id = ts.exporter_id
          LEFT OUTER JOIN trade_codes source ON ts.source_id = source.id
          LEFT OUTER JOIN trade_codes purpose ON ts.purpose_id = purpose.id
          LEFT OUTER JOIN trade_codes unit ON ts.unit_id = unit.id
          LEFT OUTER JOIN trade_codes term ON ts.term_id = term.id
    
          WHERE ts.year >= 2004 AND ts.year <= 2018 AND ts.taxon_concept_id = 6656 AND exporter.iso_code2 = 'NA' AND TRUE AND term.code IN ('TRO','SKI','SKU','HOR','BOD','FOO','GEN') AND TRUE AND purpose.code IN ('H','P') AND ts.country_of_origin_id IS NULL
          AND (source.name_en != 'Confiscations/seizures' OR ts.source_id IS NULL)
          GROUP BY year, reported_by_exporter
          HAVING SUM(quantity) > 5
    
        ) sub
      )
      ORDER BY ts.year, ts.taxon_concept_full_name, ts.exporter_id, ts.importer_id
    )
    
    UNION    

    (
      SELECT ts.id AS id,ts.year AS year,ts.appendix AS appendix,ts.taxon_concept_author_year AS author_year,ts.taxon_concept_name_status AS name_status,ts.taxon_concept_id,ts.taxon_concept_full_name AS taxon_name,ts.taxon_concept_phylum_id AS phylum_id,ts.taxon_concept_class_id AS class_id,ts.taxon_concept_class_name AS class_name,ts.taxon_concept_order_id AS order_id,ts.taxon_concept_order_name AS order_name,ts.taxon_concept_family_id AS family_id,ts.taxon_concept_family_name AS family_name,ts.taxon_concept_genus_id AS genus_id,ts.taxon_concept_genus_name AS genus_name,CASE WHEN ts.reported_by_exporter THEN ts.quantity ELSE NULL END AS exporter_reported_quantity,CASE WHEN ts.reported_by_exporter THEN NULL ELSE ts.quantity END AS importer_reported_quantity,unit.id AS unit_id,unit.name_en AS unit,importer.id AS importer_id,importer.iso_code2 AS importer_iso,importer.name_en AS importer,exporter.id AS exporter_id,exporter.iso_code2 AS exporter_iso,exporter.name_en AS exporter,NULL AS origin,purpose.id AS purpose_id,purpose.name_en AS purpose,source.id AS source_id,source.name_en AS source,term.id AS term_id,term.name_en AS term,ts.import_permits_ids AS import_permits,ts.export_permits_ids AS export_permits,ts.origin_permits_ids AS origin_permits,ts.import_permit_number AS import_permit,ts.export_permit_number AS export_permit,ts.origin_permit_number AS origin_permit,'Quota' AS issue_type,'CoP_approved' AS details_of_compliance_issue,'14/10/2004' AS compliance_type_start_date,'Present' AS compliance_type_end_date,'Diceros bicornis' AS compliance_type_taxon,ts.taxon_concept_rank_id AS rank_id,'SPECIES' AS rank_name,'5' AS quota_quantity,'hunting trophies from adult males [Note: see Resolution Conf. 13.5(Rev.CoP14)]' AS notes
      FROM trade_shipments_with_taxa_view ts
      
      INNER JOIN geo_entities AS exporter ON exporter.id = ts.exporter_id
      INNER JOIN geo_entities AS importer ON importer.id = ts.importer_id
      LEFT OUTER JOIN trade_codes source ON ts.source_id = source.id
      LEFT OUTER JOIN trade_codes purpose ON ts.purpose_id = purpose.id
      LEFT OUTER JOIN trade_codes unit ON ts.unit_id = unit.id
      LEFT OUTER JOIN trade_codes term ON ts.term_id = term.id
    
      WHERE ts.id IN (
        SELECT UNNEST(sub.ids)
        FROM (
          
          SELECT ARRAY_AGG(ts.id) AS ids
          FROM trade_shipments_with_taxa_view ts
          
          INNER JOIN geo_entities AS exporter ON exporter.id = ts.exporter_id
          LEFT OUTER JOIN trade_codes source ON ts.source_id = source.id
          LEFT OUTER JOIN trade_codes purpose ON ts.purpose_id = purpose.id
          LEFT OUTER JOIN trade_codes unit ON ts.unit_id = unit.id
          LEFT OUTER JOIN trade_codes term ON ts.term_id = term.id
    
          WHERE ts.year >= 2004 AND ts.year <= 2018 AND ts.taxon_concept_id = 6656 AND exporter.iso_code2 = 'ZA' AND TRUE AND term.code IN ('TRO','SKI','SKU','HOR','BOD','FOO','GEN') AND TRUE AND purpose.code IN ('H','P') AND ts.country_of_origin_id IS NULL
          AND (source.name_en != 'Confiscations/seizures' OR ts.source_id IS NULL)
          GROUP BY year, reported_by_exporter
          HAVING SUM(quantity) > 5
    
        ) sub
      )
      ORDER BY ts.year, ts.taxon_concept_full_name, ts.exporter_id, ts.importer_id
    )
    
    UNION    

    (
      SELECT ts.id AS id,ts.year AS year,ts.appendix AS appendix,ts.taxon_concept_author_year AS author_year,ts.taxon_concept_name_status AS name_status,ts.taxon_concept_id,ts.taxon_concept_full_name AS taxon_name,ts.taxon_concept_phylum_id AS phylum_id,ts.taxon_concept_class_id AS class_id,ts.taxon_concept_class_name AS class_name,ts.taxon_concept_order_id AS order_id,ts.taxon_concept_order_name AS order_name,ts.taxon_concept_family_id AS family_id,ts.taxon_concept_family_name AS family_name,ts.taxon_concept_genus_id AS genus_id,ts.taxon_concept_genus_name AS genus_name,CASE WHEN ts.reported_by_exporter THEN ts.quantity ELSE NULL END AS exporter_reported_quantity,CASE WHEN ts.reported_by_exporter THEN NULL ELSE ts.quantity END AS importer_reported_quantity,unit.id AS unit_id,unit.name_en AS unit,importer.id AS importer_id,importer.iso_code2 AS importer_iso,importer.name_en AS importer,exporter.id AS exporter_id,exporter.iso_code2 AS exporter_iso,exporter.name_en AS exporter,NULL AS origin,purpose.id AS purpose_id,purpose.name_en AS purpose,source.id AS source_id,source.name_en AS source,term.id AS term_id,term.name_en AS term,ts.import_permits_ids AS import_permits,ts.export_permits_ids AS export_permits,ts.origin_permits_ids AS origin_permits,ts.import_permit_number AS import_permit,ts.export_permit_number AS export_permit,ts.origin_permit_number AS origin_permit,'Quota' AS issue_type,'CoP_approved' AS details_of_compliance_issue,' 01/07/1975' AS compliance_type_start_date,'Present' AS compliance_type_end_date,'Acinonyx jubatus' AS compliance_type_taxon,ts.taxon_concept_rank_id AS rank_id,'SPECIES' AS rank_name,'5' AS quota_quantity,'live and trophies' AS notes
      FROM trade_shipments_with_taxa_view ts
      
      INNER JOIN geo_entities AS exporter ON exporter.id = ts.exporter_id
      INNER JOIN geo_entities AS importer ON importer.id = ts.importer_id
      LEFT OUTER JOIN trade_codes source ON ts.source_id = source.id
      LEFT OUTER JOIN trade_codes purpose ON ts.purpose_id = purpose.id
      LEFT OUTER JOIN trade_codes unit ON ts.unit_id = unit.id
      LEFT OUTER JOIN trade_codes term ON ts.term_id = term.id
    
      WHERE ts.id IN (
        SELECT UNNEST(sub.ids)
        FROM (
          
          SELECT ARRAY_AGG(ts.id) AS ids
          FROM trade_shipments_with_taxa_view ts
          
          INNER JOIN geo_entities AS exporter ON exporter.id = ts.exporter_id
          LEFT OUTER JOIN trade_codes source ON ts.source_id = source.id
          LEFT OUTER JOIN trade_codes purpose ON ts.purpose_id = purpose.id
          LEFT OUTER JOIN trade_codes unit ON ts.unit_id = unit.id
          LEFT OUTER JOIN trade_codes term ON ts.term_id = term.id
    
          WHERE ts.year >= 1975 AND ts.year <= 2018 AND ts.taxon_concept_id = 8935 AND exporter.iso_code2 = 'BW' AND TRUE AND term.code IN ('LIV','TRO') AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL
          AND (source.name_en != 'Confiscations/seizures' OR ts.source_id IS NULL)
          GROUP BY year, reported_by_exporter
          HAVING SUM(quantity) > 5
    
        ) sub
      )
      ORDER BY ts.year, ts.taxon_concept_full_name, ts.exporter_id, ts.importer_id
    )
    
    UNION    

    (
      SELECT ts.id AS id,ts.year AS year,ts.appendix AS appendix,ts.taxon_concept_author_year AS author_year,ts.taxon_concept_name_status AS name_status,ts.taxon_concept_id,ts.taxon_concept_full_name AS taxon_name,ts.taxon_concept_phylum_id AS phylum_id,ts.taxon_concept_class_id AS class_id,ts.taxon_concept_class_name AS class_name,ts.taxon_concept_order_id AS order_id,ts.taxon_concept_order_name AS order_name,ts.taxon_concept_family_id AS family_id,ts.taxon_concept_family_name AS family_name,ts.taxon_concept_genus_id AS genus_id,ts.taxon_concept_genus_name AS genus_name,CASE WHEN ts.reported_by_exporter THEN ts.quantity ELSE NULL END AS exporter_reported_quantity,CASE WHEN ts.reported_by_exporter THEN NULL ELSE ts.quantity END AS importer_reported_quantity,unit.id AS unit_id,unit.name_en AS unit,importer.id AS importer_id,importer.iso_code2 AS importer_iso,importer.name_en AS importer,exporter.id AS exporter_id,exporter.iso_code2 AS exporter_iso,exporter.name_en AS exporter,NULL AS origin,purpose.id AS purpose_id,purpose.name_en AS purpose,source.id AS source_id,source.name_en AS source,term.id AS term_id,term.name_en AS term,ts.import_permits_ids AS import_permits,ts.export_permits_ids AS export_permits,ts.origin_permits_ids AS origin_permits,ts.import_permit_number AS import_permit,ts.export_permit_number AS export_permit,ts.origin_permit_number AS origin_permit,'Quota' AS issue_type,'CoP_approved' AS details_of_compliance_issue,' 01/07/1975' AS compliance_type_start_date,'Present' AS compliance_type_end_date,'Acinonyx jubatus' AS compliance_type_taxon,ts.taxon_concept_rank_id AS rank_id,'SPECIES' AS rank_name,'150' AS quota_quantity,'trophies (skins) and live specimens (Note: see annotation to this species included in Appendix I)' AS notes
      FROM trade_shipments_with_taxa_view ts
      
      INNER JOIN geo_entities AS exporter ON exporter.id = ts.exporter_id
      INNER JOIN geo_entities AS importer ON importer.id = ts.importer_id
      LEFT OUTER JOIN trade_codes source ON ts.source_id = source.id
      LEFT OUTER JOIN trade_codes purpose ON ts.purpose_id = purpose.id
      LEFT OUTER JOIN trade_codes unit ON ts.unit_id = unit.id
      LEFT OUTER JOIN trade_codes term ON ts.term_id = term.id
    
      WHERE ts.id IN (
        SELECT UNNEST(sub.ids)
        FROM (
          
          SELECT ARRAY_AGG(ts.id) AS ids
          FROM trade_shipments_with_taxa_view ts
          
          INNER JOIN geo_entities AS exporter ON exporter.id = ts.exporter_id
          LEFT OUTER JOIN trade_codes source ON ts.source_id = source.id
          LEFT OUTER JOIN trade_codes purpose ON ts.purpose_id = purpose.id
          LEFT OUTER JOIN trade_codes unit ON ts.unit_id = unit.id
          LEFT OUTER JOIN trade_codes term ON ts.term_id = term.id
    
          WHERE ts.year >= 1975 AND ts.year <= 2018 AND ts.taxon_concept_id = 8935 AND exporter.iso_code2 = 'NA' AND TRUE AND term.code IN ('SKI','LIV','TRO') AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL
          AND (source.name_en != 'Confiscations/seizures' OR ts.source_id IS NULL)
          GROUP BY year, reported_by_exporter
          HAVING SUM(quantity) > 150
    
        ) sub
      )
      ORDER BY ts.year, ts.taxon_concept_full_name, ts.exporter_id, ts.importer_id
    )
    
    UNION    

    (
      SELECT ts.id AS id,ts.year AS year,ts.appendix AS appendix,ts.taxon_concept_author_year AS author_year,ts.taxon_concept_name_status AS name_status,ts.taxon_concept_id,ts.taxon_concept_full_name AS taxon_name,ts.taxon_concept_phylum_id AS phylum_id,ts.taxon_concept_class_id AS class_id,ts.taxon_concept_class_name AS class_name,ts.taxon_concept_order_id AS order_id,ts.taxon_concept_order_name AS order_name,ts.taxon_concept_family_id AS family_id,ts.taxon_concept_family_name AS family_name,ts.taxon_concept_genus_id AS genus_id,ts.taxon_concept_genus_name AS genus_name,CASE WHEN ts.reported_by_exporter THEN ts.quantity ELSE NULL END AS exporter_reported_quantity,CASE WHEN ts.reported_by_exporter THEN NULL ELSE ts.quantity END AS importer_reported_quantity,unit.id AS unit_id,unit.name_en AS unit,importer.id AS importer_id,importer.iso_code2 AS importer_iso,importer.name_en AS importer,exporter.id AS exporter_id,exporter.iso_code2 AS exporter_iso,exporter.name_en AS exporter,NULL AS origin,purpose.id AS purpose_id,purpose.name_en AS purpose,source.id AS source_id,source.name_en AS source,term.id AS term_id,term.name_en AS term,ts.import_permits_ids AS import_permits,ts.export_permits_ids AS export_permits,ts.origin_permits_ids AS origin_permits,ts.import_permit_number AS import_permit,ts.export_permit_number AS export_permit,ts.origin_permit_number AS origin_permit,'Quota' AS issue_type,'CoP_approved' AS details_of_compliance_issue,' 01/07/1975' AS compliance_type_start_date,'Present' AS compliance_type_end_date,'Acinonyx jubatus' AS compliance_type_taxon,ts.taxon_concept_rank_id AS rank_id,'SPECIES' AS rank_name,'50' AS quota_quantity,'live and trophies (Note: see annotation to this species included in Appendix I)' AS notes
      FROM trade_shipments_with_taxa_view ts
      
      INNER JOIN geo_entities AS exporter ON exporter.id = ts.exporter_id
      INNER JOIN geo_entities AS importer ON importer.id = ts.importer_id
      LEFT OUTER JOIN trade_codes source ON ts.source_id = source.id
      LEFT OUTER JOIN trade_codes purpose ON ts.purpose_id = purpose.id
      LEFT OUTER JOIN trade_codes unit ON ts.unit_id = unit.id
      LEFT OUTER JOIN trade_codes term ON ts.term_id = term.id
    
      WHERE ts.id IN (
        SELECT UNNEST(sub.ids)
        FROM (
          
          SELECT ARRAY_AGG(ts.id) AS ids
          FROM trade_shipments_with_taxa_view ts
          
          INNER JOIN geo_entities AS exporter ON exporter.id = ts.exporter_id
          LEFT OUTER JOIN trade_codes source ON ts.source_id = source.id
          LEFT OUTER JOIN trade_codes purpose ON ts.purpose_id = purpose.id
          LEFT OUTER JOIN trade_codes unit ON ts.unit_id = unit.id
          LEFT OUTER JOIN trade_codes term ON ts.term_id = term.id
    
          WHERE ts.year >= 1975 AND ts.year <= 2018 AND ts.taxon_concept_id = 8935 AND exporter.iso_code2 = 'ZW' AND TRUE AND term.code IN ('LIV','TRO') AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL
          AND (source.name_en != 'Confiscations/seizures' OR ts.source_id IS NULL)
          GROUP BY year, reported_by_exporter
          HAVING SUM(quantity) > 50
    
        ) sub
      )
      ORDER BY ts.year, ts.taxon_concept_full_name, ts.exporter_id, ts.importer_id
    )
    
    UNION    

    (
      SELECT ts.id AS id,ts.year AS year,ts.appendix AS appendix,ts.taxon_concept_author_year AS author_year,ts.taxon_concept_name_status AS name_status,ts.taxon_concept_id,ts.taxon_concept_full_name AS taxon_name,ts.taxon_concept_phylum_id AS phylum_id,ts.taxon_concept_class_id AS class_id,ts.taxon_concept_class_name AS class_name,ts.taxon_concept_order_id AS order_id,ts.taxon_concept_order_name AS order_name,ts.taxon_concept_family_id AS family_id,ts.taxon_concept_family_name AS family_name,ts.taxon_concept_genus_id AS genus_id,ts.taxon_concept_genus_name AS genus_name,CASE WHEN ts.reported_by_exporter THEN ts.quantity ELSE NULL END AS exporter_reported_quantity,CASE WHEN ts.reported_by_exporter THEN NULL ELSE ts.quantity END AS importer_reported_quantity,unit.id AS unit_id,unit.name_en AS unit,importer.id AS importer_id,importer.iso_code2 AS importer_iso,importer.name_en AS importer,exporter.id AS exporter_id,exporter.iso_code2 AS exporter_iso,exporter.name_en AS exporter,NULL AS origin,purpose.id AS purpose_id,purpose.name_en AS purpose,source.id AS source_id,source.name_en AS source,term.id AS term_id,term.name_en AS term,ts.import_permits_ids AS import_permits,ts.export_permits_ids AS export_permits,ts.origin_permits_ids AS origin_permits,ts.import_permit_number AS import_permit,ts.export_permit_number AS export_permit,ts.origin_permit_number AS origin_permit,'Quota' AS issue_type,'Listing_annotations' AS details_of_compliance_issue,'02/01/2017' AS compliance_type_start_date,'Present' AS compliance_type_end_date,'Panthera leo' AS compliance_type_taxon,ts.taxon_concept_rank_id AS rank_id,'SPECIES' AS rank_name,'0' AS quota_quantity,'**II** [FAMILY listing Felidae spp.] For Panthera leo (African populations): a zero annual export quota is established for specimens of bones, bone pieces, bone products, claws, skeletons, skulls and teeth removed from the wild and traded for commercial purposes. Annual export quotas for trade in bones, bone pieces, bone products, claws, skeletons, skulls and teeth for commercial purposes, derived from captive breeding operations in South Africa, will be established and communicated annually to the CITES Secretariat.' AS notes
      FROM trade_shipments_with_taxa_view ts
      
      INNER JOIN geo_entities AS exporter ON exporter.id = ts.exporter_id
      INNER JOIN geo_entities AS importer ON importer.id = ts.importer_id
      LEFT OUTER JOIN trade_codes source ON ts.source_id = source.id
      LEFT OUTER JOIN trade_codes purpose ON ts.purpose_id = purpose.id
      LEFT OUTER JOIN trade_codes unit ON ts.unit_id = unit.id
      LEFT OUTER JOIN trade_codes term ON ts.term_id = term.id
    
      WHERE ts.id IN (
        SELECT UNNEST(sub.ids)
        FROM (
          
          SELECT ARRAY_AGG(ts.id) AS ids
          FROM trade_shipments_with_taxa_view ts
          
          INNER JOIN geo_entities AS exporter ON exporter.id = ts.exporter_id
          LEFT OUTER JOIN trade_codes source ON ts.source_id = source.id
          LEFT OUTER JOIN trade_codes purpose ON ts.purpose_id = purpose.id
          LEFT OUTER JOIN trade_codes unit ON ts.unit_id = unit.id
          LEFT OUTER JOIN trade_codes term ON ts.term_id = term.id
    
          WHERE ts.year >= 2017 AND ts.year <= 2018 AND ts.taxon_concept_id = 6353 AND TRUE AND TRUE AND term.code IN ('BON','BOP','BPR','CLA','SKE','SKU','TEE') AND source.code IN ('W') AND purpose.code IN ('T') AND ts.country_of_origin_id IS NULL
          AND (source.name_en != 'Confiscations/seizures' OR ts.source_id IS NULL)
          GROUP BY year, reported_by_exporter
          HAVING SUM(quantity) > 0
    
        ) sub
      )
      ORDER BY ts.year, ts.taxon_concept_full_name, ts.exporter_id, ts.importer_id
    )
    
    UNION    

    (
      SELECT ts.id AS id,ts.year AS year,ts.appendix AS appendix,ts.taxon_concept_author_year AS author_year,ts.taxon_concept_name_status AS name_status,ts.taxon_concept_id,ts.taxon_concept_full_name AS taxon_name,ts.taxon_concept_phylum_id AS phylum_id,ts.taxon_concept_class_id AS class_id,ts.taxon_concept_class_name AS class_name,ts.taxon_concept_order_id AS order_id,ts.taxon_concept_order_name AS order_name,ts.taxon_concept_family_id AS family_id,ts.taxon_concept_family_name AS family_name,ts.taxon_concept_genus_id AS genus_id,ts.taxon_concept_genus_name AS genus_name,CASE WHEN ts.reported_by_exporter THEN ts.quantity ELSE NULL END AS exporter_reported_quantity,CASE WHEN ts.reported_by_exporter THEN NULL ELSE ts.quantity END AS importer_reported_quantity,unit.id AS unit_id,unit.name_en AS unit,importer.id AS importer_id,importer.iso_code2 AS importer_iso,importer.name_en AS importer,exporter.id AS exporter_id,exporter.iso_code2 AS exporter_iso,exporter.name_en AS exporter,NULL AS origin,purpose.id AS purpose_id,purpose.name_en AS purpose,source.id AS source_id,source.name_en AS source,term.id AS term_id,term.name_en AS term,ts.import_permits_ids AS import_permits,ts.export_permits_ids AS export_permits,ts.origin_permits_ids AS origin_permits,ts.import_permit_number AS import_permit,ts.export_permit_number AS export_permit,ts.origin_permit_number AS origin_permit,'Quota' AS issue_type,'Listing_annotations' AS details_of_compliance_issue,' 13/02/2003' AS compliance_type_start_date,'Present' AS compliance_type_end_date,'Tursiops truncatus' AS compliance_type_taxon,ts.taxon_concept_rank_id AS rank_id,'SPECIES' AS rank_name,'0' AS quota_quantity,'**II** [ORDER listing Cetacea spp.] Included in Appendix II, except for the species included in Appendix I. A zero annual export quota has been established for live specimens from the Black Sea population of Tursiops truncatus removed from the wild and traded for primarily commercial purposes.' AS notes
      FROM trade_shipments_with_taxa_view ts
      
      INNER JOIN geo_entities AS exporter ON exporter.id = ts.exporter_id
      INNER JOIN geo_entities AS importer ON importer.id = ts.importer_id
      LEFT OUTER JOIN trade_codes source ON ts.source_id = source.id
      LEFT OUTER JOIN trade_codes purpose ON ts.purpose_id = purpose.id
      LEFT OUTER JOIN trade_codes unit ON ts.unit_id = unit.id
      LEFT OUTER JOIN trade_codes term ON ts.term_id = term.id
    
      WHERE ts.id IN (
        SELECT UNNEST(sub.ids)
        FROM (
          
          SELECT ARRAY_AGG(ts.id) AS ids
          FROM trade_shipments_with_taxa_view ts
          
          INNER JOIN geo_entities AS exporter ON exporter.id = ts.exporter_id
          LEFT OUTER JOIN trade_codes source ON ts.source_id = source.id
          LEFT OUTER JOIN trade_codes purpose ON ts.purpose_id = purpose.id
          LEFT OUTER JOIN trade_codes unit ON ts.unit_id = unit.id
          LEFT OUTER JOIN trade_codes term ON ts.term_id = term.id
    
          WHERE ts.year >= 2003 AND ts.year <= 2018 AND ts.taxon_concept_id = 7086 AND exporter.iso_code2 = 'BG' AND TRUE AND term.code IN ('LIV') AND source.code IN ('W') AND purpose.code IN ('T') AND ts.country_of_origin_id IS NULL
          AND (source.name_en != 'Confiscations/seizures' OR ts.source_id IS NULL)
          GROUP BY year, reported_by_exporter
          HAVING SUM(quantity) > 0
    
        ) sub
      )
      ORDER BY ts.year, ts.taxon_concept_full_name, ts.exporter_id, ts.importer_id
    )
    
    UNION    

    (
      SELECT ts.id AS id,ts.year AS year,ts.appendix AS appendix,ts.taxon_concept_author_year AS author_year,ts.taxon_concept_name_status AS name_status,ts.taxon_concept_id,ts.taxon_concept_full_name AS taxon_name,ts.taxon_concept_phylum_id AS phylum_id,ts.taxon_concept_class_id AS class_id,ts.taxon_concept_class_name AS class_name,ts.taxon_concept_order_id AS order_id,ts.taxon_concept_order_name AS order_name,ts.taxon_concept_family_id AS family_id,ts.taxon_concept_family_name AS family_name,ts.taxon_concept_genus_id AS genus_id,ts.taxon_concept_genus_name AS genus_name,CASE WHEN ts.reported_by_exporter THEN ts.quantity ELSE NULL END AS exporter_reported_quantity,CASE WHEN ts.reported_by_exporter THEN NULL ELSE ts.quantity END AS importer_reported_quantity,unit.id AS unit_id,unit.name_en AS unit,importer.id AS importer_id,importer.iso_code2 AS importer_iso,importer.name_en AS importer,exporter.id AS exporter_id,exporter.iso_code2 AS exporter_iso,exporter.name_en AS exporter,NULL AS origin,purpose.id AS purpose_id,purpose.name_en AS purpose,source.id AS source_id,source.name_en AS source,term.id AS term_id,term.name_en AS term,ts.import_permits_ids AS import_permits,ts.export_permits_ids AS export_permits,ts.origin_permits_ids AS origin_permits,ts.import_permit_number AS import_permit,ts.export_permit_number AS export_permit,ts.origin_permit_number AS origin_permit,'Quota' AS issue_type,'Listing_annotations' AS details_of_compliance_issue,' 13/02/2003' AS compliance_type_start_date,'Present' AS compliance_type_end_date,'Tursiops truncatus' AS compliance_type_taxon,ts.taxon_concept_rank_id AS rank_id,'SPECIES' AS rank_name,'0' AS quota_quantity,'**II** [ORDER listing Cetacea spp.] Included in Appendix II, except for the species included in Appendix I. A zero annual export quota has been established for live specimens from the Black Sea population of Tursiops truncatus removed from the wild and traded for primarily commercial purposes.' AS notes
      FROM trade_shipments_with_taxa_view ts
      
      INNER JOIN geo_entities AS exporter ON exporter.id = ts.exporter_id
      INNER JOIN geo_entities AS importer ON importer.id = ts.importer_id
      LEFT OUTER JOIN trade_codes source ON ts.source_id = source.id
      LEFT OUTER JOIN trade_codes purpose ON ts.purpose_id = purpose.id
      LEFT OUTER JOIN trade_codes unit ON ts.unit_id = unit.id
      LEFT OUTER JOIN trade_codes term ON ts.term_id = term.id
    
      WHERE ts.id IN (
        SELECT UNNEST(sub.ids)
        FROM (
          
          SELECT ARRAY_AGG(ts.id) AS ids
          FROM trade_shipments_with_taxa_view ts
          
          INNER JOIN geo_entities AS exporter ON exporter.id = ts.exporter_id
          LEFT OUTER JOIN trade_codes source ON ts.source_id = source.id
          LEFT OUTER JOIN trade_codes purpose ON ts.purpose_id = purpose.id
          LEFT OUTER JOIN trade_codes unit ON ts.unit_id = unit.id
          LEFT OUTER JOIN trade_codes term ON ts.term_id = term.id
    
          WHERE ts.year >= 2003 AND ts.year <= 2018 AND ts.taxon_concept_id = 7086 AND exporter.iso_code2 = 'GE' AND TRUE AND term.code IN ('LIV') AND source.code IN ('W') AND purpose.code IN ('T') AND ts.country_of_origin_id IS NULL
          AND (source.name_en != 'Confiscations/seizures' OR ts.source_id IS NULL)
          GROUP BY year, reported_by_exporter
          HAVING SUM(quantity) > 0
    
        ) sub
      )
      ORDER BY ts.year, ts.taxon_concept_full_name, ts.exporter_id, ts.importer_id
    )
    
    UNION    

    (
      SELECT ts.id AS id,ts.year AS year,ts.appendix AS appendix,ts.taxon_concept_author_year AS author_year,ts.taxon_concept_name_status AS name_status,ts.taxon_concept_id,ts.taxon_concept_full_name AS taxon_name,ts.taxon_concept_phylum_id AS phylum_id,ts.taxon_concept_class_id AS class_id,ts.taxon_concept_class_name AS class_name,ts.taxon_concept_order_id AS order_id,ts.taxon_concept_order_name AS order_name,ts.taxon_concept_family_id AS family_id,ts.taxon_concept_family_name AS family_name,ts.taxon_concept_genus_id AS genus_id,ts.taxon_concept_genus_name AS genus_name,CASE WHEN ts.reported_by_exporter THEN ts.quantity ELSE NULL END AS exporter_reported_quantity,CASE WHEN ts.reported_by_exporter THEN NULL ELSE ts.quantity END AS importer_reported_quantity,unit.id AS unit_id,unit.name_en AS unit,importer.id AS importer_id,importer.iso_code2 AS importer_iso,importer.name_en AS importer,exporter.id AS exporter_id,exporter.iso_code2 AS exporter_iso,exporter.name_en AS exporter,NULL AS origin,purpose.id AS purpose_id,purpose.name_en AS purpose,source.id AS source_id,source.name_en AS source,term.id AS term_id,term.name_en AS term,ts.import_permits_ids AS import_permits,ts.export_permits_ids AS export_permits,ts.origin_permits_ids AS origin_permits,ts.import_permit_number AS import_permit,ts.export_permit_number AS export_permit,ts.origin_permit_number AS origin_permit,'Quota' AS issue_type,'Listing_annotations' AS details_of_compliance_issue,' 13/02/2003' AS compliance_type_start_date,'Present' AS compliance_type_end_date,'Tursiops truncatus' AS compliance_type_taxon,ts.taxon_concept_rank_id AS rank_id,'SPECIES' AS rank_name,'0' AS quota_quantity,'**II** [ORDER listing Cetacea spp.] Included in Appendix II, except for the species included in Appendix I. A zero annual export quota has been established for live specimens from the Black Sea population of Tursiops truncatus removed from the wild and traded for primarily commercial purposes.' AS notes
      FROM trade_shipments_with_taxa_view ts
      
      INNER JOIN geo_entities AS exporter ON exporter.id = ts.exporter_id
      INNER JOIN geo_entities AS importer ON importer.id = ts.importer_id
      LEFT OUTER JOIN trade_codes source ON ts.source_id = source.id
      LEFT OUTER JOIN trade_codes purpose ON ts.purpose_id = purpose.id
      LEFT OUTER JOIN trade_codes unit ON ts.unit_id = unit.id
      LEFT OUTER JOIN trade_codes term ON ts.term_id = term.id
    
      WHERE ts.id IN (
        SELECT UNNEST(sub.ids)
        FROM (
          
          SELECT ARRAY_AGG(ts.id) AS ids
          FROM trade_shipments_with_taxa_view ts
          
          INNER JOIN geo_entities AS exporter ON exporter.id = ts.exporter_id
          LEFT OUTER JOIN trade_codes source ON ts.source_id = source.id
          LEFT OUTER JOIN trade_codes purpose ON ts.purpose_id = purpose.id
          LEFT OUTER JOIN trade_codes unit ON ts.unit_id = unit.id
          LEFT OUTER JOIN trade_codes term ON ts.term_id = term.id
    
          WHERE ts.year >= 2003 AND ts.year <= 2018 AND ts.taxon_concept_id = 7086 AND exporter.iso_code2 = 'RO' AND TRUE AND term.code IN ('LIV') AND source.code IN ('W') AND purpose.code IN ('T') AND ts.country_of_origin_id IS NULL
          AND (source.name_en != 'Confiscations/seizures' OR ts.source_id IS NULL)
          GROUP BY year, reported_by_exporter
          HAVING SUM(quantity) > 0
    
        ) sub
      )
      ORDER BY ts.year, ts.taxon_concept_full_name, ts.exporter_id, ts.importer_id
    )
    
    UNION    

    (
      SELECT ts.id AS id,ts.year AS year,ts.appendix AS appendix,ts.taxon_concept_author_year AS author_year,ts.taxon_concept_name_status AS name_status,ts.taxon_concept_id,ts.taxon_concept_full_name AS taxon_name,ts.taxon_concept_phylum_id AS phylum_id,ts.taxon_concept_class_id AS class_id,ts.taxon_concept_class_name AS class_name,ts.taxon_concept_order_id AS order_id,ts.taxon_concept_order_name AS order_name,ts.taxon_concept_family_id AS family_id,ts.taxon_concept_family_name AS family_name,ts.taxon_concept_genus_id AS genus_id,ts.taxon_concept_genus_name AS genus_name,CASE WHEN ts.reported_by_exporter THEN ts.quantity ELSE NULL END AS exporter_reported_quantity,CASE WHEN ts.reported_by_exporter THEN NULL ELSE ts.quantity END AS importer_reported_quantity,unit.id AS unit_id,unit.name_en AS unit,importer.id AS importer_id,importer.iso_code2 AS importer_iso,importer.name_en AS importer,exporter.id AS exporter_id,exporter.iso_code2 AS exporter_iso,exporter.name_en AS exporter,NULL AS origin,purpose.id AS purpose_id,purpose.name_en AS purpose,source.id AS source_id,source.name_en AS source,term.id AS term_id,term.name_en AS term,ts.import_permits_ids AS import_permits,ts.export_permits_ids AS export_permits,ts.origin_permits_ids AS origin_permits,ts.import_permit_number AS import_permit,ts.export_permit_number AS export_permit,ts.origin_permit_number AS origin_permit,'Quota' AS issue_type,'Listing_annotations' AS details_of_compliance_issue,' 13/02/2003' AS compliance_type_start_date,'Present' AS compliance_type_end_date,'Tursiops truncatus' AS compliance_type_taxon,ts.taxon_concept_rank_id AS rank_id,'SPECIES' AS rank_name,'0' AS quota_quantity,'**II** [ORDER listing Cetacea spp.] Included in Appendix II, except for the species included in Appendix I. A zero annual export quota has been established for live specimens from the Black Sea population of Tursiops truncatus removed from the wild and traded for primarily commercial purposes.' AS notes
      FROM trade_shipments_with_taxa_view ts
      
      INNER JOIN geo_entities AS exporter ON exporter.id = ts.exporter_id
      INNER JOIN geo_entities AS importer ON importer.id = ts.importer_id
      LEFT OUTER JOIN trade_codes source ON ts.source_id = source.id
      LEFT OUTER JOIN trade_codes purpose ON ts.purpose_id = purpose.id
      LEFT OUTER JOIN trade_codes unit ON ts.unit_id = unit.id
      LEFT OUTER JOIN trade_codes term ON ts.term_id = term.id
    
      WHERE ts.id IN (
        SELECT UNNEST(sub.ids)
        FROM (
          
          SELECT ARRAY_AGG(ts.id) AS ids
          FROM trade_shipments_with_taxa_view ts
          
          INNER JOIN geo_entities AS exporter ON exporter.id = ts.exporter_id
          LEFT OUTER JOIN trade_codes source ON ts.source_id = source.id
          LEFT OUTER JOIN trade_codes purpose ON ts.purpose_id = purpose.id
          LEFT OUTER JOIN trade_codes unit ON ts.unit_id = unit.id
          LEFT OUTER JOIN trade_codes term ON ts.term_id = term.id
    
          WHERE ts.year >= 2003 AND ts.year <= 2018 AND ts.taxon_concept_id = 7086 AND exporter.iso_code2 = 'RU' AND TRUE AND term.code IN ('LIV') AND source.code IN ('W') AND purpose.code IN ('T') AND ts.country_of_origin_id IS NULL
          AND (source.name_en != 'Confiscations/seizures' OR ts.source_id IS NULL)
          GROUP BY year, reported_by_exporter
          HAVING SUM(quantity) > 0
    
        ) sub
      )
      ORDER BY ts.year, ts.taxon_concept_full_name, ts.exporter_id, ts.importer_id
    )
    
    UNION    

    (
      SELECT ts.id AS id,ts.year AS year,ts.appendix AS appendix,ts.taxon_concept_author_year AS author_year,ts.taxon_concept_name_status AS name_status,ts.taxon_concept_id,ts.taxon_concept_full_name AS taxon_name,ts.taxon_concept_phylum_id AS phylum_id,ts.taxon_concept_class_id AS class_id,ts.taxon_concept_class_name AS class_name,ts.taxon_concept_order_id AS order_id,ts.taxon_concept_order_name AS order_name,ts.taxon_concept_family_id AS family_id,ts.taxon_concept_family_name AS family_name,ts.taxon_concept_genus_id AS genus_id,ts.taxon_concept_genus_name AS genus_name,CASE WHEN ts.reported_by_exporter THEN ts.quantity ELSE NULL END AS exporter_reported_quantity,CASE WHEN ts.reported_by_exporter THEN NULL ELSE ts.quantity END AS importer_reported_quantity,unit.id AS unit_id,unit.name_en AS unit,importer.id AS importer_id,importer.iso_code2 AS importer_iso,importer.name_en AS importer,exporter.id AS exporter_id,exporter.iso_code2 AS exporter_iso,exporter.name_en AS exporter,NULL AS origin,purpose.id AS purpose_id,purpose.name_en AS purpose,source.id AS source_id,source.name_en AS source,term.id AS term_id,term.name_en AS term,ts.import_permits_ids AS import_permits,ts.export_permits_ids AS export_permits,ts.origin_permits_ids AS origin_permits,ts.import_permit_number AS import_permit,ts.export_permit_number AS export_permit,ts.origin_permit_number AS origin_permit,'Quota' AS issue_type,'Listing_annotations' AS details_of_compliance_issue,' 13/02/2003' AS compliance_type_start_date,'Present' AS compliance_type_end_date,'Tursiops truncatus' AS compliance_type_taxon,ts.taxon_concept_rank_id AS rank_id,'SPECIES' AS rank_name,'0' AS quota_quantity,'**II** [ORDER listing Cetacea spp.] Included in Appendix II, except for the species included in Appendix I. A zero annual export quota has been established for live specimens from the Black Sea population of Tursiops truncatus removed from the wild and traded for primarily commercial purposes.' AS notes
      FROM trade_shipments_with_taxa_view ts
      
      INNER JOIN geo_entities AS exporter ON exporter.id = ts.exporter_id
      INNER JOIN geo_entities AS importer ON importer.id = ts.importer_id
      LEFT OUTER JOIN trade_codes source ON ts.source_id = source.id
      LEFT OUTER JOIN trade_codes purpose ON ts.purpose_id = purpose.id
      LEFT OUTER JOIN trade_codes unit ON ts.unit_id = unit.id
      LEFT OUTER JOIN trade_codes term ON ts.term_id = term.id
    
      WHERE ts.id IN (
        SELECT UNNEST(sub.ids)
        FROM (
          
          SELECT ARRAY_AGG(ts.id) AS ids
          FROM trade_shipments_with_taxa_view ts
          
          INNER JOIN geo_entities AS exporter ON exporter.id = ts.exporter_id
          LEFT OUTER JOIN trade_codes source ON ts.source_id = source.id
          LEFT OUTER JOIN trade_codes purpose ON ts.purpose_id = purpose.id
          LEFT OUTER JOIN trade_codes unit ON ts.unit_id = unit.id
          LEFT OUTER JOIN trade_codes term ON ts.term_id = term.id
    
          WHERE ts.year >= 2003 AND ts.year <= 2018 AND ts.taxon_concept_id = 7086 AND exporter.iso_code2 = 'TR' AND TRUE AND term.code IN ('LIV') AND source.code IN ('W') AND purpose.code IN ('T') AND ts.country_of_origin_id IS NULL
          AND (source.name_en != 'Confiscations/seizures' OR ts.source_id IS NULL)
          GROUP BY year, reported_by_exporter
          HAVING SUM(quantity) > 0
    
        ) sub
      )
      ORDER BY ts.year, ts.taxon_concept_full_name, ts.exporter_id, ts.importer_id
    )
    
    UNION    

    (
      SELECT ts.id AS id,ts.year AS year,ts.appendix AS appendix,ts.taxon_concept_author_year AS author_year,ts.taxon_concept_name_status AS name_status,ts.taxon_concept_id,ts.taxon_concept_full_name AS taxon_name,ts.taxon_concept_phylum_id AS phylum_id,ts.taxon_concept_class_id AS class_id,ts.taxon_concept_class_name AS class_name,ts.taxon_concept_order_id AS order_id,ts.taxon_concept_order_name AS order_name,ts.taxon_concept_family_id AS family_id,ts.taxon_concept_family_name AS family_name,ts.taxon_concept_genus_id AS genus_id,ts.taxon_concept_genus_name AS genus_name,CASE WHEN ts.reported_by_exporter THEN ts.quantity ELSE NULL END AS exporter_reported_quantity,CASE WHEN ts.reported_by_exporter THEN NULL ELSE ts.quantity END AS importer_reported_quantity,unit.id AS unit_id,unit.name_en AS unit,importer.id AS importer_id,importer.iso_code2 AS importer_iso,importer.name_en AS importer,exporter.id AS exporter_id,exporter.iso_code2 AS exporter_iso,exporter.name_en AS exporter,NULL AS origin,purpose.id AS purpose_id,purpose.name_en AS purpose,source.id AS source_id,source.name_en AS source,term.id AS term_id,term.name_en AS term,ts.import_permits_ids AS import_permits,ts.export_permits_ids AS export_permits,ts.origin_permits_ids AS origin_permits,ts.import_permit_number AS import_permit,ts.export_permit_number AS export_permit,ts.origin_permit_number AS origin_permit,'Quota' AS issue_type,'Listing_annotations' AS details_of_compliance_issue,' 13/02/2003' AS compliance_type_start_date,'Present' AS compliance_type_end_date,'Tursiops truncatus' AS compliance_type_taxon,ts.taxon_concept_rank_id AS rank_id,'SPECIES' AS rank_name,'0' AS quota_quantity,'**II** [ORDER listing Cetacea spp.] Included in Appendix II, except for the species included in Appendix I. A zero annual export quota has been established for live specimens from the Black Sea population of Tursiops truncatus removed from the wild and traded for primarily commercial purposes.' AS notes
      FROM trade_shipments_with_taxa_view ts
      
      INNER JOIN geo_entities AS exporter ON exporter.id = ts.exporter_id
      INNER JOIN geo_entities AS importer ON importer.id = ts.importer_id
      LEFT OUTER JOIN trade_codes source ON ts.source_id = source.id
      LEFT OUTER JOIN trade_codes purpose ON ts.purpose_id = purpose.id
      LEFT OUTER JOIN trade_codes unit ON ts.unit_id = unit.id
      LEFT OUTER JOIN trade_codes term ON ts.term_id = term.id
    
      WHERE ts.id IN (
        SELECT UNNEST(sub.ids)
        FROM (
          
          SELECT ARRAY_AGG(ts.id) AS ids
          FROM trade_shipments_with_taxa_view ts
          
          INNER JOIN geo_entities AS exporter ON exporter.id = ts.exporter_id
          LEFT OUTER JOIN trade_codes source ON ts.source_id = source.id
          LEFT OUTER JOIN trade_codes purpose ON ts.purpose_id = purpose.id
          LEFT OUTER JOIN trade_codes unit ON ts.unit_id = unit.id
          LEFT OUTER JOIN trade_codes term ON ts.term_id = term.id
    
          WHERE ts.year >= 2003 AND ts.year <= 2018 AND ts.taxon_concept_id = 7086 AND exporter.iso_code2 = 'UA' AND TRUE AND term.code IN ('LIV') AND source.code IN ('W') AND purpose.code IN ('T') AND ts.country_of_origin_id IS NULL
          AND (source.name_en != 'Confiscations/seizures' OR ts.source_id IS NULL)
          GROUP BY year, reported_by_exporter
          HAVING SUM(quantity) > 0
    
        ) sub
      )
      ORDER BY ts.year, ts.taxon_concept_full_name, ts.exporter_id, ts.importer_id
    )
    
    UNION    

    (
      SELECT ts.id AS id,ts.year AS year,ts.appendix AS appendix,ts.taxon_concept_author_year AS author_year,ts.taxon_concept_name_status AS name_status,ts.taxon_concept_id,ts.taxon_concept_full_name AS taxon_name,ts.taxon_concept_phylum_id AS phylum_id,ts.taxon_concept_class_id AS class_id,ts.taxon_concept_class_name AS class_name,ts.taxon_concept_order_id AS order_id,ts.taxon_concept_order_name AS order_name,ts.taxon_concept_family_id AS family_id,ts.taxon_concept_family_name AS family_name,ts.taxon_concept_genus_id AS genus_id,ts.taxon_concept_genus_name AS genus_name,CASE WHEN ts.reported_by_exporter THEN ts.quantity ELSE NULL END AS exporter_reported_quantity,CASE WHEN ts.reported_by_exporter THEN NULL ELSE ts.quantity END AS importer_reported_quantity,unit.id AS unit_id,unit.name_en AS unit,importer.id AS importer_id,importer.iso_code2 AS importer_iso,importer.name_en AS importer,exporter.id AS exporter_id,exporter.iso_code2 AS exporter_iso,exporter.name_en AS exporter,NULL AS origin,purpose.id AS purpose_id,purpose.name_en AS purpose,source.id AS source_id,source.name_en AS source,term.id AS term_id,term.name_en AS term,ts.import_permits_ids AS import_permits,ts.export_permits_ids AS export_permits,ts.origin_permits_ids AS origin_permits,ts.import_permit_number AS import_permit,ts.export_permit_number AS export_permit,ts.origin_permit_number AS origin_permit,'Quota' AS issue_type,'Listing_annotations' AS details_of_compliance_issue,'18/09/1997' AS compliance_type_start_date,'Present' AS compliance_type_end_date,'Chaetophractus nationi' AS compliance_type_taxon,ts.taxon_concept_rank_id AS rank_id,'SPECIES' AS rank_name,'0' AS quota_quantity,'**II** Included in Appendix II. A zero annual export quota has been established. All specimens shall be deemed to be specimens of species included in Appendix I and the trade in them shall be regulated accordingly.' AS notes
      FROM trade_shipments_with_taxa_view ts
      
      INNER JOIN geo_entities AS exporter ON exporter.id = ts.exporter_id
      INNER JOIN geo_entities AS importer ON importer.id = ts.importer_id
      LEFT OUTER JOIN trade_codes source ON ts.source_id = source.id
      LEFT OUTER JOIN trade_codes purpose ON ts.purpose_id = purpose.id
      LEFT OUTER JOIN trade_codes unit ON ts.unit_id = unit.id
      LEFT OUTER JOIN trade_codes term ON ts.term_id = term.id
    
      WHERE ts.id IN (
        SELECT UNNEST(sub.ids)
        FROM (
          
          SELECT ARRAY_AGG(ts.id) AS ids
          FROM trade_shipments_with_taxa_view ts
          
          INNER JOIN geo_entities AS exporter ON exporter.id = ts.exporter_id
          LEFT OUTER JOIN trade_codes source ON ts.source_id = source.id
          LEFT OUTER JOIN trade_codes purpose ON ts.purpose_id = purpose.id
          LEFT OUTER JOIN trade_codes unit ON ts.unit_id = unit.id
          LEFT OUTER JOIN trade_codes term ON ts.term_id = term.id
    
          WHERE ts.year >= 1997 AND ts.year <= 2018 AND ts.taxon_concept_id = 5522 AND TRUE AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL
          AND (source.name_en != 'Confiscations/seizures' OR ts.source_id IS NULL)
          GROUP BY year, reported_by_exporter
          HAVING SUM(quantity) > 0
    
        ) sub
      )
      ORDER BY ts.year, ts.taxon_concept_full_name, ts.exporter_id, ts.importer_id
    )
    
    UNION    

    (
      SELECT ts.id AS id,ts.year AS year,ts.appendix AS appendix,ts.taxon_concept_author_year AS author_year,ts.taxon_concept_name_status AS name_status,ts.taxon_concept_id,ts.taxon_concept_full_name AS taxon_name,ts.taxon_concept_phylum_id AS phylum_id,ts.taxon_concept_class_id AS class_id,ts.taxon_concept_class_name AS class_name,ts.taxon_concept_order_id AS order_id,ts.taxon_concept_order_name AS order_name,ts.taxon_concept_family_id AS family_id,ts.taxon_concept_family_name AS family_name,ts.taxon_concept_genus_id AS genus_id,ts.taxon_concept_genus_name AS genus_name,CASE WHEN ts.reported_by_exporter THEN ts.quantity ELSE NULL END AS exporter_reported_quantity,CASE WHEN ts.reported_by_exporter THEN NULL ELSE ts.quantity END AS importer_reported_quantity,unit.id AS unit_id,unit.name_en AS unit,importer.id AS importer_id,importer.iso_code2 AS importer_iso,importer.name_en AS importer,exporter.id AS exporter_id,exporter.iso_code2 AS exporter_iso,exporter.name_en AS exporter,NULL AS origin,purpose.id AS purpose_id,purpose.name_en AS purpose,source.id AS source_id,source.name_en AS source,term.id AS term_id,term.name_en AS term,ts.import_permits_ids AS import_permits,ts.export_permits_ids AS export_permits,ts.origin_permits_ids AS origin_permits,ts.import_permit_number AS import_permit,ts.export_permit_number AS export_permit,ts.origin_permit_number AS origin_permit,'Quota' AS issue_type,'Listing_annotations' AS details_of_compliance_issue,'16/02/1995' AS compliance_type_start_date,'Present' AS compliance_type_end_date,'Melanosuchus niger' AS compliance_type_taxon,ts.taxon_concept_rank_id AS rank_id,'SPECIES' AS rank_name,'0' AS quota_quantity,'**I** Included in Appendix I, except for the population of Brazil, which is included in Appendix II, and the population of Ecuador, which is included in Appendix II and is subject to a zero annual export quota until an annual export quota has been approved by the CITES Secretariat and the IUCN/SSC Crocodile Specialist Group.
**II** Population of Brazil and the population of Ecuador, which is included in Appendix II and is subject to a zero annual export quota until an annual export quota has been approved by the CITES Secretariat and the IUCN/SSC Crocodile Specialist Group.' AS notes
      FROM trade_shipments_with_taxa_view ts
      
      INNER JOIN geo_entities AS exporter ON exporter.id = ts.exporter_id
      INNER JOIN geo_entities AS importer ON importer.id = ts.importer_id
      LEFT OUTER JOIN trade_codes source ON ts.source_id = source.id
      LEFT OUTER JOIN trade_codes purpose ON ts.purpose_id = purpose.id
      LEFT OUTER JOIN trade_codes unit ON ts.unit_id = unit.id
      LEFT OUTER JOIN trade_codes term ON ts.term_id = term.id
    
      WHERE ts.id IN (
        SELECT UNNEST(sub.ids)
        FROM (
          
          SELECT ARRAY_AGG(ts.id) AS ids
          FROM trade_shipments_with_taxa_view ts
          
          INNER JOIN geo_entities AS exporter ON exporter.id = ts.exporter_id
          LEFT OUTER JOIN trade_codes source ON ts.source_id = source.id
          LEFT OUTER JOIN trade_codes purpose ON ts.purpose_id = purpose.id
          LEFT OUTER JOIN trade_codes unit ON ts.unit_id = unit.id
          LEFT OUTER JOIN trade_codes term ON ts.term_id = term.id
    
          WHERE ts.year >= 1995 AND ts.year <= 2018 AND ts.taxon_concept_id = 10978 AND exporter.iso_code2 = 'EC' AND TRUE AND TRUE AND TRUE AND TRUE AND ts.country_of_origin_id IS NULL
          AND (source.name_en != 'Confiscations/seizures' OR ts.source_id IS NULL)
          GROUP BY year, reported_by_exporter
          HAVING SUM(quantity) > 0
    
        ) sub
      )
      ORDER BY ts.year, ts.taxon_concept_full_name, ts.exporter_id, ts.importer_id
    )
    
    UNION    

    (
      SELECT ts.id AS id,ts.year AS year,ts.appendix AS appendix,ts.taxon_concept_author_year AS author_year,ts.taxon_concept_name_status AS name_status,ts.taxon_concept_id,ts.taxon_concept_full_name AS taxon_name,ts.taxon_concept_phylum_id AS phylum_id,ts.taxon_concept_class_id AS class_id,ts.taxon_concept_class_name AS class_name,ts.taxon_concept_order_id AS order_id,ts.taxon_concept_order_name AS order_name,ts.taxon_concept_family_id AS family_id,ts.taxon_concept_family_name AS family_name,ts.taxon_concept_genus_id AS genus_id,ts.taxon_concept_genus_name AS genus_name,CASE WHEN ts.reported_by_exporter THEN ts.quantity ELSE NULL END AS exporter_reported_quantity,CASE WHEN ts.reported_by_exporter THEN NULL ELSE ts.quantity END AS importer_reported_quantity,unit.id AS unit_id,unit.name_en AS unit,importer.id AS importer_id,importer.iso_code2 AS importer_iso,importer.name_en AS importer,exporter.id AS exporter_id,exporter.iso_code2 AS exporter_iso,exporter.name_en AS exporter,NULL AS origin,purpose.id AS purpose_id,purpose.name_en AS purpose,source.id AS source_id,source.name_en AS source,term.id AS term_id,term.name_en AS term,ts.import_permits_ids AS import_permits,ts.export_permits_ids AS export_permits,ts.origin_permits_ids AS origin_permits,ts.import_permit_number AS import_permit,ts.export_permit_number AS export_permit,ts.origin_permit_number AS origin_permit,'Quota' AS issue_type,'Listing_annotations' AS details_of_compliance_issue,' 23/06/2010' AS compliance_type_start_date,' 01/01/2017' AS compliance_type_end_date,'Crocodylus moreletii' AS compliance_type_taxon,ts.taxon_concept_rank_id AS rank_id,'SPECIES' AS rank_name,'0' AS quota_quantity,'Zero quota for Mexico. Removed following listing in 02/01/2017' AS notes
      FROM trade_shipments_with_taxa_view ts
      
      INNER JOIN geo_entities AS exporter ON exporter.id = ts.exporter_id
      INNER JOIN geo_entities AS importer ON importer.id = ts.importer_id
      LEFT OUTER JOIN trade_codes source ON ts.source_id = source.id
      LEFT OUTER JOIN trade_codes purpose ON ts.purpose_id = purpose.id
      LEFT OUTER JOIN trade_codes unit ON ts.unit_id = unit.id
      LEFT OUTER JOIN trade_codes term ON ts.term_id = term.id
    
      WHERE ts.id IN (
        SELECT UNNEST(sub.ids)
        FROM (
          
          SELECT ARRAY_AGG(ts.id) AS ids
          FROM trade_shipments_with_taxa_view ts
          
          INNER JOIN geo_entities AS exporter ON exporter.id = ts.exporter_id
          LEFT OUTER JOIN trade_codes source ON ts.source_id = source.id
          LEFT OUTER JOIN trade_codes purpose ON ts.purpose_id = purpose.id
          LEFT OUTER JOIN trade_codes unit ON ts.unit_id = unit.id
          LEFT OUTER JOIN trade_codes term ON ts.term_id = term.id
    
          WHERE ts.year >= 2010 AND ts.year <= 2017 AND ts.taxon_concept_id = 7747 AND exporter.iso_code2 = 'MX' AND TRUE AND TRUE AND source.code IN ('W') AND purpose.code IN ('T') AND ts.country_of_origin_id IS NULL
          AND (source.name_en != 'Confiscations/seizures' OR ts.source_id IS NULL)
          GROUP BY year, reported_by_exporter
          HAVING SUM(quantity) > 0
    
        ) sub
      )
      ORDER BY ts.year, ts.taxon_concept_full_name, ts.exporter_id, ts.importer_id
    )
    
    UNION    

    (
      SELECT ts.id AS id,ts.year AS year,ts.appendix AS appendix,ts.taxon_concept_author_year AS author_year,ts.taxon_concept_name_status AS name_status,ts.taxon_concept_id,ts.taxon_concept_full_name AS taxon_name,ts.taxon_concept_phylum_id AS phylum_id,ts.taxon_concept_class_id AS class_id,ts.taxon_concept_class_name AS class_name,ts.taxon_concept_order_id AS order_id,ts.taxon_concept_order_name AS order_name,ts.taxon_concept_family_id AS family_id,ts.taxon_concept_family_name AS family_name,ts.taxon_concept_genus_id AS genus_id,ts.taxon_concept_genus_name AS genus_name,CASE WHEN ts.reported_by_exporter THEN ts.quantity ELSE NULL END AS exporter_reported_quantity,CASE WHEN ts.reported_by_exporter THEN NULL ELSE ts.quantity END AS importer_reported_quantity,unit.id AS unit_id,unit.name_en AS unit,importer.id AS importer_id,importer.iso_code2 AS importer_iso,importer.name_en AS importer,exporter.id AS exporter_id,exporter.iso_code2 AS exporter_iso,exporter.name_en AS exporter,NULL AS origin,purpose.id AS purpose_id,purpose.name_en AS purpose,source.id AS source_id,source.name_en AS source,term.id AS term_id,term.name_en AS term,ts.import_permits_ids AS import_permits,ts.export_permits_ids AS export_permits,ts.origin_permits_ids AS origin_permits,ts.import_permit_number AS import_permit,ts.export_permit_number AS export_permit,ts.origin_permit_number AS origin_permit,'Quota' AS issue_type,'Listing_annotations' AS details_of_compliance_issue,' 23/06/2010' AS compliance_type_start_date,'Present' AS compliance_type_end_date,'Crocodylus moreletii' AS compliance_type_taxon,ts.taxon_concept_rank_id AS rank_id,'SPECIES' AS rank_name,'0' AS quota_quantity,'**I** Except the population of Belize, which is included in Appendix II with a zero quota for wild specimens traded for commercial purposes, and the population of Mexico, which is included in Appendix II.
**II** Only the population of Belize, which is included in Appendix II with a zero quota for wild specimens traded for commercial purposes, and the population of Mexico.' AS notes
      FROM trade_shipments_with_taxa_view ts
      
      INNER JOIN geo_entities AS exporter ON exporter.id = ts.exporter_id
      INNER JOIN geo_entities AS importer ON importer.id = ts.importer_id
      LEFT OUTER JOIN trade_codes source ON ts.source_id = source.id
      LEFT OUTER JOIN trade_codes purpose ON ts.purpose_id = purpose.id
      LEFT OUTER JOIN trade_codes unit ON ts.unit_id = unit.id
      LEFT OUTER JOIN trade_codes term ON ts.term_id = term.id
    
      WHERE ts.id IN (
        SELECT UNNEST(sub.ids)
        FROM (
          
          SELECT ARRAY_AGG(ts.id) AS ids
          FROM trade_shipments_with_taxa_view ts
          
          INNER JOIN geo_entities AS exporter ON exporter.id = ts.exporter_id
          LEFT OUTER JOIN trade_codes source ON ts.source_id = source.id
          LEFT OUTER JOIN trade_codes purpose ON ts.purpose_id = purpose.id
          LEFT OUTER JOIN trade_codes unit ON ts.unit_id = unit.id
          LEFT OUTER JOIN trade_codes term ON ts.term_id = term.id
    
          WHERE ts.year >= 2010 AND ts.year <= 2018 AND ts.taxon_concept_id = 7747 AND exporter.iso_code2 = 'BZ' AND TRUE AND TRUE AND source.code IN ('W') AND purpose.code IN ('T') AND ts.country_of_origin_id IS NULL
          AND (source.name_en != 'Confiscations/seizures' OR ts.source_id IS NULL)
          GROUP BY year, reported_by_exporter
          HAVING SUM(quantity) > 0
    
        ) sub
      )
      ORDER BY ts.year, ts.taxon_concept_full_name, ts.exporter_id, ts.importer_id
    )
    
    UNION    

    (
      SELECT ts.id AS id,ts.year AS year,ts.appendix AS appendix,ts.taxon_concept_author_year AS author_year,ts.taxon_concept_name_status AS name_status,ts.taxon_concept_id,ts.taxon_concept_full_name AS taxon_name,ts.taxon_concept_phylum_id AS phylum_id,ts.taxon_concept_class_id AS class_id,ts.taxon_concept_class_name AS class_name,ts.taxon_concept_order_id AS order_id,ts.taxon_concept_order_name AS order_name,ts.taxon_concept_family_id AS family_id,ts.taxon_concept_family_name AS family_name,ts.taxon_concept_genus_id AS genus_id,ts.taxon_concept_genus_name AS genus_name,CASE WHEN ts.reported_by_exporter THEN ts.quantity ELSE NULL END AS exporter_reported_quantity,CASE WHEN ts.reported_by_exporter THEN NULL ELSE ts.quantity END AS importer_reported_quantity,unit.id AS unit_id,unit.name_en AS unit,importer.id AS importer_id,importer.iso_code2 AS importer_iso,importer.name_en AS importer,exporter.id AS exporter_id,exporter.iso_code2 AS exporter_iso,exporter.name_en AS exporter,NULL AS origin,purpose.id AS purpose_id,purpose.name_en AS purpose,source.id AS source_id,source.name_en AS source,term.id AS term_id,term.name_en AS term,ts.import_permits_ids AS import_permits,ts.export_permits_ids AS export_permits,ts.origin_permits_ids AS origin_permits,ts.import_permit_number AS import_permit,ts.export_permit_number AS export_permit,ts.origin_permit_number AS origin_permit,'Quota' AS issue_type,'Listing_annotations' AS details_of_compliance_issue,' 23/06/2010' AS compliance_type_start_date,'Present' AS compliance_type_end_date,'Crocodylus niloticus' AS compliance_type_taxon,ts.taxon_concept_rank_id AS rank_id,'SPECIES' AS rank_name,'0' AS quota_quantity,'**I** Included in Appendix I, except the populations of Botswana, Egypt (subject to a zero quota for wild specimens traded for commercial purposes), Ethiopia, Kenya, Madagascar, Malawi, Mozambique, Namibia, South Africa, Uganda, the United Republic of Tanzania (subject to an annual export quota of no more than 1,600 wild specimens including hunting trophies, in addition to ranched specimens), Zambia and Zimbabwe, which are included in Appendix II
**II** Populations of Botswana, Egypt (subject to a zero quota for wild specimens traded for commercial purposes), Ethiopia, Kenya, Madagascar, Malawi, Mozambique, Namibia, South Africa, Uganda, the United Republic of Tanzania (subject to an annual export quota of no more than 1,600 wild specimens including hunting trophies, in addition to ranched specimens), Zambia and Zimbabwe. ' AS notes
      FROM trade_shipments_with_taxa_view ts
      
      INNER JOIN geo_entities AS exporter ON exporter.id = ts.exporter_id
      INNER JOIN geo_entities AS importer ON importer.id = ts.importer_id
      LEFT OUTER JOIN trade_codes source ON ts.source_id = source.id
      LEFT OUTER JOIN trade_codes purpose ON ts.purpose_id = purpose.id
      LEFT OUTER JOIN trade_codes unit ON ts.unit_id = unit.id
      LEFT OUTER JOIN trade_codes term ON ts.term_id = term.id
    
      WHERE ts.id IN (
        SELECT UNNEST(sub.ids)
        FROM (
          
          SELECT ARRAY_AGG(ts.id) AS ids
          FROM trade_shipments_with_taxa_view ts
          
          INNER JOIN geo_entities AS exporter ON exporter.id = ts.exporter_id
          LEFT OUTER JOIN trade_codes source ON ts.source_id = source.id
          LEFT OUTER JOIN trade_codes purpose ON ts.purpose_id = purpose.id
          LEFT OUTER JOIN trade_codes unit ON ts.unit_id = unit.id
          LEFT OUTER JOIN trade_codes term ON ts.term_id = term.id
    
          WHERE ts.year >= 2010 AND ts.year <= 2018 AND ts.taxon_concept_id = 10745 AND exporter.iso_code2 = 'EG' AND TRUE AND TRUE AND source.code IN ('W') AND purpose.code IN ('T') AND ts.country_of_origin_id IS NULL
          AND (source.name_en != 'Confiscations/seizures' OR ts.source_id IS NULL)
          GROUP BY year, reported_by_exporter
          HAVING SUM(quantity) > 0
    
        ) sub
      )
      ORDER BY ts.year, ts.taxon_concept_full_name, ts.exporter_id, ts.importer_id
    )
    
    UNION    

    (
      SELECT ts.id AS id,ts.year AS year,ts.appendix AS appendix,ts.taxon_concept_author_year AS author_year,ts.taxon_concept_name_status AS name_status,ts.taxon_concept_id,ts.taxon_concept_full_name AS taxon_name,ts.taxon_concept_phylum_id AS phylum_id,ts.taxon_concept_class_id AS class_id,ts.taxon_concept_class_name AS class_name,ts.taxon_concept_order_id AS order_id,ts.taxon_concept_order_name AS order_name,ts.taxon_concept_family_id AS family_id,ts.taxon_concept_family_name AS family_name,ts.taxon_concept_genus_id AS genus_id,ts.taxon_concept_genus_name AS genus_name,CASE WHEN ts.reported_by_exporter THEN ts.quantity ELSE NULL END AS exporter_reported_quantity,CASE WHEN ts.reported_by_exporter THEN NULL ELSE ts.quantity END AS importer_reported_quantity,unit.id AS unit_id,unit.name_en AS unit,importer.id AS importer_id,importer.iso_code2 AS importer_iso,importer.name_en AS importer,exporter.id AS exporter_id,exporter.iso_code2 AS exporter_iso,exporter.name_en AS exporter,NULL AS origin,purpose.id AS purpose_id,purpose.name_en AS purpose,source.id AS source_id,source.name_en AS source,term.id AS term_id,term.name_en AS term,ts.import_permits_ids AS import_permits,ts.export_permits_ids AS export_permits,ts.origin_permits_ids AS origin_permits,ts.import_permit_number AS import_permit,ts.export_permit_number AS export_permit,ts.origin_permit_number AS origin_permit,'Quota' AS issue_type,'Listing_annotations' AS details_of_compliance_issue,' 23/06/2010' AS compliance_type_start_date,'Present' AS compliance_type_end_date,'Crocodylus niloticus' AS compliance_type_taxon,ts.taxon_concept_rank_id AS rank_id,'SPECIES' AS rank_name,'1600' AS quota_quantity,'**I** Included in Appendix I, except the populations of Botswana, Egypt (subject to a zero quota for wild specimens traded for commercial purposes), Ethiopia, Kenya, Madagascar, Malawi, Mozambique, Namibia, South Africa, Uganda, the United Republic of Tanzania (subject to an annual export quota of no more than 1,600 wild specimens including hunting trophies, in addition to ranched specimens), Zambia and Zimbabwe, which are included in Appendix II
**II** Populations of Botswana, Egypt (subject to a zero quota for wild specimens traded for commercial purposes), Ethiopia, Kenya, Madagascar, Malawi, Mozambique, Namibia, South Africa, Uganda, the United Republic of Tanzania (subject to an annual export quota of no more than 1,600 wild specimens including hunting trophies, in addition to ranched specimens), Zambia and Zimbabwe. ' AS notes
      FROM trade_shipments_with_taxa_view ts
      
      INNER JOIN geo_entities AS exporter ON exporter.id = ts.exporter_id
      INNER JOIN geo_entities AS importer ON importer.id = ts.importer_id
      LEFT OUTER JOIN trade_codes source ON ts.source_id = source.id
      LEFT OUTER JOIN trade_codes purpose ON ts.purpose_id = purpose.id
      LEFT OUTER JOIN trade_codes unit ON ts.unit_id = unit.id
      LEFT OUTER JOIN trade_codes term ON ts.term_id = term.id
    
      WHERE ts.id IN (
        SELECT UNNEST(sub.ids)
        FROM (
          
          SELECT ARRAY_AGG(ts.id) AS ids
          FROM trade_shipments_with_taxa_view ts
          
          INNER JOIN geo_entities AS exporter ON exporter.id = ts.exporter_id
          LEFT OUTER JOIN trade_codes source ON ts.source_id = source.id
          LEFT OUTER JOIN trade_codes purpose ON ts.purpose_id = purpose.id
          LEFT OUTER JOIN trade_codes unit ON ts.unit_id = unit.id
          LEFT OUTER JOIN trade_codes term ON ts.term_id = term.id
    
          WHERE ts.year >= 2010 AND ts.year <= 2018 AND ts.taxon_concept_id = 10745 AND exporter.iso_code2 = 'TZ' AND TRUE AND TRUE AND source.code IN ('W') AND TRUE AND ts.country_of_origin_id IS NULL
          AND (source.name_en != 'Confiscations/seizures' OR ts.source_id IS NULL)
          GROUP BY year, reported_by_exporter
          HAVING SUM(quantity) > 1600
    
        ) sub
      )
      ORDER BY ts.year, ts.taxon_concept_full_name, ts.exporter_id, ts.importer_id
    )
    
    UNION    

    (
      SELECT ts.id AS id,ts.year AS year,ts.appendix AS appendix,ts.taxon_concept_author_year AS author_year,ts.taxon_concept_name_status AS name_status,ts.taxon_concept_id,ts.taxon_concept_full_name AS taxon_name,ts.taxon_concept_phylum_id AS phylum_id,ts.taxon_concept_class_id AS class_id,ts.taxon_concept_class_name AS class_name,ts.taxon_concept_order_id AS order_id,ts.taxon_concept_order_name AS order_name,ts.taxon_concept_family_id AS family_id,ts.taxon_concept_family_name AS family_name,ts.taxon_concept_genus_id AS genus_id,ts.taxon_concept_genus_name AS genus_name,CASE WHEN ts.reported_by_exporter THEN ts.quantity ELSE NULL END AS exporter_reported_quantity,CASE WHEN ts.reported_by_exporter THEN NULL ELSE ts.quantity END AS importer_reported_quantity,unit.id AS unit_id,unit.name_en AS unit,importer.id AS importer_id,importer.iso_code2 AS importer_iso,importer.name_en AS importer,exporter.id AS exporter_id,exporter.iso_code2 AS exporter_iso,exporter.name_en AS exporter,NULL AS origin,purpose.id AS purpose_id,purpose.name_en AS purpose,source.id AS source_id,source.name_en AS source,term.id AS term_id,term.name_en AS term,ts.import_permits_ids AS import_permits,ts.export_permits_ids AS export_permits,ts.origin_permits_ids AS origin_permits,ts.import_permit_number AS import_permit,ts.export_permit_number AS export_permit,ts.origin_permit_number AS origin_permit,'Quota' AS issue_type,'Listing_annotations' AS details_of_compliance_issue,' 02/01/2017' AS compliance_type_start_date,'Present' AS compliance_type_end_date,'Crocodylus porosus' AS compliance_type_taxon,ts.taxon_concept_rank_id AS rank_id,'SPECIES' AS rank_name,'0' AS quota_quantity,'**I** Except the populations of Australia, Indonesia, Malaysia [wild harvest restricted to the State of Sarawak and a zero quota for wild specimens for the other States of Malaysia (Sabah and Peninsular Malaysia), with no change in the zero quota unless approved by the Parties] and Papua New Guinea, which are included in Appendix II.
**II** Only the populations of Australia, Indonesia, Malaysia [wild harvest restricted to the State of Sarawak and a zero quota for wild specimens for the other States of Malaysia (Sabah and Peninsular Malaysia), with no change in the zero quota unless approved by the Parties] and Papua New Guinea; all other populations are included in Appendix I.' AS notes
      FROM trade_shipments_with_taxa_view ts
      
      INNER JOIN geo_entities AS exporter ON exporter.id = ts.exporter_id
      INNER JOIN geo_entities AS importer ON importer.id = ts.importer_id
      LEFT OUTER JOIN trade_codes source ON ts.source_id = source.id
      LEFT OUTER JOIN trade_codes purpose ON ts.purpose_id = purpose.id
      LEFT OUTER JOIN trade_codes unit ON ts.unit_id = unit.id
      LEFT OUTER JOIN trade_codes term ON ts.term_id = term.id
    
      WHERE ts.id IN (
        SELECT UNNEST(sub.ids)
        FROM (
          
          SELECT ARRAY_AGG(ts.id) AS ids
          FROM trade_shipments_with_taxa_view ts
          
          INNER JOIN geo_entities AS exporter ON exporter.id = ts.exporter_id
          LEFT OUTER JOIN trade_codes source ON ts.source_id = source.id
          LEFT OUTER JOIN trade_codes purpose ON ts.purpose_id = purpose.id
          LEFT OUTER JOIN trade_codes unit ON ts.unit_id = unit.id
          LEFT OUTER JOIN trade_codes term ON ts.term_id = term.id
    
          WHERE ts.year >= 2017 AND ts.year <= 2018 AND ts.taxon_concept_id = 8560 AND exporter.iso_code2 = 'MY' AND TRUE AND TRUE AND source.code IN ('W') AND TRUE AND ts.country_of_origin_id IS NULL
          AND (source.name_en != 'Confiscations/seizures' OR ts.source_id IS NULL)
          GROUP BY year, reported_by_exporter
          HAVING SUM(quantity) > 0
    
        ) sub
      )
      ORDER BY ts.year, ts.taxon_concept_full_name, ts.exporter_id, ts.importer_id
    )
    
    UNION    

    (
      SELECT ts.id AS id,ts.year AS year,ts.appendix AS appendix,ts.taxon_concept_author_year AS author_year,ts.taxon_concept_name_status AS name_status,ts.taxon_concept_id,ts.taxon_concept_full_name AS taxon_name,ts.taxon_concept_phylum_id AS phylum_id,ts.taxon_concept_class_id AS class_id,ts.taxon_concept_class_name AS class_name,ts.taxon_concept_order_id AS order_id,ts.taxon_concept_order_name AS order_name,ts.taxon_concept_family_id AS family_id,ts.taxon_concept_family_name AS family_name,ts.taxon_concept_genus_id AS genus_id,ts.taxon_concept_genus_name AS genus_name,CASE WHEN ts.reported_by_exporter THEN ts.quantity ELSE NULL END AS exporter_reported_quantity,CASE WHEN ts.reported_by_exporter THEN NULL ELSE ts.quantity END AS importer_reported_quantity,unit.id AS unit_id,unit.name_en AS unit,importer.id AS importer_id,importer.iso_code2 AS importer_iso,importer.name_en AS importer,exporter.id AS exporter_id,exporter.iso_code2 AS exporter_iso,exporter.name_en AS exporter,NULL AS origin,purpose.id AS purpose_id,purpose.name_en AS purpose,source.id AS source_id,source.name_en AS source,term.id AS term_id,term.name_en AS term,ts.import_permits_ids AS import_permits,ts.export_permits_ids AS export_permits,ts.origin_permits_ids AS origin_permits,ts.import_permit_number AS import_permit,ts.export_permit_number AS export_permit,ts.origin_permit_number AS origin_permit,'Quota' AS issue_type,'Listing_annotations' AS details_of_compliance_issue,' 02/01/2017' AS compliance_type_start_date,'Present' AS compliance_type_end_date,'Abronia aurita' AS compliance_type_taxon,ts.taxon_concept_rank_id AS rank_id,'SPECIES' AS rank_name,'0' AS quota_quantity,'**II** [GENUS listing Abronia spp.] Except the species included in Appendix I. Zero export quota for wild specimens for Abronia aurita, A. gaiophantasma, A. montecristoi, A. salvadorensis and A. vasconcelosii.' AS notes
      FROM trade_shipments_with_taxa_view ts
      
      INNER JOIN geo_entities AS exporter ON exporter.id = ts.exporter_id
      INNER JOIN geo_entities AS importer ON importer.id = ts.importer_id
      LEFT OUTER JOIN trade_codes source ON ts.source_id = source.id
      LEFT OUTER JOIN trade_codes purpose ON ts.purpose_id = purpose.id
      LEFT OUTER JOIN trade_codes unit ON ts.unit_id = unit.id
      LEFT OUTER JOIN trade_codes term ON ts.term_id = term.id
    
      WHERE ts.id IN (
        SELECT UNNEST(sub.ids)
        FROM (
          
          SELECT ARRAY_AGG(ts.id) AS ids
          FROM trade_shipments_with_taxa_view ts
          
          INNER JOIN geo_entities AS exporter ON exporter.id = ts.exporter_id
          LEFT OUTER JOIN trade_codes source ON ts.source_id = source.id
          LEFT OUTER JOIN trade_codes purpose ON ts.purpose_id = purpose.id
          LEFT OUTER JOIN trade_codes unit ON ts.unit_id = unit.id
          LEFT OUTER JOIN trade_codes term ON ts.term_id = term.id
    
          WHERE ts.year >= 2017 AND ts.year <= 2018 AND ts.taxon_concept_id = 68179 AND TRUE AND TRUE AND TRUE AND source.code IN ('W') AND TRUE AND ts.country_of_origin_id IS NULL
          AND (source.name_en != 'Confiscations/seizures' OR ts.source_id IS NULL)
          GROUP BY year, reported_by_exporter
          HAVING SUM(quantity) > 0
    
        ) sub
      )
      ORDER BY ts.year, ts.taxon_concept_full_name, ts.exporter_id, ts.importer_id
    )
    
    UNION    

    (
      SELECT ts.id AS id,ts.year AS year,ts.appendix AS appendix,ts.taxon_concept_author_year AS author_year,ts.taxon_concept_name_status AS name_status,ts.taxon_concept_id,ts.taxon_concept_full_name AS taxon_name,ts.taxon_concept_phylum_id AS phylum_id,ts.taxon_concept_class_id AS class_id,ts.taxon_concept_class_name AS class_name,ts.taxon_concept_order_id AS order_id,ts.taxon_concept_order_name AS order_name,ts.taxon_concept_family_id AS family_id,ts.taxon_concept_family_name AS family_name,ts.taxon_concept_genus_id AS genus_id,ts.taxon_concept_genus_name AS genus_name,CASE WHEN ts.reported_by_exporter THEN ts.quantity ELSE NULL END AS exporter_reported_quantity,CASE WHEN ts.reported_by_exporter THEN NULL ELSE ts.quantity END AS importer_reported_quantity,unit.id AS unit_id,unit.name_en AS unit,importer.id AS importer_id,importer.iso_code2 AS importer_iso,importer.name_en AS importer,exporter.id AS exporter_id,exporter.iso_code2 AS exporter_iso,exporter.name_en AS exporter,NULL AS origin,purpose.id AS purpose_id,purpose.name_en AS purpose,source.id AS source_id,source.name_en AS source,term.id AS term_id,term.name_en AS term,ts.import_permits_ids AS import_permits,ts.export_permits_ids AS export_permits,ts.origin_permits_ids AS origin_permits,ts.import_permit_number AS import_permit,ts.export_permit_number AS export_permit,ts.origin_permit_number AS origin_permit,'Quota' AS issue_type,'Listing_annotations' AS details_of_compliance_issue,' 02/01/2017' AS compliance_type_start_date,'Present' AS compliance_type_end_date,'Abronia gaiophantasma' AS compliance_type_taxon,ts.taxon_concept_rank_id AS rank_id,'SPECIES' AS rank_name,'0' AS quota_quantity,'**II** [GENUS listing Abronia spp.] Except the species included in Appendix I. Zero export quota for wild specimens for Abronia aurita, A. gaiophantasma, A. montecristoi, A. salvadorensis and A. vasconcelosii.' AS notes
      FROM trade_shipments_with_taxa_view ts
      
      INNER JOIN geo_entities AS exporter ON exporter.id = ts.exporter_id
      INNER JOIN geo_entities AS importer ON importer.id = ts.importer_id
      LEFT OUTER JOIN trade_codes source ON ts.source_id = source.id
      LEFT OUTER JOIN trade_codes purpose ON ts.purpose_id = purpose.id
      LEFT OUTER JOIN trade_codes unit ON ts.unit_id = unit.id
      LEFT OUTER JOIN trade_codes term ON ts.term_id = term.id
    
      WHERE ts.id IN (
        SELECT UNNEST(sub.ids)
        FROM (
          
          SELECT ARRAY_AGG(ts.id) AS ids
          FROM trade_shipments_with_taxa_view ts
          
          INNER JOIN geo_entities AS exporter ON exporter.id = ts.exporter_id
          LEFT OUTER JOIN trade_codes source ON ts.source_id = source.id
          LEFT OUTER JOIN trade_codes purpose ON ts.purpose_id = purpose.id
          LEFT OUTER JOIN trade_codes unit ON ts.unit_id = unit.id
          LEFT OUTER JOIN trade_codes term ON ts.term_id = term.id
    
          WHERE ts.year >= 2017 AND ts.year <= 2018 AND ts.taxon_concept_id = 68245 AND TRUE AND TRUE AND TRUE AND source.code IN ('W') AND TRUE AND ts.country_of_origin_id IS NULL
          AND (source.name_en != 'Confiscations/seizures' OR ts.source_id IS NULL)
          GROUP BY year, reported_by_exporter
          HAVING SUM(quantity) > 0
    
        ) sub
      )
      ORDER BY ts.year, ts.taxon_concept_full_name, ts.exporter_id, ts.importer_id
    )
    
    UNION    

    (
      SELECT ts.id AS id,ts.year AS year,ts.appendix AS appendix,ts.taxon_concept_author_year AS author_year,ts.taxon_concept_name_status AS name_status,ts.taxon_concept_id,ts.taxon_concept_full_name AS taxon_name,ts.taxon_concept_phylum_id AS phylum_id,ts.taxon_concept_class_id AS class_id,ts.taxon_concept_class_name AS class_name,ts.taxon_concept_order_id AS order_id,ts.taxon_concept_order_name AS order_name,ts.taxon_concept_family_id AS family_id,ts.taxon_concept_family_name AS family_name,ts.taxon_concept_genus_id AS genus_id,ts.taxon_concept_genus_name AS genus_name,CASE WHEN ts.reported_by_exporter THEN ts.quantity ELSE NULL END AS exporter_reported_quantity,CASE WHEN ts.reported_by_exporter THEN NULL ELSE ts.quantity END AS importer_reported_quantity,unit.id AS unit_id,unit.name_en AS unit,importer.id AS importer_id,importer.iso_code2 AS importer_iso,importer.name_en AS importer,exporter.id AS exporter_id,exporter.iso_code2 AS exporter_iso,exporter.name_en AS exporter,NULL AS origin,purpose.id AS purpose_id,purpose.name_en AS purpose,source.id AS source_id,source.name_en AS source,term.id AS term_id,term.name_en AS term,ts.import_permits_ids AS import_permits,ts.export_permits_ids AS export_permits,ts.origin_permits_ids AS origin_permits,ts.import_permit_number AS import_permit,ts.export_permit_number AS export_permit,ts.origin_permit_number AS origin_permit,'Quota' AS issue_type,'Listing_annotations' AS details_of_compliance_issue,' 02/01/2017' AS compliance_type_start_date,'Present' AS compliance_type_end_date,'Abronia montecristoi' AS compliance_type_taxon,ts.taxon_concept_rank_id AS rank_id,'SPECIES' AS rank_name,'0' AS quota_quantity,'**II** [GENUS listing Abronia spp.] Except the species included in Appendix I. Zero export quota for wild specimens for Abronia aurita, A. gaiophantasma, A. montecristoi, A. salvadorensis and A. vasconcelosii.' AS notes
      FROM trade_shipments_with_taxa_view ts
      
      INNER JOIN geo_entities AS exporter ON exporter.id = ts.exporter_id
      INNER JOIN geo_entities AS importer ON importer.id = ts.importer_id
      LEFT OUTER JOIN trade_codes source ON ts.source_id = source.id
      LEFT OUTER JOIN trade_codes purpose ON ts.purpose_id = purpose.id
      LEFT OUTER JOIN trade_codes unit ON ts.unit_id = unit.id
      LEFT OUTER JOIN trade_codes term ON ts.term_id = term.id
    
      WHERE ts.id IN (
        SELECT UNNEST(sub.ids)
        FROM (
          
          SELECT ARRAY_AGG(ts.id) AS ids
          FROM trade_shipments_with_taxa_view ts
          
          INNER JOIN geo_entities AS exporter ON exporter.id = ts.exporter_id
          LEFT OUTER JOIN trade_codes source ON ts.source_id = source.id
          LEFT OUTER JOIN trade_codes purpose ON ts.purpose_id = purpose.id
          LEFT OUTER JOIN trade_codes unit ON ts.unit_id = unit.id
          LEFT OUTER JOIN trade_codes term ON ts.term_id = term.id
    
          WHERE ts.year >= 2017 AND ts.year <= 2018 AND ts.taxon_concept_id = 68148 AND TRUE AND TRUE AND TRUE AND source.code IN ('W') AND TRUE AND ts.country_of_origin_id IS NULL
          AND (source.name_en != 'Confiscations/seizures' OR ts.source_id IS NULL)
          GROUP BY year, reported_by_exporter
          HAVING SUM(quantity) > 0
    
        ) sub
      )
      ORDER BY ts.year, ts.taxon_concept_full_name, ts.exporter_id, ts.importer_id
    )
    
    UNION    

    (
      SELECT ts.id AS id,ts.year AS year,ts.appendix AS appendix,ts.taxon_concept_author_year AS author_year,ts.taxon_concept_name_status AS name_status,ts.taxon_concept_id,ts.taxon_concept_full_name AS taxon_name,ts.taxon_concept_phylum_id AS phylum_id,ts.taxon_concept_class_id AS class_id,ts.taxon_concept_class_name AS class_name,ts.taxon_concept_order_id AS order_id,ts.taxon_concept_order_name AS order_name,ts.taxon_concept_family_id AS family_id,ts.taxon_concept_family_name AS family_name,ts.taxon_concept_genus_id AS genus_id,ts.taxon_concept_genus_name AS genus_name,CASE WHEN ts.reported_by_exporter THEN ts.quantity ELSE NULL END AS exporter_reported_quantity,CASE WHEN ts.reported_by_exporter THEN NULL ELSE ts.quantity END AS importer_reported_quantity,unit.id AS unit_id,unit.name_en AS unit,importer.id AS importer_id,importer.iso_code2 AS importer_iso,importer.name_en AS importer,exporter.id AS exporter_id,exporter.iso_code2 AS exporter_iso,exporter.name_en AS exporter,NULL AS origin,purpose.id AS purpose_id,purpose.name_en AS purpose,source.id AS source_id,source.name_en AS source,term.id AS term_id,term.name_en AS term,ts.import_permits_ids AS import_permits,ts.export_permits_ids AS export_permits,ts.origin_permits_ids AS origin_permits,ts.import_permit_number AS import_permit,ts.export_permit_number AS export_permit,ts.origin_permit_number AS origin_permit,'Quota' AS issue_type,'Listing_annotations' AS details_of_compliance_issue,' 02/01/2017' AS compliance_type_start_date,'Present' AS compliance_type_end_date,'Abronia salvadorensis' AS compliance_type_taxon,ts.taxon_concept_rank_id AS rank_id,'SPECIES' AS rank_name,'0' AS quota_quantity,'**II** [GENUS listing Abronia spp.] Except the species included in Appendix I. Zero export quota for wild specimens for Abronia aurita, A. gaiophantasma, A. montecristoi, A. salvadorensis and A. vasconcelosii.' AS notes
      FROM trade_shipments_with_taxa_view ts
      
      INNER JOIN geo_entities AS exporter ON exporter.id = ts.exporter_id
      INNER JOIN geo_entities AS importer ON importer.id = ts.importer_id
      LEFT OUTER JOIN trade_codes source ON ts.source_id = source.id
      LEFT OUTER JOIN trade_codes purpose ON ts.purpose_id = purpose.id
      LEFT OUTER JOIN trade_codes unit ON ts.unit_id = unit.id
      LEFT OUTER JOIN trade_codes term ON ts.term_id = term.id
    
      WHERE ts.id IN (
        SELECT UNNEST(sub.ids)
        FROM (
          
          SELECT ARRAY_AGG(ts.id) AS ids
          FROM trade_shipments_with_taxa_view ts
          
          INNER JOIN geo_entities AS exporter ON exporter.id = ts.exporter_id
          LEFT OUTER JOIN trade_codes source ON ts.source_id = source.id
          LEFT OUTER JOIN trade_codes purpose ON ts.purpose_id = purpose.id
          LEFT OUTER JOIN trade_codes unit ON ts.unit_id = unit.id
          LEFT OUTER JOIN trade_codes term ON ts.term_id = term.id
    
          WHERE ts.year >= 2017 AND ts.year <= 2018 AND ts.taxon_concept_id = 68213 AND TRUE AND TRUE AND TRUE AND source.code IN ('W') AND TRUE AND ts.country_of_origin_id IS NULL
          AND (source.name_en != 'Confiscations/seizures' OR ts.source_id IS NULL)
          GROUP BY year, reported_by_exporter
          HAVING SUM(quantity) > 0
    
        ) sub
      )
      ORDER BY ts.year, ts.taxon_concept_full_name, ts.exporter_id, ts.importer_id
    )
    
    UNION    

    (
      SELECT ts.id AS id,ts.year AS year,ts.appendix AS appendix,ts.taxon_concept_author_year AS author_year,ts.taxon_concept_name_status AS name_status,ts.taxon_concept_id,ts.taxon_concept_full_name AS taxon_name,ts.taxon_concept_phylum_id AS phylum_id,ts.taxon_concept_class_id AS class_id,ts.taxon_concept_class_name AS class_name,ts.taxon_concept_order_id AS order_id,ts.taxon_concept_order_name AS order_name,ts.taxon_concept_family_id AS family_id,ts.taxon_concept_family_name AS family_name,ts.taxon_concept_genus_id AS genus_id,ts.taxon_concept_genus_name AS genus_name,CASE WHEN ts.reported_by_exporter THEN ts.quantity ELSE NULL END AS exporter_reported_quantity,CASE WHEN ts.reported_by_exporter THEN NULL ELSE ts.quantity END AS importer_reported_quantity,unit.id AS unit_id,unit.name_en AS unit,importer.id AS importer_id,importer.iso_code2 AS importer_iso,importer.name_en AS importer,exporter.id AS exporter_id,exporter.iso_code2 AS exporter_iso,exporter.name_en AS exporter,NULL AS origin,purpose.id AS purpose_id,purpose.name_en AS purpose,source.id AS source_id,source.name_en AS source,term.id AS term_id,term.name_en AS term,ts.import_permits_ids AS import_permits,ts.export_permits_ids AS export_permits,ts.origin_permits_ids AS origin_permits,ts.import_permit_number AS import_permit,ts.export_permit_number AS export_permit,ts.origin_permit_number AS origin_permit,'Quota' AS issue_type,'Listing_annotations' AS details_of_compliance_issue,' 02/01/2017' AS compliance_type_start_date,'Present' AS compliance_type_end_date,'Abronia vasconcelosii' AS compliance_type_taxon,ts.taxon_concept_rank_id AS rank_id,'SPECIES' AS rank_name,'0' AS quota_quantity,'**II** [GENUS listing Abronia spp.] Except the species included in Appendix I. Zero export quota for wild specimens for Abronia aurita, A. gaiophantasma, A. montecristoi, A. salvadorensis and A. vasconcelosii.' AS notes
      FROM trade_shipments_with_taxa_view ts
      
      INNER JOIN geo_entities AS exporter ON exporter.id = ts.exporter_id
      INNER JOIN geo_entities AS importer ON importer.id = ts.importer_id
      LEFT OUTER JOIN trade_codes source ON ts.source_id = source.id
      LEFT OUTER JOIN trade_codes purpose ON ts.purpose_id = purpose.id
      LEFT OUTER JOIN trade_codes unit ON ts.unit_id = unit.id
      LEFT OUTER JOIN trade_codes term ON ts.term_id = term.id
    
      WHERE ts.id IN (
        SELECT UNNEST(sub.ids)
        FROM (
          
          SELECT ARRAY_AGG(ts.id) AS ids
          FROM trade_shipments_with_taxa_view ts
          
          INNER JOIN geo_entities AS exporter ON exporter.id = ts.exporter_id
          LEFT OUTER JOIN trade_codes source ON ts.source_id = source.id
          LEFT OUTER JOIN trade_codes purpose ON ts.purpose_id = purpose.id
          LEFT OUTER JOIN trade_codes unit ON ts.unit_id = unit.id
          LEFT OUTER JOIN trade_codes term ON ts.term_id = term.id
    
          WHERE ts.year >= 2017 AND ts.year <= 2018 AND ts.taxon_concept_id = 68195 AND TRUE AND TRUE AND TRUE AND source.code IN ('W') AND TRUE AND ts.country_of_origin_id IS NULL
          AND (source.name_en != 'Confiscations/seizures' OR ts.source_id IS NULL)
          GROUP BY year, reported_by_exporter
          HAVING SUM(quantity) > 0
    
        ) sub
      )
      ORDER BY ts.year, ts.taxon_concept_full_name, ts.exporter_id, ts.importer_id
    )
    
    UNION    

    (
      SELECT ts.id AS id,ts.year AS year,ts.appendix AS appendix,ts.taxon_concept_author_year AS author_year,ts.taxon_concept_name_status AS name_status,ts.taxon_concept_id,ts.taxon_concept_full_name AS taxon_name,ts.taxon_concept_phylum_id AS phylum_id,ts.taxon_concept_class_id AS class_id,ts.taxon_concept_class_name AS class_name,ts.taxon_concept_order_id AS order_id,ts.taxon_concept_order_name AS order_name,ts.taxon_concept_family_id AS family_id,ts.taxon_concept_family_name AS family_name,ts.taxon_concept_genus_id AS genus_id,ts.taxon_concept_genus_name AS genus_name,CASE WHEN ts.reported_by_exporter THEN ts.quantity ELSE NULL END AS exporter_reported_quantity,CASE WHEN ts.reported_by_exporter THEN NULL ELSE ts.quantity END AS importer_reported_quantity,unit.id AS unit_id,unit.name_en AS unit,importer.id AS importer_id,importer.iso_code2 AS importer_iso,importer.name_en AS importer,exporter.id AS exporter_id,exporter.iso_code2 AS exporter_iso,exporter.name_en AS exporter,NULL AS origin,purpose.id AS purpose_id,purpose.name_en AS purpose,source.id AS source_id,source.name_en AS source,term.id AS term_id,term.name_en AS term,ts.import_permits_ids AS import_permits,ts.export_permits_ids AS export_permits,ts.origin_permits_ids AS origin_permits,ts.import_permit_number AS import_permit,ts.export_permit_number AS export_permit,ts.origin_permit_number AS origin_permit,'Quota' AS issue_type,'Listing_annotations' AS details_of_compliance_issue,' 02/01/2017' AS compliance_type_start_date,'Present' AS compliance_type_end_date,'Lanthanotus borneensis' AS compliance_type_taxon,ts.taxon_concept_rank_id AS rank_id,'SPECIES' AS rank_name,'0' AS quota_quantity,'**II** [FAMILY listing Lanthanotidae spp.] Zero export quota for wild specimens for commercial purposes.' AS notes
      FROM trade_shipments_with_taxa_view ts
      
      INNER JOIN geo_entities AS exporter ON exporter.id = ts.exporter_id
      INNER JOIN geo_entities AS importer ON importer.id = ts.importer_id
      LEFT OUTER JOIN trade_codes source ON ts.source_id = source.id
      LEFT OUTER JOIN trade_codes purpose ON ts.purpose_id = purpose.id
      LEFT OUTER JOIN trade_codes unit ON ts.unit_id = unit.id
      LEFT OUTER JOIN trade_codes term ON ts.term_id = term.id
    
      WHERE ts.id IN (
        SELECT UNNEST(sub.ids)
        FROM (
          
          SELECT ARRAY_AGG(ts.id) AS ids
          FROM trade_shipments_with_taxa_view ts
          
          INNER JOIN geo_entities AS exporter ON exporter.id = ts.exporter_id
          LEFT OUTER JOIN trade_codes source ON ts.source_id = source.id
          LEFT OUTER JOIN trade_codes purpose ON ts.purpose_id = purpose.id
          LEFT OUTER JOIN trade_codes unit ON ts.unit_id = unit.id
          LEFT OUTER JOIN trade_codes term ON ts.term_id = term.id
    
          WHERE ts.year >= 2017 AND ts.year <= 2018 AND ts.taxon_concept_id = 67618 AND TRUE AND TRUE AND TRUE AND source.code IN ('W') AND purpose.code IN ('T') AND ts.country_of_origin_id IS NULL
          AND (source.name_en != 'Confiscations/seizures' OR ts.source_id IS NULL)
          GROUP BY year, reported_by_exporter
          HAVING SUM(quantity) > 0
    
        ) sub
      )
      ORDER BY ts.year, ts.taxon_concept_full_name, ts.exporter_id, ts.importer_id
    )
    
    UNION    

    (
      SELECT ts.id AS id,ts.year AS year,ts.appendix AS appendix,ts.taxon_concept_author_year AS author_year,ts.taxon_concept_name_status AS name_status,ts.taxon_concept_id,ts.taxon_concept_full_name AS taxon_name,ts.taxon_concept_phylum_id AS phylum_id,ts.taxon_concept_class_id AS class_id,ts.taxon_concept_class_name AS class_name,ts.taxon_concept_order_id AS order_id,ts.taxon_concept_order_name AS order_name,ts.taxon_concept_family_id AS family_id,ts.taxon_concept_family_name AS family_name,ts.taxon_concept_genus_id AS genus_id,ts.taxon_concept_genus_name AS genus_name,CASE WHEN ts.reported_by_exporter THEN ts.quantity ELSE NULL END AS exporter_reported_quantity,CASE WHEN ts.reported_by_exporter THEN NULL ELSE ts.quantity END AS importer_reported_quantity,unit.id AS unit_id,unit.name_en AS unit,importer.id AS importer_id,importer.iso_code2 AS importer_iso,importer.name_en AS importer,exporter.id AS exporter_id,exporter.iso_code2 AS exporter_iso,exporter.name_en AS exporter,NULL AS origin,purpose.id AS purpose_id,purpose.name_en AS purpose,source.id AS source_id,source.name_en AS source,term.id AS term_id,term.name_en AS term,ts.import_permits_ids AS import_permits,ts.export_permits_ids AS export_permits,ts.origin_permits_ids AS origin_permits,ts.import_permit_number AS import_permit,ts.export_permit_number AS export_permit,ts.origin_permit_number AS origin_permit,'Quota' AS issue_type,'Listing_annotations' AS details_of_compliance_issue,'12/06/2013' AS compliance_type_start_date,'Present' AS compliance_type_end_date,'Chelodina mccordi' AS compliance_type_taxon,ts.taxon_concept_rank_id AS rank_id,'SPECIES' AS rank_name,'0' AS quota_quantity,'**II** Zero export quota for specimens from the wild.' AS notes
      FROM trade_shipments_with_taxa_view ts
      
      INNER JOIN geo_entities AS exporter ON exporter.id = ts.exporter_id
      INNER JOIN geo_entities AS importer ON importer.id = ts.importer_id
      LEFT OUTER JOIN trade_codes source ON ts.source_id = source.id
      LEFT OUTER JOIN trade_codes purpose ON ts.purpose_id = purpose.id
      LEFT OUTER JOIN trade_codes unit ON ts.unit_id = unit.id
      LEFT OUTER JOIN trade_codes term ON ts.term_id = term.id
    
      WHERE ts.id IN (
        SELECT UNNEST(sub.ids)
        FROM (
          
          SELECT ARRAY_AGG(ts.id) AS ids
          FROM trade_shipments_with_taxa_view ts
          
          INNER JOIN geo_entities AS exporter ON exporter.id = ts.exporter_id
          LEFT OUTER JOIN trade_codes source ON ts.source_id = source.id
          LEFT OUTER JOIN trade_codes purpose ON ts.purpose_id = purpose.id
          LEFT OUTER JOIN trade_codes unit ON ts.unit_id = unit.id
          LEFT OUTER JOIN trade_codes term ON ts.term_id = term.id
    
          WHERE ts.year >= 2013 AND ts.year <= 2018 AND ts.taxon_concept_id = 7441 AND TRUE AND TRUE AND TRUE AND source.code IN ('W') AND TRUE AND ts.country_of_origin_id IS NULL
          AND (source.name_en != 'Confiscations/seizures' OR ts.source_id IS NULL)
          GROUP BY year, reported_by_exporter
          HAVING SUM(quantity) > 0
    
        ) sub
      )
      ORDER BY ts.year, ts.taxon_concept_full_name, ts.exporter_id, ts.importer_id
    )
    
    UNION    

    (
      SELECT ts.id AS id,ts.year AS year,ts.appendix AS appendix,ts.taxon_concept_author_year AS author_year,ts.taxon_concept_name_status AS name_status,ts.taxon_concept_id,ts.taxon_concept_full_name AS taxon_name,ts.taxon_concept_phylum_id AS phylum_id,ts.taxon_concept_class_id AS class_id,ts.taxon_concept_class_name AS class_name,ts.taxon_concept_order_id AS order_id,ts.taxon_concept_order_name AS order_name,ts.taxon_concept_family_id AS family_id,ts.taxon_concept_family_name AS family_name,ts.taxon_concept_genus_id AS genus_id,ts.taxon_concept_genus_name AS genus_name,CASE WHEN ts.reported_by_exporter THEN ts.quantity ELSE NULL END AS exporter_reported_quantity,CASE WHEN ts.reported_by_exporter THEN NULL ELSE ts.quantity END AS importer_reported_quantity,unit.id AS unit_id,unit.name_en AS unit,importer.id AS importer_id,importer.iso_code2 AS importer_iso,importer.name_en AS importer,exporter.id AS exporter_id,exporter.iso_code2 AS exporter_iso,exporter.name_en AS exporter,NULL AS origin,purpose.id AS purpose_id,purpose.name_en AS purpose,source.id AS source_id,source.name_en AS source,term.id AS term_id,term.name_en AS term,ts.import_permits_ids AS import_permits,ts.export_permits_ids AS export_permits,ts.origin_permits_ids AS origin_permits,ts.import_permit_number AS import_permit,ts.export_permit_number AS export_permit,ts.origin_permit_number AS origin_permit,'Quota' AS issue_type,'Listing_annotations' AS details_of_compliance_issue,'12/06/2013' AS compliance_type_start_date,'Present' AS compliance_type_end_date,'Batagur borneoensis' AS compliance_type_taxon,ts.taxon_concept_rank_id AS rank_id,'SPECIES' AS rank_name,'0' AS quota_quantity,'**II** Zero quota for wild specimens for commercial purposes.' AS notes
      FROM trade_shipments_with_taxa_view ts
      
      INNER JOIN geo_entities AS exporter ON exporter.id = ts.exporter_id
      INNER JOIN geo_entities AS importer ON importer.id = ts.importer_id
      LEFT OUTER JOIN trade_codes source ON ts.source_id = source.id
      LEFT OUTER JOIN trade_codes purpose ON ts.purpose_id = purpose.id
      LEFT OUTER JOIN trade_codes unit ON ts.unit_id = unit.id
      LEFT OUTER JOIN trade_codes term ON ts.term_id = term.id
    
      WHERE ts.id IN (
        SELECT UNNEST(sub.ids)
        FROM (
          
          SELECT ARRAY_AGG(ts.id) AS ids
          FROM trade_shipments_with_taxa_view ts
          
          INNER JOIN geo_entities AS exporter ON exporter.id = ts.exporter_id
          LEFT OUTER JOIN trade_codes source ON ts.source_id = source.id
          LEFT OUTER JOIN trade_codes purpose ON ts.purpose_id = purpose.id
          LEFT OUTER JOIN trade_codes unit ON ts.unit_id = unit.id
          LEFT OUTER JOIN trade_codes term ON ts.term_id = term.id
    
          WHERE ts.year >= 2013 AND ts.year <= 2018 AND ts.taxon_concept_id = 4927 AND TRUE AND TRUE AND TRUE AND source.code IN ('W') AND purpose.code IN ('T') AND ts.country_of_origin_id IS NULL
          AND (source.name_en != 'Confiscations/seizures' OR ts.source_id IS NULL)
          GROUP BY year, reported_by_exporter
          HAVING SUM(quantity) > 0
    
        ) sub
      )
      ORDER BY ts.year, ts.taxon_concept_full_name, ts.exporter_id, ts.importer_id
    )
    
    UNION    

    (
      SELECT ts.id AS id,ts.year AS year,ts.appendix AS appendix,ts.taxon_concept_author_year AS author_year,ts.taxon_concept_name_status AS name_status,ts.taxon_concept_id,ts.taxon_concept_full_name AS taxon_name,ts.taxon_concept_phylum_id AS phylum_id,ts.taxon_concept_class_id AS class_id,ts.taxon_concept_class_name AS class_name,ts.taxon_concept_order_id AS order_id,ts.taxon_concept_order_name AS order_name,ts.taxon_concept_family_id AS family_id,ts.taxon_concept_family_name AS family_name,ts.taxon_concept_genus_id AS genus_id,ts.taxon_concept_genus_name AS genus_name,CASE WHEN ts.reported_by_exporter THEN ts.quantity ELSE NULL END AS exporter_reported_quantity,CASE WHEN ts.reported_by_exporter THEN NULL ELSE ts.quantity END AS importer_reported_quantity,unit.id AS unit_id,unit.name_en AS unit,importer.id AS importer_id,importer.iso_code2 AS importer_iso,importer.name_en AS importer,exporter.id AS exporter_id,exporter.iso_code2 AS exporter_iso,exporter.name_en AS exporter,NULL AS origin,purpose.id AS purpose_id,purpose.name_en AS purpose,source.id AS source_id,source.name_en AS source,term.id AS term_id,term.name_en AS term,ts.import_permits_ids AS import_permits,ts.export_permits_ids AS export_permits,ts.origin_permits_ids AS origin_permits,ts.import_permit_number AS import_permit,ts.export_permit_number AS export_permit,ts.origin_permit_number AS origin_permit,'Quota' AS issue_type,'Listing_annotations' AS details_of_compliance_issue,'12/06/2013' AS compliance_type_start_date,'Present' AS compliance_type_end_date,'Batagur trivittata' AS compliance_type_taxon,ts.taxon_concept_rank_id AS rank_id,'SPECIES' AS rank_name,'0' AS quota_quantity,'**II** Zero quota for wild specimens for commercial purposes.' AS notes
      FROM trade_shipments_with_taxa_view ts
      
      INNER JOIN geo_entities AS exporter ON exporter.id = ts.exporter_id
      INNER JOIN geo_entities AS importer ON importer.id = ts.importer_id
      LEFT OUTER JOIN trade_codes source ON ts.source_id = source.id
      LEFT OUTER JOIN trade_codes purpose ON ts.purpose_id = purpose.id
      LEFT OUTER JOIN trade_codes unit ON ts.unit_id = unit.id
      LEFT OUTER JOIN trade_codes term ON ts.term_id = term.id
    
      WHERE ts.id IN (
        SELECT UNNEST(sub.ids)
        FROM (
          
          SELECT ARRAY_AGG(ts.id) AS ids
          FROM trade_shipments_with_taxa_view ts
          
          INNER JOIN geo_entities AS exporter ON exporter.id = ts.exporter_id
          LEFT OUTER JOIN trade_codes source ON ts.source_id = source.id
          LEFT OUTER JOIN trade_codes purpose ON ts.purpose_id = purpose.id
          LEFT OUTER JOIN trade_codes unit ON ts.unit_id = unit.id
          LEFT OUTER JOIN trade_codes term ON ts.term_id = term.id
    
          WHERE ts.year >= 2013 AND ts.year <= 2018 AND ts.taxon_concept_id = 4397 AND TRUE AND TRUE AND TRUE AND source.code IN ('W') AND purpose.code IN ('T') AND ts.country_of_origin_id IS NULL
          AND (source.name_en != 'Confiscations/seizures' OR ts.source_id IS NULL)
          GROUP BY year, reported_by_exporter
          HAVING SUM(quantity) > 0
    
        ) sub
      )
      ORDER BY ts.year, ts.taxon_concept_full_name, ts.exporter_id, ts.importer_id
    )
    
    UNION    

    (
      SELECT ts.id AS id,ts.year AS year,ts.appendix AS appendix,ts.taxon_concept_author_year AS author_year,ts.taxon_concept_name_status AS name_status,ts.taxon_concept_id,ts.taxon_concept_full_name AS taxon_name,ts.taxon_concept_phylum_id AS phylum_id,ts.taxon_concept_class_id AS class_id,ts.taxon_concept_class_name AS class_name,ts.taxon_concept_order_id AS order_id,ts.taxon_concept_order_name AS order_name,ts.taxon_concept_family_id AS family_id,ts.taxon_concept_family_name AS family_name,ts.taxon_concept_genus_id AS genus_id,ts.taxon_concept_genus_name AS genus_name,CASE WHEN ts.reported_by_exporter THEN ts.quantity ELSE NULL END AS exporter_reported_quantity,CASE WHEN ts.reported_by_exporter THEN NULL ELSE ts.quantity END AS importer_reported_quantity,unit.id AS unit_id,unit.name_en AS unit,importer.id AS importer_id,importer.iso_code2 AS importer_iso,importer.name_en AS importer,exporter.id AS exporter_id,exporter.iso_code2 AS exporter_iso,exporter.name_en AS exporter,NULL AS origin,purpose.id AS purpose_id,purpose.name_en AS purpose,source.id AS source_id,source.name_en AS source,term.id AS term_id,term.name_en AS term,ts.import_permits_ids AS import_permits,ts.export_permits_ids AS export_permits,ts.origin_permits_ids AS origin_permits,ts.import_permit_number AS import_permit,ts.export_permit_number AS export_permit,ts.origin_permit_number AS origin_permit,'Quota' AS issue_type,'Listing_annotations' AS details_of_compliance_issue,'12/06/2013' AS compliance_type_start_date,'Present' AS compliance_type_end_date,'Cuora aurocapitata' AS compliance_type_taxon,ts.taxon_concept_rank_id AS rank_id,'SPECIES' AS rank_name,'0' AS quota_quantity,'**II** [GENUS listing Cuora spp.] Zero quota for wild specimens for commercial purposes for Cuora aurocapitata, C. bourreti, C. flavomarginata, C. galbinifrons, C. mccordi, C. mouhotii, C. pani, C. picturata, C. trifasciata, C. yunnanensis and C. zhoui.' AS notes
      FROM trade_shipments_with_taxa_view ts
      
      INNER JOIN geo_entities AS exporter ON exporter.id = ts.exporter_id
      INNER JOIN geo_entities AS importer ON importer.id = ts.importer_id
      LEFT OUTER JOIN trade_codes source ON ts.source_id = source.id
      LEFT OUTER JOIN trade_codes purpose ON ts.purpose_id = purpose.id
      LEFT OUTER JOIN trade_codes unit ON ts.unit_id = unit.id
      LEFT OUTER JOIN trade_codes term ON ts.term_id = term.id
    
      WHERE ts.id IN (
        SELECT UNNEST(sub.ids)
        FROM (
          
          SELECT ARRAY_AGG(ts.id) AS ids
          FROM trade_shipments_with_taxa_view ts
          
          INNER JOIN geo_entities AS exporter ON exporter.id = ts.exporter_id
          LEFT OUTER JOIN trade_codes source ON ts.source_id = source.id
          LEFT OUTER JOIN trade_codes purpose ON ts.purpose_id = purpose.id
          LEFT OUTER JOIN trade_codes unit ON ts.unit_id = unit.id
          LEFT OUTER JOIN trade_codes term ON ts.term_id = term.id
    
          WHERE ts.year >= 2013 AND ts.year <= 2018 AND ts.taxon_concept_id = 8231 AND TRUE AND TRUE AND TRUE AND source.code IN ('W') AND purpose.code IN ('T') AND ts.country_of_origin_id IS NULL
          AND (source.name_en != 'Confiscations/seizures' OR ts.source_id IS NULL)
          GROUP BY year, reported_by_exporter
          HAVING SUM(quantity) > 0
    
        ) sub
      )
      ORDER BY ts.year, ts.taxon_concept_full_name, ts.exporter_id, ts.importer_id
    )
    
    UNION    

    (
      SELECT ts.id AS id,ts.year AS year,ts.appendix AS appendix,ts.taxon_concept_author_year AS author_year,ts.taxon_concept_name_status AS name_status,ts.taxon_concept_id,ts.taxon_concept_full_name AS taxon_name,ts.taxon_concept_phylum_id AS phylum_id,ts.taxon_concept_class_id AS class_id,ts.taxon_concept_class_name AS class_name,ts.taxon_concept_order_id AS order_id,ts.taxon_concept_order_name AS order_name,ts.taxon_concept_family_id AS family_id,ts.taxon_concept_family_name AS family_name,ts.taxon_concept_genus_id AS genus_id,ts.taxon_concept_genus_name AS genus_name,CASE WHEN ts.reported_by_exporter THEN ts.quantity ELSE NULL END AS exporter_reported_quantity,CASE WHEN ts.reported_by_exporter THEN NULL ELSE ts.quantity END AS importer_reported_quantity,unit.id AS unit_id,unit.name_en AS unit,importer.id AS importer_id,importer.iso_code2 AS importer_iso,importer.name_en AS importer,exporter.id AS exporter_id,exporter.iso_code2 AS exporter_iso,exporter.name_en AS exporter,NULL AS origin,purpose.id AS purpose_id,purpose.name_en AS purpose,source.id AS source_id,source.name_en AS source,term.id AS term_id,term.name_en AS term,ts.import_permits_ids AS import_permits,ts.export_permits_ids AS export_permits,ts.origin_permits_ids AS origin_permits,ts.import_permit_number AS import_permit,ts.export_permit_number AS export_permit,ts.origin_permit_number AS origin_permit,'Quota' AS issue_type,'Listing_annotations' AS details_of_compliance_issue,'12/06/2013' AS compliance_type_start_date,'Present' AS compliance_type_end_date,'Cuora bourreti' AS compliance_type_taxon,ts.taxon_concept_rank_id AS rank_id,'SPECIES' AS rank_name,'0' AS quota_quantity,'**II** [GENUS listing Cuora spp.] Zero quota for wild specimens for commercial purposes for Cuora aurocapitata, C. bourreti, C. flavomarginata, C. galbinifrons, C. mccordi, C. mouhotii, C. pani, C. picturata, C. trifasciata, C. yunnanensis and C. zhoui.' AS notes
      FROM trade_shipments_with_taxa_view ts
      
      INNER JOIN geo_entities AS exporter ON exporter.id = ts.exporter_id
      INNER JOIN geo_entities AS importer ON importer.id = ts.importer_id
      LEFT OUTER JOIN trade_codes source ON ts.source_id = source.id
      LEFT OUTER JOIN trade_codes purpose ON ts.purpose_id = purpose.id
      LEFT OUTER JOIN trade_codes unit ON ts.unit_id = unit.id
      LEFT OUTER JOIN trade_codes term ON ts.term_id = term.id
    
      WHERE ts.id IN (
        SELECT UNNEST(sub.ids)
        FROM (
          
          SELECT ARRAY_AGG(ts.id) AS ids
          FROM trade_shipments_with_taxa_view ts
          
          INNER JOIN geo_entities AS exporter ON exporter.id = ts.exporter_id
          LEFT OUTER JOIN trade_codes source ON ts.source_id = source.id
          LEFT OUTER JOIN trade_codes purpose ON ts.purpose_id = purpose.id
          LEFT OUTER JOIN trade_codes unit ON ts.unit_id = unit.id
          LEFT OUTER JOIN trade_codes term ON ts.term_id = term.id
    
          WHERE ts.year >= 2013 AND ts.year <= 2018 AND ts.taxon_concept_id = 65766 AND TRUE AND TRUE AND TRUE AND source.code IN ('W') AND purpose.code IN ('T') AND ts.country_of_origin_id IS NULL
          AND (source.name_en != 'Confiscations/seizures' OR ts.source_id IS NULL)
          GROUP BY year, reported_by_exporter
          HAVING SUM(quantity) > 0
    
        ) sub
      )
      ORDER BY ts.year, ts.taxon_concept_full_name, ts.exporter_id, ts.importer_id
    )
    
    UNION    

    (
      SELECT ts.id AS id,ts.year AS year,ts.appendix AS appendix,ts.taxon_concept_author_year AS author_year,ts.taxon_concept_name_status AS name_status,ts.taxon_concept_id,ts.taxon_concept_full_name AS taxon_name,ts.taxon_concept_phylum_id AS phylum_id,ts.taxon_concept_class_id AS class_id,ts.taxon_concept_class_name AS class_name,ts.taxon_concept_order_id AS order_id,ts.taxon_concept_order_name AS order_name,ts.taxon_concept_family_id AS family_id,ts.taxon_concept_family_name AS family_name,ts.taxon_concept_genus_id AS genus_id,ts.taxon_concept_genus_name AS genus_name,CASE WHEN ts.reported_by_exporter THEN ts.quantity ELSE NULL END AS exporter_reported_quantity,CASE WHEN ts.reported_by_exporter THEN NULL ELSE ts.quantity END AS importer_reported_quantity,unit.id AS unit_id,unit.name_en AS unit,importer.id AS importer_id,importer.iso_code2 AS importer_iso,importer.name_en AS importer,exporter.id AS exporter_id,exporter.iso_code2 AS exporter_iso,exporter.name_en AS exporter,NULL AS origin,purpose.id AS purpose_id,purpose.name_en AS purpose,source.id AS source_id,source.name_en AS source,term.id AS term_id,term.name_en AS term,ts.import_permits_ids AS import_permits,ts.export_permits_ids AS export_permits,ts.origin_permits_ids AS origin_permits,ts.import_permit_number AS import_permit,ts.export_permit_number AS export_permit,ts.origin_permit_number AS origin_permit,'Quota' AS issue_type,'Listing_annotations' AS details_of_compliance_issue,'12/06/2013' AS compliance_type_start_date,'Present' AS compliance_type_end_date,'Cuora flavomarginata' AS compliance_type_taxon,ts.taxon_concept_rank_id AS rank_id,'SPECIES' AS rank_name,'0' AS quota_quantity,'**II** [GENUS listing Cuora spp.] Zero quota for wild specimens for commercial purposes for Cuora aurocapitata, C. bourreti, C. flavomarginata, C. galbinifrons, C. mccordi, C. mouhotii, C. pani, C. picturata, C. trifasciata, C. yunnanensis and C. zhoui.' AS notes
      FROM trade_shipments_with_taxa_view ts
      
      INNER JOIN geo_entities AS exporter ON exporter.id = ts.exporter_id
      INNER JOIN geo_entities AS importer ON importer.id = ts.importer_id
      LEFT OUTER JOIN trade_codes source ON ts.source_id = source.id
      LEFT OUTER JOIN trade_codes purpose ON ts.purpose_id = purpose.id
      LEFT OUTER JOIN trade_codes unit ON ts.unit_id = unit.id
      LEFT OUTER JOIN trade_codes term ON ts.term_id = term.id
    
      WHERE ts.id IN (
        SELECT UNNEST(sub.ids)
        FROM (
          
          SELECT ARRAY_AGG(ts.id) AS ids
          FROM trade_shipments_with_taxa_view ts
          
          INNER JOIN geo_entities AS exporter ON exporter.id = ts.exporter_id
          LEFT OUTER JOIN trade_codes source ON ts.source_id = source.id
          LEFT OUTER JOIN trade_codes purpose ON ts.purpose_id = purpose.id
          LEFT OUTER JOIN trade_codes unit ON ts.unit_id = unit.id
          LEFT OUTER JOIN trade_codes term ON ts.term_id = term.id
    
          WHERE ts.year >= 2013 AND ts.year <= 2018 AND ts.taxon_concept_id = 7271 AND TRUE AND TRUE AND TRUE AND source.code IN ('W') AND purpose.code IN ('T') AND ts.country_of_origin_id IS NULL
          AND (source.name_en != 'Confiscations/seizures' OR ts.source_id IS NULL)
          GROUP BY year, reported_by_exporter
          HAVING SUM(quantity) > 0
    
        ) sub
      )
      ORDER BY ts.year, ts.taxon_concept_full_name, ts.exporter_id, ts.importer_id
    )
    
    UNION    

    (
      SELECT ts.id AS id,ts.year AS year,ts.appendix AS appendix,ts.taxon_concept_author_year AS author_year,ts.taxon_concept_name_status AS name_status,ts.taxon_concept_id,ts.taxon_concept_full_name AS taxon_name,ts.taxon_concept_phylum_id AS phylum_id,ts.taxon_concept_class_id AS class_id,ts.taxon_concept_class_name AS class_name,ts.taxon_concept_order_id AS order_id,ts.taxon_concept_order_name AS order_name,ts.taxon_concept_family_id AS family_id,ts.taxon_concept_family_name AS family_name,ts.taxon_concept_genus_id AS genus_id,ts.taxon_concept_genus_name AS genus_name,CASE WHEN ts.reported_by_exporter THEN ts.quantity ELSE NULL END AS exporter_reported_quantity,CASE WHEN ts.reported_by_exporter THEN NULL ELSE ts.quantity END AS importer_reported_quantity,unit.id AS unit_id,unit.name_en AS unit,importer.id AS importer_id,importer.iso_code2 AS importer_iso,importer.name_en AS importer,exporter.id AS exporter_id,exporter.iso_code2 AS exporter_iso,exporter.name_en AS exporter,NULL AS origin,purpose.id AS purpose_id,purpose.name_en AS purpose,source.id AS source_id,source.name_en AS source,term.id AS term_id,term.name_en AS term,ts.import_permits_ids AS import_permits,ts.export_permits_ids AS export_permits,ts.origin_permits_ids AS origin_permits,ts.import_permit_number AS import_permit,ts.export_permit_number AS export_permit,ts.origin_permit_number AS origin_permit,'Quota' AS issue_type,'Listing_annotations' AS details_of_compliance_issue,'12/06/2013' AS compliance_type_start_date,'Present' AS compliance_type_end_date,'Cuora galbinifrons' AS compliance_type_taxon,ts.taxon_concept_rank_id AS rank_id,'SPECIES' AS rank_name,'0' AS quota_quantity,'**II** [GENUS listing Cuora spp.] Zero quota for wild specimens for commercial purposes for Cuora aurocapitata, C. bourreti, C. flavomarginata, C. galbinifrons, C. mccordi, C. mouhotii, C. pani, C. picturata, C. trifasciata, C. yunnanensis and C. zhoui.' AS notes
      FROM trade_shipments_with_taxa_view ts
      
      INNER JOIN geo_entities AS exporter ON exporter.id = ts.exporter_id
      INNER JOIN geo_entities AS importer ON importer.id = ts.importer_id
      LEFT OUTER JOIN trade_codes source ON ts.source_id = source.id
      LEFT OUTER JOIN trade_codes purpose ON ts.purpose_id = purpose.id
      LEFT OUTER JOIN trade_codes unit ON ts.unit_id = unit.id
      LEFT OUTER JOIN trade_codes term ON ts.term_id = term.id
    
      WHERE ts.id IN (
        SELECT UNNEST(sub.ids)
        FROM (
          
          SELECT ARRAY_AGG(ts.id) AS ids
          FROM trade_shipments_with_taxa_view ts
          
          INNER JOIN geo_entities AS exporter ON exporter.id = ts.exporter_id
          LEFT OUTER JOIN trade_codes source ON ts.source_id = source.id
          LEFT OUTER JOIN trade_codes purpose ON ts.purpose_id = purpose.id
          LEFT OUTER JOIN trade_codes unit ON ts.unit_id = unit.id
          LEFT OUTER JOIN trade_codes term ON ts.term_id = term.id
    
          WHERE ts.year >= 2013 AND ts.year <= 2018 AND ts.taxon_concept_id = 10210 AND TRUE AND TRUE AND TRUE AND source.code IN ('W') AND purpose.code IN ('T') AND ts.country_of_origin_id IS NULL
          AND (source.name_en != 'Confiscations/seizures' OR ts.source_id IS NULL)
          GROUP BY year, reported_by_exporter
          HAVING SUM(quantity) > 0
    
        ) sub
      )
      ORDER BY ts.year, ts.taxon_concept_full_name, ts.exporter_id, ts.importer_id
    )
    
    UNION    

    (
      SELECT ts.id AS id,ts.year AS year,ts.appendix AS appendix,ts.taxon_concept_author_year AS author_year,ts.taxon_concept_name_status AS name_status,ts.taxon_concept_id,ts.taxon_concept_full_name AS taxon_name,ts.taxon_concept_phylum_id AS phylum_id,ts.taxon_concept_class_id AS class_id,ts.taxon_concept_class_name AS class_name,ts.taxon_concept_order_id AS order_id,ts.taxon_concept_order_name AS order_name,ts.taxon_concept_family_id AS family_id,ts.taxon_concept_family_name AS family_name,ts.taxon_concept_genus_id AS genus_id,ts.taxon_concept_genus_name AS genus_name,CASE WHEN ts.reported_by_exporter THEN ts.quantity ELSE NULL END AS exporter_reported_quantity,CASE WHEN ts.reported_by_exporter THEN NULL ELSE ts.quantity END AS importer_reported_quantity,unit.id AS unit_id,unit.name_en AS unit,importer.id AS importer_id,importer.iso_code2 AS importer_iso,importer.name_en AS importer,exporter.id AS exporter_id,exporter.iso_code2 AS exporter_iso,exporter.name_en AS exporter,NULL AS origin,purpose.id AS purpose_id,purpose.name_en AS purpose,source.id AS source_id,source.name_en AS source,term.id AS term_id,term.name_en AS term,ts.import_permits_ids AS import_permits,ts.export_permits_ids AS export_permits,ts.origin_permits_ids AS origin_permits,ts.import_permit_number AS import_permit,ts.export_permit_number AS export_permit,ts.origin_permit_number AS origin_permit,'Quota' AS issue_type,'Listing_annotations' AS details_of_compliance_issue,'12/06/2013' AS compliance_type_start_date,'Present' AS compliance_type_end_date,'Cuora mccordi' AS compliance_type_taxon,ts.taxon_concept_rank_id AS rank_id,'SPECIES' AS rank_name,'0' AS quota_quantity,'**II** [GENUS listing Cuora spp.] Zero quota for wild specimens for commercial purposes for Cuora aurocapitata, C. bourreti, C. flavomarginata, C. galbinifrons, C. mccordi, C. mouhotii, C. pani, C. picturata, C. trifasciata, C. yunnanensis and C. zhoui.' AS notes
      FROM trade_shipments_with_taxa_view ts
      
      INNER JOIN geo_entities AS exporter ON exporter.id = ts.exporter_id
      INNER JOIN geo_entities AS importer ON importer.id = ts.importer_id
      LEFT OUTER JOIN trade_codes source ON ts.source_id = source.id
      LEFT OUTER JOIN trade_codes purpose ON ts.purpose_id = purpose.id
      LEFT OUTER JOIN trade_codes unit ON ts.unit_id = unit.id
      LEFT OUTER JOIN trade_codes term ON ts.term_id = term.id
    
      WHERE ts.id IN (
        SELECT UNNEST(sub.ids)
        FROM (
          
          SELECT ARRAY_AGG(ts.id) AS ids
          FROM trade_shipments_with_taxa_view ts
          
          INNER JOIN geo_entities AS exporter ON exporter.id = ts.exporter_id
          LEFT OUTER JOIN trade_codes source ON ts.source_id = source.id
          LEFT OUTER JOIN trade_codes purpose ON ts.purpose_id = purpose.id
          LEFT OUTER JOIN trade_codes unit ON ts.unit_id = unit.id
          LEFT OUTER JOIN trade_codes term ON ts.term_id = term.id
    
          WHERE ts.year >= 2013 AND ts.year <= 2018 AND ts.taxon_concept_id = 3678 AND TRUE AND TRUE AND TRUE AND source.code IN ('W') AND purpose.code IN ('T') AND ts.country_of_origin_id IS NULL
          AND (source.name_en != 'Confiscations/seizures' OR ts.source_id IS NULL)
          GROUP BY year, reported_by_exporter
          HAVING SUM(quantity) > 0
    
        ) sub
      )
      ORDER BY ts.year, ts.taxon_concept_full_name, ts.exporter_id, ts.importer_id
    )
    
    UNION    

    (
      SELECT ts.id AS id,ts.year AS year,ts.appendix AS appendix,ts.taxon_concept_author_year AS author_year,ts.taxon_concept_name_status AS name_status,ts.taxon_concept_id,ts.taxon_concept_full_name AS taxon_name,ts.taxon_concept_phylum_id AS phylum_id,ts.taxon_concept_class_id AS class_id,ts.taxon_concept_class_name AS class_name,ts.taxon_concept_order_id AS order_id,ts.taxon_concept_order_name AS order_name,ts.taxon_concept_family_id AS family_id,ts.taxon_concept_family_name AS family_name,ts.taxon_concept_genus_id AS genus_id,ts.taxon_concept_genus_name AS genus_name,CASE WHEN ts.reported_by_exporter THEN ts.quantity ELSE NULL END AS exporter_reported_quantity,CASE WHEN ts.reported_by_exporter THEN NULL ELSE ts.quantity END AS importer_reported_quantity,unit.id AS unit_id,unit.name_en AS unit,importer.id AS importer_id,importer.iso_code2 AS importer_iso,importer.name_en AS importer,exporter.id AS exporter_id,exporter.iso_code2 AS exporter_iso,exporter.name_en AS exporter,NULL AS origin,purpose.id AS purpose_id,purpose.name_en AS purpose,source.id AS source_id,source.name_en AS source,term.id AS term_id,term.name_en AS term,ts.import_permits_ids AS import_permits,ts.export_permits_ids AS export_permits,ts.origin_permits_ids AS origin_permits,ts.import_permit_number AS import_permit,ts.export_permit_number AS export_permit,ts.origin_permit_number AS origin_permit,'Quota' AS issue_type,'Listing_annotations' AS details_of_compliance_issue,'12/06/2013' AS compliance_type_start_date,'Present' AS compliance_type_end_date,'Cuora mouhotii' AS compliance_type_taxon,ts.taxon_concept_rank_id AS rank_id,'SPECIES' AS rank_name,'0' AS quota_quantity,'**II** [GENUS listing Cuora spp.] Zero quota for wild specimens for commercial purposes for Cuora aurocapitata, C. bourreti, C. flavomarginata, C. galbinifrons, C. mccordi, C. mouhotii, C. pani, C. picturata, C. trifasciata, C. yunnanensis and C. zhoui.' AS notes
      FROM trade_shipments_with_taxa_view ts
      
      INNER JOIN geo_entities AS exporter ON exporter.id = ts.exporter_id
      INNER JOIN geo_entities AS importer ON importer.id = ts.importer_id
      LEFT OUTER JOIN trade_codes source ON ts.source_id = source.id
      LEFT OUTER JOIN trade_codes purpose ON ts.purpose_id = purpose.id
      LEFT OUTER JOIN trade_codes unit ON ts.unit_id = unit.id
      LEFT OUTER JOIN trade_codes term ON ts.term_id = term.id
    
      WHERE ts.id IN (
        SELECT UNNEST(sub.ids)
        FROM (
          
          SELECT ARRAY_AGG(ts.id) AS ids
          FROM trade_shipments_with_taxa_view ts
          
          INNER JOIN geo_entities AS exporter ON exporter.id = ts.exporter_id
          LEFT OUTER JOIN trade_codes source ON ts.source_id = source.id
          LEFT OUTER JOIN trade_codes purpose ON ts.purpose_id = purpose.id
          LEFT OUTER JOIN trade_codes unit ON ts.unit_id = unit.id
          LEFT OUTER JOIN trade_codes term ON ts.term_id = term.id
    
          WHERE ts.year >= 2013 AND ts.year <= 2018 AND ts.taxon_concept_id = 10699 AND TRUE AND TRUE AND TRUE AND source.code IN ('W') AND purpose.code IN ('T') AND ts.country_of_origin_id IS NULL
          AND (source.name_en != 'Confiscations/seizures' OR ts.source_id IS NULL)
          GROUP BY year, reported_by_exporter
          HAVING SUM(quantity) > 0
    
        ) sub
      )
      ORDER BY ts.year, ts.taxon_concept_full_name, ts.exporter_id, ts.importer_id
    )
    
    UNION    

    (
      SELECT ts.id AS id,ts.year AS year,ts.appendix AS appendix,ts.taxon_concept_author_year AS author_year,ts.taxon_concept_name_status AS name_status,ts.taxon_concept_id,ts.taxon_concept_full_name AS taxon_name,ts.taxon_concept_phylum_id AS phylum_id,ts.taxon_concept_class_id AS class_id,ts.taxon_concept_class_name AS class_name,ts.taxon_concept_order_id AS order_id,ts.taxon_concept_order_name AS order_name,ts.taxon_concept_family_id AS family_id,ts.taxon_concept_family_name AS family_name,ts.taxon_concept_genus_id AS genus_id,ts.taxon_concept_genus_name AS genus_name,CASE WHEN ts.reported_by_exporter THEN ts.quantity ELSE NULL END AS exporter_reported_quantity,CASE WHEN ts.reported_by_exporter THEN NULL ELSE ts.quantity END AS importer_reported_quantity,unit.id AS unit_id,unit.name_en AS unit,importer.id AS importer_id,importer.iso_code2 AS importer_iso,importer.name_en AS importer,exporter.id AS exporter_id,exporter.iso_code2 AS exporter_iso,exporter.name_en AS exporter,NULL AS origin,purpose.id AS purpose_id,purpose.name_en AS purpose,source.id AS source_id,source.name_en AS source,term.id AS term_id,term.name_en AS term,ts.import_permits_ids AS import_permits,ts.export_permits_ids AS export_permits,ts.origin_permits_ids AS origin_permits,ts.import_permit_number AS import_permit,ts.export_permit_number AS export_permit,ts.origin_permit_number AS origin_permit,'Quota' AS issue_type,'Listing_annotations' AS details_of_compliance_issue,'12/06/2013' AS compliance_type_start_date,'Present' AS compliance_type_end_date,'Cuora pani' AS compliance_type_taxon,ts.taxon_concept_rank_id AS rank_id,'SPECIES' AS rank_name,'0' AS quota_quantity,'**II** [GENUS listing Cuora spp.] Zero quota for wild specimens for commercial purposes for Cuora aurocapitata, C. bourreti, C. flavomarginata, C. galbinifrons, C. mccordi, C. mouhotii, C. pani, C. picturata, C. trifasciata, C. yunnanensis and C. zhoui.' AS notes
      FROM trade_shipments_with_taxa_view ts
      
      INNER JOIN geo_entities AS exporter ON exporter.id = ts.exporter_id
      INNER JOIN geo_entities AS importer ON importer.id = ts.importer_id
      LEFT OUTER JOIN trade_codes source ON ts.source_id = source.id
      LEFT OUTER JOIN trade_codes purpose ON ts.purpose_id = purpose.id
      LEFT OUTER JOIN trade_codes unit ON ts.unit_id = unit.id
      LEFT OUTER JOIN trade_codes term ON ts.term_id = term.id
    
      WHERE ts.id IN (
        SELECT UNNEST(sub.ids)
        FROM (
          
          SELECT ARRAY_AGG(ts.id) AS ids
          FROM trade_shipments_with_taxa_view ts
          
          INNER JOIN geo_entities AS exporter ON exporter.id = ts.exporter_id
          LEFT OUTER JOIN trade_codes source ON ts.source_id = source.id
          LEFT OUTER JOIN trade_codes purpose ON ts.purpose_id = purpose.id
          LEFT OUTER JOIN trade_codes unit ON ts.unit_id = unit.id
          LEFT OUTER JOIN trade_codes term ON ts.term_id = term.id
    
          WHERE ts.year >= 2013 AND ts.year <= 2018 AND ts.taxon_concept_id = 6783 AND TRUE AND TRUE AND TRUE AND source.code IN ('W') AND purpose.code IN ('T') AND ts.country_of_origin_id IS NULL
          AND (source.name_en != 'Confiscations/seizures' OR ts.source_id IS NULL)
          GROUP BY year, reported_by_exporter
          HAVING SUM(quantity) > 0
    
        ) sub
      )
      ORDER BY ts.year, ts.taxon_concept_full_name, ts.exporter_id, ts.importer_id
    )
    
    UNION    

    (
      SELECT ts.id AS id,ts.year AS year,ts.appendix AS appendix,ts.taxon_concept_author_year AS author_year,ts.taxon_concept_name_status AS name_status,ts.taxon_concept_id,ts.taxon_concept_full_name AS taxon_name,ts.taxon_concept_phylum_id AS phylum_id,ts.taxon_concept_class_id AS class_id,ts.taxon_concept_class_name AS class_name,ts.taxon_concept_order_id AS order_id,ts.taxon_concept_order_name AS order_name,ts.taxon_concept_family_id AS family_id,ts.taxon_concept_family_name AS family_name,ts.taxon_concept_genus_id AS genus_id,ts.taxon_concept_genus_name AS genus_name,CASE WHEN ts.reported_by_exporter THEN ts.quantity ELSE NULL END AS exporter_reported_quantity,CASE WHEN ts.reported_by_exporter THEN NULL ELSE ts.quantity END AS importer_reported_quantity,unit.id AS unit_id,unit.name_en AS unit,importer.id AS importer_id,importer.iso_code2 AS importer_iso,importer.name_en AS importer,exporter.id AS exporter_id,exporter.iso_code2 AS exporter_iso,exporter.name_en AS exporter,NULL AS origin,purpose.id AS purpose_id,purpose.name_en AS purpose,source.id AS source_id,source.name_en AS source,term.id AS term_id,term.name_en AS term,ts.import_permits_ids AS import_permits,ts.export_permits_ids AS export_permits,ts.origin_permits_ids AS origin_permits,ts.import_permit_number AS import_permit,ts.export_permit_number AS export_permit,ts.origin_permit_number AS origin_permit,'Quota' AS issue_type,'Listing_annotations' AS details_of_compliance_issue,'12/06/2013' AS compliance_type_start_date,'Present' AS compliance_type_end_date,'Cuora picturata' AS compliance_type_taxon,ts.taxon_concept_rank_id AS rank_id,'SPECIES' AS rank_name,'0' AS quota_quantity,'**II** [GENUS listing Cuora spp.] Zero quota for wild specimens for commercial purposes for Cuora aurocapitata, C. bourreti, C. flavomarginata, C. galbinifrons, C. mccordi, C. mouhotii, C. pani, C. picturata, C. trifasciata, C. yunnanensis and C. zhoui.' AS notes
      FROM trade_shipments_with_taxa_view ts
      
      INNER JOIN geo_entities AS exporter ON exporter.id = ts.exporter_id
      INNER JOIN geo_entities AS importer ON importer.id = ts.importer_id
      LEFT OUTER JOIN trade_codes source ON ts.source_id = source.id
      LEFT OUTER JOIN trade_codes purpose ON ts.purpose_id = purpose.id
      LEFT OUTER JOIN trade_codes unit ON ts.unit_id = unit.id
      LEFT OUTER JOIN trade_codes term ON ts.term_id = term.id
    
      WHERE ts.id IN (
        SELECT UNNEST(sub.ids)
        FROM (
          
          SELECT ARRAY_AGG(ts.id) AS ids
          FROM trade_shipments_with_taxa_view ts
          
          INNER JOIN geo_entities AS exporter ON exporter.id = ts.exporter_id
          LEFT OUTER JOIN trade_codes source ON ts.source_id = source.id
          LEFT OUTER JOIN trade_codes purpose ON ts.purpose_id = purpose.id
          LEFT OUTER JOIN trade_codes unit ON ts.unit_id = unit.id
          LEFT OUTER JOIN trade_codes term ON ts.term_id = term.id
    
          WHERE ts.year >= 2013 AND ts.year <= 2018 AND ts.taxon_concept_id = 65767 AND TRUE AND TRUE AND TRUE AND source.code IN ('W') AND purpose.code IN ('T') AND ts.country_of_origin_id IS NULL
          AND (source.name_en != 'Confiscations/seizures' OR ts.source_id IS NULL)
          GROUP BY year, reported_by_exporter
          HAVING SUM(quantity) > 0
    
        ) sub
      )
      ORDER BY ts.year, ts.taxon_concept_full_name, ts.exporter_id, ts.importer_id
    )
    
    UNION    

    (
      SELECT ts.id AS id,ts.year AS year,ts.appendix AS appendix,ts.taxon_concept_author_year AS author_year,ts.taxon_concept_name_status AS name_status,ts.taxon_concept_id,ts.taxon_concept_full_name AS taxon_name,ts.taxon_concept_phylum_id AS phylum_id,ts.taxon_concept_class_id AS class_id,ts.taxon_concept_class_name AS class_name,ts.taxon_concept_order_id AS order_id,ts.taxon_concept_order_name AS order_name,ts.taxon_concept_family_id AS family_id,ts.taxon_concept_family_name AS family_name,ts.taxon_concept_genus_id AS genus_id,ts.taxon_concept_genus_name AS genus_name,CASE WHEN ts.reported_by_exporter THEN ts.quantity ELSE NULL END AS exporter_reported_quantity,CASE WHEN ts.reported_by_exporter THEN NULL ELSE ts.quantity END AS importer_reported_quantity,unit.id AS unit_id,unit.name_en AS unit,importer.id AS importer_id,importer.iso_code2 AS importer_iso,importer.name_en AS importer,exporter.id AS exporter_id,exporter.iso_code2 AS exporter_iso,exporter.name_en AS exporter,NULL AS origin,purpose.id AS purpose_id,purpose.name_en AS purpose,source.id AS source_id,source.name_en AS source,term.id AS term_id,term.name_en AS term,ts.import_permits_ids AS import_permits,ts.export_permits_ids AS export_permits,ts.origin_permits_ids AS origin_permits,ts.import_permit_number AS import_permit,ts.export_permit_number AS export_permit,ts.origin_permit_number AS origin_permit,'Quota' AS issue_type,'Listing_annotations' AS details_of_compliance_issue,'12/06/2013' AS compliance_type_start_date,'Present' AS compliance_type_end_date,'Cuora trifasciata' AS compliance_type_taxon,ts.taxon_concept_rank_id AS rank_id,'SPECIES' AS rank_name,'0' AS quota_quantity,'**II** [GENUS listing Cuora spp.] Zero quota for wild specimens for commercial purposes for Cuora aurocapitata, C. bourreti, C. flavomarginata, C. galbinifrons, C. mccordi, C. mouhotii, C. pani, C. picturata, C. trifasciata, C. yunnanensis and C. zhoui.' AS notes
      FROM trade_shipments_with_taxa_view ts
      
      INNER JOIN geo_entities AS exporter ON exporter.id = ts.exporter_id
      INNER JOIN geo_entities AS importer ON importer.id = ts.importer_id
      LEFT OUTER JOIN trade_codes source ON ts.source_id = source.id
      LEFT OUTER JOIN trade_codes purpose ON ts.purpose_id = purpose.id
      LEFT OUTER JOIN trade_codes unit ON ts.unit_id = unit.id
      LEFT OUTER JOIN trade_codes term ON ts.term_id = term.id
    
      WHERE ts.id IN (
        SELECT UNNEST(sub.ids)
        FROM (
          
          SELECT ARRAY_AGG(ts.id) AS ids
          FROM trade_shipments_with_taxa_view ts
          
          INNER JOIN geo_entities AS exporter ON exporter.id = ts.exporter_id
          LEFT OUTER JOIN trade_codes source ON ts.source_id = source.id
          LEFT OUTER JOIN trade_codes purpose ON ts.purpose_id = purpose.id
          LEFT OUTER JOIN trade_codes unit ON ts.unit_id = unit.id
          LEFT OUTER JOIN trade_codes term ON ts.term_id = term.id
    
          WHERE ts.year >= 2013 AND ts.year <= 2018 AND ts.taxon_concept_id = 6023 AND TRUE AND TRUE AND TRUE AND source.code IN ('W') AND purpose.code IN ('T') AND ts.country_of_origin_id IS NULL
          AND (source.name_en != 'Confiscations/seizures' OR ts.source_id IS NULL)
          GROUP BY year, reported_by_exporter
          HAVING SUM(quantity) > 0
    
        ) sub
      )
      ORDER BY ts.year, ts.taxon_concept_full_name, ts.exporter_id, ts.importer_id
    )
    
    UNION    

    (
      SELECT ts.id AS id,ts.year AS year,ts.appendix AS appendix,ts.taxon_concept_author_year AS author_year,ts.taxon_concept_name_status AS name_status,ts.taxon_concept_id,ts.taxon_concept_full_name AS taxon_name,ts.taxon_concept_phylum_id AS phylum_id,ts.taxon_concept_class_id AS class_id,ts.taxon_concept_class_name AS class_name,ts.taxon_concept_order_id AS order_id,ts.taxon_concept_order_name AS order_name,ts.taxon_concept_family_id AS family_id,ts.taxon_concept_family_name AS family_name,ts.taxon_concept_genus_id AS genus_id,ts.taxon_concept_genus_name AS genus_name,CASE WHEN ts.reported_by_exporter THEN ts.quantity ELSE NULL END AS exporter_reported_quantity,CASE WHEN ts.reported_by_exporter THEN NULL ELSE ts.quantity END AS importer_reported_quantity,unit.id AS unit_id,unit.name_en AS unit,importer.id AS importer_id,importer.iso_code2 AS importer_iso,importer.name_en AS importer,exporter.id AS exporter_id,exporter.iso_code2 AS exporter_iso,exporter.name_en AS exporter,NULL AS origin,purpose.id AS purpose_id,purpose.name_en AS purpose,source.id AS source_id,source.name_en AS source,term.id AS term_id,term.name_en AS term,ts.import_permits_ids AS import_permits,ts.export_permits_ids AS export_permits,ts.origin_permits_ids AS origin_permits,ts.import_permit_number AS import_permit,ts.export_permit_number AS export_permit,ts.origin_permit_number AS origin_permit,'Quota' AS issue_type,'Listing_annotations' AS details_of_compliance_issue,'12/06/2013' AS compliance_type_start_date,'Present' AS compliance_type_end_date,'Cuora yunnanensis' AS compliance_type_taxon,ts.taxon_concept_rank_id AS rank_id,'SPECIES' AS rank_name,'0' AS quota_quantity,'**II** [GENUS listing Cuora spp.] Zero quota for wild specimens for commercial purposes for Cuora aurocapitata, C. bourreti, C. flavomarginata, C. galbinifrons, C. mccordi, C. mouhotii, C. pani, C. picturata, C. trifasciata, C. yunnanensis and C. zhoui.' AS notes
      FROM trade_shipments_with_taxa_view ts
      
      INNER JOIN geo_entities AS exporter ON exporter.id = ts.exporter_id
      INNER JOIN geo_entities AS importer ON importer.id = ts.importer_id
      LEFT OUTER JOIN trade_codes source ON ts.source_id = source.id
      LEFT OUTER JOIN trade_codes purpose ON ts.purpose_id = purpose.id
      LEFT OUTER JOIN trade_codes unit ON ts.unit_id = unit.id
      LEFT OUTER JOIN trade_codes term ON ts.term_id = term.id
    
      WHERE ts.id IN (
        SELECT UNNEST(sub.ids)
        FROM (
          
          SELECT ARRAY_AGG(ts.id) AS ids
          FROM trade_shipments_with_taxa_view ts
          
          INNER JOIN geo_entities AS exporter ON exporter.id = ts.exporter_id
          LEFT OUTER JOIN trade_codes source ON ts.source_id = source.id
          LEFT OUTER JOIN trade_codes purpose ON ts.purpose_id = purpose.id
          LEFT OUTER JOIN trade_codes unit ON ts.unit_id = unit.id
          LEFT OUTER JOIN trade_codes term ON ts.term_id = term.id
    
          WHERE ts.year >= 2013 AND ts.year <= 2018 AND ts.taxon_concept_id = 5712 AND TRUE AND TRUE AND TRUE AND source.code IN ('W') AND purpose.code IN ('T') AND ts.country_of_origin_id IS NULL
          AND (source.name_en != 'Confiscations/seizures' OR ts.source_id IS NULL)
          GROUP BY year, reported_by_exporter
          HAVING SUM(quantity) > 0
    
        ) sub
      )
      ORDER BY ts.year, ts.taxon_concept_full_name, ts.exporter_id, ts.importer_id
    )
    
    UNION    

    (
      SELECT ts.id AS id,ts.year AS year,ts.appendix AS appendix,ts.taxon_concept_author_year AS author_year,ts.taxon_concept_name_status AS name_status,ts.taxon_concept_id,ts.taxon_concept_full_name AS taxon_name,ts.taxon_concept_phylum_id AS phylum_id,ts.taxon_concept_class_id AS class_id,ts.taxon_concept_class_name AS class_name,ts.taxon_concept_order_id AS order_id,ts.taxon_concept_order_name AS order_name,ts.taxon_concept_family_id AS family_id,ts.taxon_concept_family_name AS family_name,ts.taxon_concept_genus_id AS genus_id,ts.taxon_concept_genus_name AS genus_name,CASE WHEN ts.reported_by_exporter THEN ts.quantity ELSE NULL END AS exporter_reported_quantity,CASE WHEN ts.reported_by_exporter THEN NULL ELSE ts.quantity END AS importer_reported_quantity,unit.id AS unit_id,unit.name_en AS unit,importer.id AS importer_id,importer.iso_code2 AS importer_iso,importer.name_en AS importer,exporter.id AS exporter_id,exporter.iso_code2 AS exporter_iso,exporter.name_en AS exporter,NULL AS origin,purpose.id AS purpose_id,purpose.name_en AS purpose,source.id AS source_id,source.name_en AS source,term.id AS term_id,term.name_en AS term,ts.import_permits_ids AS import_permits,ts.export_permits_ids AS export_permits,ts.origin_permits_ids AS origin_permits,ts.import_permit_number AS import_permit,ts.export_permit_number AS export_permit,ts.origin_permit_number AS origin_permit,'Quota' AS issue_type,'Listing_annotations' AS details_of_compliance_issue,'12/06/2013' AS compliance_type_start_date,'Present' AS compliance_type_end_date,'Cuora zhoui' AS compliance_type_taxon,ts.taxon_concept_rank_id AS rank_id,'SPECIES' AS rank_name,'0' AS quota_quantity,'**II** [GENUS listing Cuora spp.] Zero quota for wild specimens for commercial purposes for Cuora aurocapitata, C. bourreti, C. flavomarginata, C. galbinifrons, C. mccordi, C. mouhotii, C. pani, C. picturata, C. trifasciata, C. yunnanensis and C. zhoui.' AS notes
      FROM trade_shipments_with_taxa_view ts
      
      INNER JOIN geo_entities AS exporter ON exporter.id = ts.exporter_id
      INNER JOIN geo_entities AS importer ON importer.id = ts.importer_id
      LEFT OUTER JOIN trade_codes source ON ts.source_id = source.id
      LEFT OUTER JOIN trade_codes purpose ON ts.purpose_id = purpose.id
      LEFT OUTER JOIN trade_codes unit ON ts.unit_id = unit.id
      LEFT OUTER JOIN trade_codes term ON ts.term_id = term.id
    
      WHERE ts.id IN (
        SELECT UNNEST(sub.ids)
        FROM (
          
          SELECT ARRAY_AGG(ts.id) AS ids
          FROM trade_shipments_with_taxa_view ts
          
          INNER JOIN geo_entities AS exporter ON exporter.id = ts.exporter_id
          LEFT OUTER JOIN trade_codes source ON ts.source_id = source.id
          LEFT OUTER JOIN trade_codes purpose ON ts.purpose_id = purpose.id
          LEFT OUTER JOIN trade_codes unit ON ts.unit_id = unit.id
          LEFT OUTER JOIN trade_codes term ON ts.term_id = term.id
    
          WHERE ts.year >= 2013 AND ts.year <= 2018 AND ts.taxon_concept_id = 5930 AND TRUE AND TRUE AND TRUE AND source.code IN ('W') AND purpose.code IN ('T') AND ts.country_of_origin_id IS NULL
          AND (source.name_en != 'Confiscations/seizures' OR ts.source_id IS NULL)
          GROUP BY year, reported_by_exporter
          HAVING SUM(quantity) > 0
    
        ) sub
      )
      ORDER BY ts.year, ts.taxon_concept_full_name, ts.exporter_id, ts.importer_id
    )
    
    UNION    

    (
      SELECT ts.id AS id,ts.year AS year,ts.appendix AS appendix,ts.taxon_concept_author_year AS author_year,ts.taxon_concept_name_status AS name_status,ts.taxon_concept_id,ts.taxon_concept_full_name AS taxon_name,ts.taxon_concept_phylum_id AS phylum_id,ts.taxon_concept_class_id AS class_id,ts.taxon_concept_class_name AS class_name,ts.taxon_concept_order_id AS order_id,ts.taxon_concept_order_name AS order_name,ts.taxon_concept_family_id AS family_id,ts.taxon_concept_family_name AS family_name,ts.taxon_concept_genus_id AS genus_id,ts.taxon_concept_genus_name AS genus_name,CASE WHEN ts.reported_by_exporter THEN ts.quantity ELSE NULL END AS exporter_reported_quantity,CASE WHEN ts.reported_by_exporter THEN NULL ELSE ts.quantity END AS importer_reported_quantity,unit.id AS unit_id,unit.name_en AS unit,importer.id AS importer_id,importer.iso_code2 AS importer_iso,importer.name_en AS importer,exporter.id AS exporter_id,exporter.iso_code2 AS exporter_iso,exporter.name_en AS exporter,NULL AS origin,purpose.id AS purpose_id,purpose.name_en AS purpose,source.id AS source_id,source.name_en AS source,term.id AS term_id,term.name_en AS term,ts.import_permits_ids AS import_permits,ts.export_permits_ids AS export_permits,ts.origin_permits_ids AS origin_permits,ts.import_permit_number AS import_permit,ts.export_permit_number AS export_permit,ts.origin_permit_number AS origin_permit,'Quota' AS issue_type,'Listing_annotations' AS details_of_compliance_issue,'12/06/2013' AS compliance_type_start_date,'Present' AS compliance_type_end_date,'Heosemys annandalii' AS compliance_type_taxon,ts.taxon_concept_rank_id AS rank_id,'SPECIES' AS rank_name,'0' AS quota_quantity,'**II** Zero quota for wild specimens for commercial purposes.' AS notes
      FROM trade_shipments_with_taxa_view ts
      
      INNER JOIN geo_entities AS exporter ON exporter.id = ts.exporter_id
      INNER JOIN geo_entities AS importer ON importer.id = ts.importer_id
      LEFT OUTER JOIN trade_codes source ON ts.source_id = source.id
      LEFT OUTER JOIN trade_codes purpose ON ts.purpose_id = purpose.id
      LEFT OUTER JOIN trade_codes unit ON ts.unit_id = unit.id
      LEFT OUTER JOIN trade_codes term ON ts.term_id = term.id
    
      WHERE ts.id IN (
        SELECT UNNEST(sub.ids)
        FROM (
          
          SELECT ARRAY_AGG(ts.id) AS ids
          FROM trade_shipments_with_taxa_view ts
          
          INNER JOIN geo_entities AS exporter ON exporter.id = ts.exporter_id
          LEFT OUTER JOIN trade_codes source ON ts.source_id = source.id
          LEFT OUTER JOIN trade_codes purpose ON ts.purpose_id = purpose.id
          LEFT OUTER JOIN trade_codes unit ON ts.unit_id = unit.id
          LEFT OUTER JOIN trade_codes term ON ts.term_id = term.id
    
          WHERE ts.year >= 2013 AND ts.year <= 2018 AND ts.taxon_concept_id = 7457 AND TRUE AND TRUE AND TRUE AND source.code IN ('W') AND purpose.code IN ('T') AND ts.country_of_origin_id IS NULL
          AND (source.name_en != 'Confiscations/seizures' OR ts.source_id IS NULL)
          GROUP BY year, reported_by_exporter
          HAVING SUM(quantity) > 0
    
        ) sub
      )
      ORDER BY ts.year, ts.taxon_concept_full_name, ts.exporter_id, ts.importer_id
    )
    
    UNION    

    (
      SELECT ts.id AS id,ts.year AS year,ts.appendix AS appendix,ts.taxon_concept_author_year AS author_year,ts.taxon_concept_name_status AS name_status,ts.taxon_concept_id,ts.taxon_concept_full_name AS taxon_name,ts.taxon_concept_phylum_id AS phylum_id,ts.taxon_concept_class_id AS class_id,ts.taxon_concept_class_name AS class_name,ts.taxon_concept_order_id AS order_id,ts.taxon_concept_order_name AS order_name,ts.taxon_concept_family_id AS family_id,ts.taxon_concept_family_name AS family_name,ts.taxon_concept_genus_id AS genus_id,ts.taxon_concept_genus_name AS genus_name,CASE WHEN ts.reported_by_exporter THEN ts.quantity ELSE NULL END AS exporter_reported_quantity,CASE WHEN ts.reported_by_exporter THEN NULL ELSE ts.quantity END AS importer_reported_quantity,unit.id AS unit_id,unit.name_en AS unit,importer.id AS importer_id,importer.iso_code2 AS importer_iso,importer.name_en AS importer,exporter.id AS exporter_id,exporter.iso_code2 AS exporter_iso,exporter.name_en AS exporter,NULL AS origin,purpose.id AS purpose_id,purpose.name_en AS purpose,source.id AS source_id,source.name_en AS source,term.id AS term_id,term.name_en AS term,ts.import_permits_ids AS import_permits,ts.export_permits_ids AS export_permits,ts.origin_permits_ids AS origin_permits,ts.import_permit_number AS import_permit,ts.export_permit_number AS export_permit,ts.origin_permit_number AS origin_permit,'Quota' AS issue_type,'Listing_annotations' AS details_of_compliance_issue,'12/06/2013' AS compliance_type_start_date,'Present' AS compliance_type_end_date,'Heosemys depressa' AS compliance_type_taxon,ts.taxon_concept_rank_id AS rank_id,'SPECIES' AS rank_name,'0' AS quota_quantity,'**II** Zero quota for wild specimens for commercial purposes.' AS notes
      FROM trade_shipments_with_taxa_view ts
      
      INNER JOIN geo_entities AS exporter ON exporter.id = ts.exporter_id
      INNER JOIN geo_entities AS importer ON importer.id = ts.importer_id
      LEFT OUTER JOIN trade_codes source ON ts.source_id = source.id
      LEFT OUTER JOIN trade_codes purpose ON ts.purpose_id = purpose.id
      LEFT OUTER JOIN trade_codes unit ON ts.unit_id = unit.id
      LEFT OUTER JOIN trade_codes term ON ts.term_id = term.id
    
      WHERE ts.id IN (
        SELECT UNNEST(sub.ids)
        FROM (
          
          SELECT ARRAY_AGG(ts.id) AS ids
          FROM trade_shipments_with_taxa_view ts
          
          INNER JOIN geo_entities AS exporter ON exporter.id = ts.exporter_id
          LEFT OUTER JOIN trade_codes source ON ts.source_id = source.id
          LEFT OUTER JOIN trade_codes purpose ON ts.purpose_id = purpose.id
          LEFT OUTER JOIN trade_codes unit ON ts.unit_id = unit.id
          LEFT OUTER JOIN trade_codes term ON ts.term_id = term.id
    
          WHERE ts.year >= 2013 AND ts.year <= 2018 AND ts.taxon_concept_id = 4484 AND TRUE AND TRUE AND TRUE AND source.code IN ('W') AND purpose.code IN ('T') AND ts.country_of_origin_id IS NULL
          AND (source.name_en != 'Confiscations/seizures' OR ts.source_id IS NULL)
          GROUP BY year, reported_by_exporter
          HAVING SUM(quantity) > 0
    
        ) sub
      )
      ORDER BY ts.year, ts.taxon_concept_full_name, ts.exporter_id, ts.importer_id
    )
    
    UNION    

    (
      SELECT ts.id AS id,ts.year AS year,ts.appendix AS appendix,ts.taxon_concept_author_year AS author_year,ts.taxon_concept_name_status AS name_status,ts.taxon_concept_id,ts.taxon_concept_full_name AS taxon_name,ts.taxon_concept_phylum_id AS phylum_id,ts.taxon_concept_class_id AS class_id,ts.taxon_concept_class_name AS class_name,ts.taxon_concept_order_id AS order_id,ts.taxon_concept_order_name AS order_name,ts.taxon_concept_family_id AS family_id,ts.taxon_concept_family_name AS family_name,ts.taxon_concept_genus_id AS genus_id,ts.taxon_concept_genus_name AS genus_name,CASE WHEN ts.reported_by_exporter THEN ts.quantity ELSE NULL END AS exporter_reported_quantity,CASE WHEN ts.reported_by_exporter THEN NULL ELSE ts.quantity END AS importer_reported_quantity,unit.id AS unit_id,unit.name_en AS unit,importer.id AS importer_id,importer.iso_code2 AS importer_iso,importer.name_en AS importer,exporter.id AS exporter_id,exporter.iso_code2 AS exporter_iso,exporter.name_en AS exporter,NULL AS origin,purpose.id AS purpose_id,purpose.name_en AS purpose,source.id AS source_id,source.name_en AS source,term.id AS term_id,term.name_en AS term,ts.import_permits_ids AS import_permits,ts.export_permits_ids AS export_permits,ts.origin_permits_ids AS origin_permits,ts.import_permit_number AS import_permit,ts.export_permit_number AS export_permit,ts.origin_permit_number AS origin_permit,'Quota' AS issue_type,'Listing_annotations' AS details_of_compliance_issue,'12/06/2013' AS compliance_type_start_date,'Present' AS compliance_type_end_date,'Mauremys annamensis' AS compliance_type_taxon,ts.taxon_concept_rank_id AS rank_id,'SPECIES' AS rank_name,'0' AS quota_quantity,'**II** Zero quota for wild specimens for commercial purposes.' AS notes
      FROM trade_shipments_with_taxa_view ts
      
      INNER JOIN geo_entities AS exporter ON exporter.id = ts.exporter_id
      INNER JOIN geo_entities AS importer ON importer.id = ts.importer_id
      LEFT OUTER JOIN trade_codes source ON ts.source_id = source.id
      LEFT OUTER JOIN trade_codes purpose ON ts.purpose_id = purpose.id
      LEFT OUTER JOIN trade_codes unit ON ts.unit_id = unit.id
      LEFT OUTER JOIN trade_codes term ON ts.term_id = term.id
    
      WHERE ts.id IN (
        SELECT UNNEST(sub.ids)
        FROM (
          
          SELECT ARRAY_AGG(ts.id) AS ids
          FROM trade_shipments_with_taxa_view ts
          
          INNER JOIN geo_entities AS exporter ON exporter.id = ts.exporter_id
          LEFT OUTER JOIN trade_codes source ON ts.source_id = source.id
          LEFT OUTER JOIN trade_codes purpose ON ts.purpose_id = purpose.id
          LEFT OUTER JOIN trade_codes unit ON ts.unit_id = unit.id
          LEFT OUTER JOIN trade_codes term ON ts.term_id = term.id
    
          WHERE ts.year >= 2013 AND ts.year <= 2018 AND ts.taxon_concept_id = 3838 AND TRUE AND TRUE AND TRUE AND source.code IN ('W') AND purpose.code IN ('T') AND ts.country_of_origin_id IS NULL
          AND (source.name_en != 'Confiscations/seizures' OR ts.source_id IS NULL)
          GROUP BY year, reported_by_exporter
          HAVING SUM(quantity) > 0
    
        ) sub
      )
      ORDER BY ts.year, ts.taxon_concept_full_name, ts.exporter_id, ts.importer_id
    )
    
    UNION    

    (
      SELECT ts.id AS id,ts.year AS year,ts.appendix AS appendix,ts.taxon_concept_author_year AS author_year,ts.taxon_concept_name_status AS name_status,ts.taxon_concept_id,ts.taxon_concept_full_name AS taxon_name,ts.taxon_concept_phylum_id AS phylum_id,ts.taxon_concept_class_id AS class_id,ts.taxon_concept_class_name AS class_name,ts.taxon_concept_order_id AS order_id,ts.taxon_concept_order_name AS order_name,ts.taxon_concept_family_id AS family_id,ts.taxon_concept_family_name AS family_name,ts.taxon_concept_genus_id AS genus_id,ts.taxon_concept_genus_name AS genus_name,CASE WHEN ts.reported_by_exporter THEN ts.quantity ELSE NULL END AS exporter_reported_quantity,CASE WHEN ts.reported_by_exporter THEN NULL ELSE ts.quantity END AS importer_reported_quantity,unit.id AS unit_id,unit.name_en AS unit,importer.id AS importer_id,importer.iso_code2 AS importer_iso,importer.name_en AS importer,exporter.id AS exporter_id,exporter.iso_code2 AS exporter_iso,exporter.name_en AS exporter,NULL AS origin,purpose.id AS purpose_id,purpose.name_en AS purpose,source.id AS source_id,source.name_en AS source,term.id AS term_id,term.name_en AS term,ts.import_permits_ids AS import_permits,ts.export_permits_ids AS export_permits,ts.origin_permits_ids AS origin_permits,ts.import_permit_number AS import_permit,ts.export_permit_number AS export_permit,ts.origin_permit_number AS origin_permit,'Quota' AS issue_type,'Listing_annotations' AS details_of_compliance_issue,'12/06/2013' AS compliance_type_start_date,'Present' AS compliance_type_end_date,'Orlitia borneensis' AS compliance_type_taxon,ts.taxon_concept_rank_id AS rank_id,'SPECIES' AS rank_name,'0' AS quota_quantity,'**II** Zero quota for wild specimens for commercial purposes.' AS notes
      FROM trade_shipments_with_taxa_view ts
      
      INNER JOIN geo_entities AS exporter ON exporter.id = ts.exporter_id
      INNER JOIN geo_entities AS importer ON importer.id = ts.importer_id
      LEFT OUTER JOIN trade_codes source ON ts.source_id = source.id
      LEFT OUTER JOIN trade_codes purpose ON ts.purpose_id = purpose.id
      LEFT OUTER JOIN trade_codes unit ON ts.unit_id = unit.id
      LEFT OUTER JOIN trade_codes term ON ts.term_id = term.id
    
      WHERE ts.id IN (
        SELECT UNNEST(sub.ids)
        FROM (
          
          SELECT ARRAY_AGG(ts.id) AS ids
          FROM trade_shipments_with_taxa_view ts
          
          INNER JOIN geo_entities AS exporter ON exporter.id = ts.exporter_id
          LEFT OUTER JOIN trade_codes source ON ts.source_id = source.id
          LEFT OUTER JOIN trade_codes purpose ON ts.purpose_id = purpose.id
          LEFT OUTER JOIN trade_codes unit ON ts.unit_id = unit.id
          LEFT OUTER JOIN trade_codes term ON ts.term_id = term.id
    
          WHERE ts.year >= 2013 AND ts.year <= 2018 AND ts.taxon_concept_id = 3413 AND TRUE AND TRUE AND TRUE AND source.code IN ('W') AND purpose.code IN ('T') AND ts.country_of_origin_id IS NULL
          AND (source.name_en != 'Confiscations/seizures' OR ts.source_id IS NULL)
          GROUP BY year, reported_by_exporter
          HAVING SUM(quantity) > 0
    
        ) sub
      )
      ORDER BY ts.year, ts.taxon_concept_full_name, ts.exporter_id, ts.importer_id
    )
    
    UNION    

    (
      SELECT ts.id AS id,ts.year AS year,ts.appendix AS appendix,ts.taxon_concept_author_year AS author_year,ts.taxon_concept_name_status AS name_status,ts.taxon_concept_id,ts.taxon_concept_full_name AS taxon_name,ts.taxon_concept_phylum_id AS phylum_id,ts.taxon_concept_class_id AS class_id,ts.taxon_concept_class_name AS class_name,ts.taxon_concept_order_id AS order_id,ts.taxon_concept_order_name AS order_name,ts.taxon_concept_family_id AS family_id,ts.taxon_concept_family_name AS family_name,ts.taxon_concept_genus_id AS genus_id,ts.taxon_concept_genus_name AS genus_name,CASE WHEN ts.reported_by_exporter THEN ts.quantity ELSE NULL END AS exporter_reported_quantity,CASE WHEN ts.reported_by_exporter THEN NULL ELSE ts.quantity END AS importer_reported_quantity,unit.id AS unit_id,unit.name_en AS unit,importer.id AS importer_id,importer.iso_code2 AS importer_iso,importer.name_en AS importer,exporter.id AS exporter_id,exporter.iso_code2 AS exporter_iso,exporter.name_en AS exporter,NULL AS origin,purpose.id AS purpose_id,purpose.name_en AS purpose,source.id AS source_id,source.name_en AS source,term.id AS term_id,term.name_en AS term,ts.import_permits_ids AS import_permits,ts.export_permits_ids AS export_permits,ts.origin_permits_ids AS origin_permits,ts.import_permit_number AS import_permit,ts.export_permit_number AS export_permit,ts.origin_permit_number AS origin_permit,'Quota' AS issue_type,'Listing_annotations' AS details_of_compliance_issue,'19/07/2000' AS compliance_type_start_date,'Present' AS compliance_type_end_date,'Centrochelys sulcata' AS compliance_type_taxon,ts.taxon_concept_rank_id AS rank_id,'SPECIES' AS rank_name,'0' AS quota_quantity,'**II** [FAMILY listing Testudinidae spp.] Included in Appendix II, except for the species included in Appendix I. A zero annual export quota has been established for Centrochelys sulcata for specimens removed from the wild and traded for primarily commercial purposes.' AS notes
      FROM trade_shipments_with_taxa_view ts
      
      INNER JOIN geo_entities AS exporter ON exporter.id = ts.exporter_id
      INNER JOIN geo_entities AS importer ON importer.id = ts.importer_id
      LEFT OUTER JOIN trade_codes source ON ts.source_id = source.id
      LEFT OUTER JOIN trade_codes purpose ON ts.purpose_id = purpose.id
      LEFT OUTER JOIN trade_codes unit ON ts.unit_id = unit.id
      LEFT OUTER JOIN trade_codes term ON ts.term_id = term.id
    
      WHERE ts.id IN (
        SELECT UNNEST(sub.ids)
        FROM (
          
          SELECT ARRAY_AGG(ts.id) AS ids
          FROM trade_shipments_with_taxa_view ts
          
          INNER JOIN geo_entities AS exporter ON exporter.id = ts.exporter_id
          LEFT OUTER JOIN trade_codes source ON ts.source_id = source.id
          LEFT OUTER JOIN trade_codes purpose ON ts.purpose_id = purpose.id
          LEFT OUTER JOIN trade_codes unit ON ts.unit_id = unit.id
          LEFT OUTER JOIN trade_codes term ON ts.term_id = term.id
    
          WHERE ts.year >= 2000 AND ts.year <= 2018 AND ts.taxon_concept_id = 31025 AND TRUE AND TRUE AND TRUE AND source.code IN ('W') AND purpose.code IN ('T') AND ts.country_of_origin_id IS NULL
          AND (source.name_en != 'Confiscations/seizures' OR ts.source_id IS NULL)
          GROUP BY year, reported_by_exporter
          HAVING SUM(quantity) > 0
    
        ) sub
      )
      ORDER BY ts.year, ts.taxon_concept_full_name, ts.exporter_id, ts.importer_id
    )
    