SELECT ts.id, ts.year, ts.appendix, ts.reported_by_exporter,
       ts.taxon_concept_id AS taxon_id,
       ts.taxon_concept_author_year AS author_year,
       ts.taxon_concept_name_status AS name_status,
       ts.taxon_concept_full_name AS taxon_name,
       ts.taxon_concept_kingdom_name AS kingdom_name,
       ts.taxon_concept_kingdom_id AS kingdom_id,
       ts.taxon_concept_phylum_name AS phylum_name,
       ts.taxon_concept_phylum_id AS phylum_id,
       ts.taxon_concept_class_id AS class_id,
       ts.taxon_concept_class_name AS class_name,
       ts.taxon_concept_order_id AS order_id,
       ts.taxon_concept_order_name AS order_name,
       ts.taxon_concept_family_id AS family_id,
       ts.taxon_concept_family_name AS family_name,
       ts.taxon_concept_genus_id AS genus_id,
       ts.taxon_concept_genus_name AS genus_name,
       ts.group AS group_name,
       CASE 									WHEN term_id IN (73) AND ts.taxon_concept_genus_name IN ('Galanthus','Cyclamen','Sternbergia')
        THEN
          Array[57, (ts.quantity), unit_id]
        WHEN term_id IN (56) AND unit_id IN (143)
        THEN
          Array[59, (ts.quantity), unit_id]
        WHEN term_id IN (78) AND ts.taxon_concept_order_name IN ('Testudines')
        THEN
          Array[10, (ts.quantity), unit_id]
        WHEN term_id IN (19,70) AND ts.taxon_concept_genus_name IN ('Aloe','Euphorbia')
        THEN
          Array[24, (ts.quantity), unit_id]
        WHEN term_id IN (22) AND ts.taxon_concept_order_name IN ('Acipenseriformes')
        THEN
          Array[12, (ts.quantity), unit_id]
        WHEN term_id IN (19) AND ts.taxon_concept_order_name IN ('Acipenseriformes')
        THEN
          Array[24, (ts.quantity), unit_id]
        WHEN term_id IN (3,51,101,64,40,52,102)
        THEN
          Array[54, (ts.quantity), unit_id]
        WHEN term_id IN (88,13)
        THEN
          Array[11, (ts.quantity), unit_id]
        WHEN term_id IN (7)
        THEN
          Array[5, (ts.quantity), unit_id]
        WHEN term_id IN (45)
        THEN
          Array[43, (ts.quantity), unit_id]
        WHEN term_id IN (50)
        THEN
          Array[49, (ts.quantity), unit_id]
        WHEN term_id IN (71)
        THEN
          Array[25, (ts.quantity), unit_id]
        WHEN term_id IN (76)
        THEN
          Array[19, (ts.quantity), unit_id]
        WHEN term_id IN (83)
        THEN
          Array[82, (ts.quantity), unit_id]
        WHEN term_id IN (94)
        THEN
          Array[177, (ts.quantity), unit_id]
        WHEN term_id IN (95)
        THEN
          Array[93, (ts.quantity), unit_id]
        WHEN term_id IN (96)
        THEN
          Array[18, (ts.quantity), unit_id]
        WHEN term_id IN (100)
        THEN
          Array[24, (ts.quantity), unit_id]
        WHEN term_id IN (41)
        THEN
          Array[85, (ts.quantity), unit_id]
        WHEN term_id IN (47) AND ts.group IN ('Timber')
        THEN
          Array[177, (ts.quantity), unit_id]
        WHEN term_id IN (47)
        THEN
          Array[11, (ts.quantity), unit_id]
        WHEN term_id IN (66)
        THEN
          Array[172, (ts.quantity*52), unit_id]
        WHEN term_id IN (79,80)
        THEN
          Array[84, (ts.quantity/2), unit_id]
        WHEN unit_id IN (150)
        THEN
          Array[term_id, (ts.quantity*2), NULL]
        WHEN unit_id IN (133,125,127,128,130,131,138,151,142,153,154,156)
        THEN
          Array[term_id, (ts.quantity), NULL]
        WHEN unit_id IN (148)
        THEN
          Array[term_id, (ts.quantity/10e+9), 143]
        WHEN unit_id IN (145)
        THEN
          Array[term_id, (ts.quantity/10e+6), 143]
        WHEN unit_id IN (139)
        THEN
          Array[term_id, (ts.quantity/1000), 143]
        WHEN unit_id IN (161)
        THEN
          Array[term_id, (ts.quantity*1000), 143]
        WHEN unit_id IN (146)
        THEN
          Array[term_id, (ts.quantity/1000), 144]
        WHEN unit_id IN (134)
        THEN
          Array[term_id, (ts.quantity/100), 147]
        WHEN unit_id IN (157)
        THEN
          Array[term_id, (ts.quantity/10e+4), 160]
        WHEN unit_id IN (158)
        THEN
          Array[term_id, (ts.quantity/100), 160]
        WHEN unit_id IN (132)
        THEN
          Array[term_id, (ts.quantity/10e+6), 136]
        WHEN unit_id IN (149)
        THEN
          Array[term_id, (ts.quantity/35.274), 143]
        WHEN unit_id IN (152)
        THEN
          Array[term_id, (ts.quantity/2.205), 143]
        WHEN unit_id IN (141)
        THEN
          Array[term_id, (ts.quantity/39.37), 147]
        WHEN unit_id IN (137)
        THEN
          Array[term_id, (ts.quantity/3.281), 147]
        WHEN unit_id IN (163)
        THEN
          Array[term_id, (ts.quantity/1.094), 143]
        WHEN unit_id IN (159)
        THEN
          Array[term_id, (ts.quantity/10.764), 160]
        WHEN unit_id IN (135)
        THEN
          Array[term_id, (ts.quantity/35.315), 136]
        WHEN unit_id IN (143) AND ts.group IN ('Coral') AND term_id IN (57)
        THEN
          Array[term_id, (ts.quantity/0.206), NULL]
        WHEN unit_id IS NULL AND ts.group IN ('Coral') AND term_id IN (72)
        THEN
          Array[term_id, (ts.quantity*0.58), 143]
        WHEN unit_id IN (143) AND term_id IN (58,93,74) AND ts.taxon_concept_full_name IN ('Pericopsis elata')
        THEN
          Array[term_id, (ts.quantity/725), 136]
        WHEN unit_id IN (143) AND term_id IN (58,93,74) AND ts.taxon_concept_full_name IN ('Cedrela odorata')
        THEN
          Array[term_id, (ts.quantity/440), 136]
        WHEN unit_id IN (143) AND term_id IN (58,93,74) AND ts.taxon_concept_full_name IN ('Guaiacum sanctum','Guaiacum officinale')
        THEN
          Array[term_id, (ts.quantity/1230), 136]
        WHEN unit_id IN (143) AND term_id IN (58,93,74) AND ts.taxon_concept_full_name IN ('Swietenia macrophylla')
        THEN
          Array[term_id, (ts.quantity/730), 136]
        WHEN unit_id IN (143) AND term_id IN (58,93,74) AND ts.taxon_concept_full_name IN ('Swietenia humilis')
        THEN
          Array[term_id, (ts.quantity/610), 136]
        WHEN unit_id IN (143) AND term_id IN (58,93,74) AND ts.taxon_concept_full_name IN ('Swietenia mahagoni')
        THEN
          Array[term_id, (ts.quantity/750), 136]
        WHEN unit_id IN (143) AND term_id IN (58,93,74) AND ts.taxon_concept_full_name IN ('Araucaria araucana')
        THEN
          Array[term_id, (ts.quantity/570), 136]
        WHEN unit_id IN (143) AND term_id IN (58,93,74) AND ts.taxon_concept_full_name IN ('Fitzroya cupressoides')
        THEN
          Array[term_id, (ts.quantity/480), 136]
        WHEN unit_id IN (143) AND term_id IN (58,93,74) AND ts.taxon_concept_full_name IN ('Dalbergia nigra')
        THEN
          Array[term_id, (ts.quantity/970), 136]
        WHEN unit_id IN (143) AND term_id IN (58,93,74) AND ts.taxon_concept_full_name IN ('Abies guatemalensis')
        THEN
          Array[term_id, (ts.quantity/350), 136]
        WHEN unit_id IN (143) AND term_id IN (58,93,74) AND ts.taxon_concept_full_name IN ('Prunus africana')
        THEN
          Array[term_id, (ts.quantity/740), 136]
        WHEN unit_id IN (143) AND term_id IN (58,93,74) AND ts.taxon_concept_genus_name IN ('Gonystylus spp.','Gonystylus')
        THEN
          Array[term_id, (ts.quantity/660), 136]
        WHEN unit_id IN (129,140)
        THEN
          Array[80, (ts.quantity), NULL]
        WHEN unit_id IN (126)
        THEN
          Array[82, (ts.quantity), NULL]
        WHEN unit_id IN (155)
        THEN
          Array[84, (ts.quantity/2), NULL]
        ELSE										Array[term_id, ts.quantity, unit_id]

        END AS term_quantity_unit,
       exporters.id AS exporter_id,
       exporters.iso_code2 AS exporter_iso,
       exporters.name_en AS exporter,
       importers.id AS importer_id,
       importers.iso_code2 AS importer_iso,
       importers.name_en AS importer,
       origins.id AS origin_id,
       origins.iso_code2 AS origin_iso,
       origins.name_en AS origin,
       purposes.id AS purpose_id,
       purposes.name_en AS purpose,
       sources.id AS source_id,
       sources.name_en AS source,
       ranks.id AS rank_id,
       ranks.name AS rank_name
FROM trade_plus_group_view ts
LEFT OUTER JOIN trade_codes sources ON ts.source_id = sources.id
LEFT OUTER JOIN trade_codes purposes ON ts.purpose_id = purposes.id
INNER JOIN ranks ON ranks.id = ts.taxon_concept_rank_id
LEFT OUTER JOIN geo_entities exporters ON ts.exporter_id = exporters.id
LEFT OUTER JOIN geo_entities importers ON ts.importer_id = importers.id
LEFT OUTER JOIN geo_entities origins ON ts.country_of_origin_id = origins.id
WHERE  term_id NOT IN (17,63,67)
