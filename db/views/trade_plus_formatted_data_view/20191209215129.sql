            WITH codes_map(term_id,term_code,term_name,unit_id,unit_code,unit_name,output_term_id,output_term_code,output_term_name,output_unit_id,output_unit_code,output_unit_name,taxa_field,term_quantity_modifier,term_modifier_value,unit_quantity_modifier,unit_modifier_value) AS (
        VALUES (73,'ROO','roots',NULL,NULL,NULL,57,'LIV','live',NULL,NULL,NULL,'{"genus":["Galanthus", "Cyclamen", "Sternbergia"]}'::JSON,NULL,NULL,NULL,0),(56,'LEG','frog legs',143,'KIL','kg',59,'MEA','meat',NULL,NULL,NULL,NULL,NULL,NULL,NULL,0),(78,'SHE','shells',NULL,NULL,NULL,10,'CAP','carapaces',NULL,NULL,NULL,'{"order":["Testudines"]}'::JSON,NULL,NULL,NULL,0),(19,'DER','derivatives',NULL,NULL,NULL,24,'EXT','extract',NULL,NULL,NULL,'{"genus":["Aloe", "Euphorbia"]}'::JSON,NULL,NULL,NULL,0),(70,'POW','powder',NULL,NULL,NULL,24,'EXT','extract',NULL,NULL,NULL,'{"genus":["Aloe", "Euphorbia"]}'::JSON,NULL,NULL,NULL,0),(22,'EGG','eggs',NULL,NULL,NULL,12,'CAV','caviar',NULL,NULL,NULL,'{"order":["Acipenseriformes"]}'::JSON,NULL,NULL,NULL,0),(19,'DER','derivatives',NULL,NULL,NULL,24,'EXT','extract',NULL,NULL,NULL,'{"order":["Acipenseriformes"]}'::JSON,NULL,NULL,NULL,0),(3,'BEL','belts',NULL,NULL,NULL,54,'LPS','leather products (small)',NULL,NULL,NULL,NULL,NULL,NULL,NULL,0),(40,'HAN','handbags',NULL,NULL,NULL,54,'LPS','leather products (small)',NULL,NULL,NULL,NULL,NULL,NULL,NULL,0),(51,'LEA','leather',NULL,NULL,NULL,54,'LPS','leather products (small)',NULL,NULL,NULL,NULL,NULL,NULL,NULL,0),(64,'SHO','shoes',NULL,NULL,NULL,54,'LPS','leather products (small)',NULL,NULL,NULL,NULL,NULL,NULL,NULL,0),(52,'SKO','leather items',NULL,NULL,NULL,54,'LPS','leather products (small)',NULL,NULL,NULL,NULL,NULL,NULL,NULL,0),(101,'WAL','wallets',NULL,NULL,NULL,54,'LPS','leather products (small)',NULL,NULL,NULL,NULL,NULL,NULL,NULL,0),(102,'WAT','watchstraps',NULL,NULL,NULL,54,'LPS','leather products (small)',NULL,NULL,NULL,NULL,NULL,NULL,NULL,0),(13,'CST','chess sets',NULL,NULL,NULL,11,'CAR','carvings',NULL,NULL,NULL,NULL,NULL,NULL,NULL,0),(88,'FRA','spectacle frames',NULL,NULL,NULL,11,'CAR','carvings',NULL,NULL,NULL,NULL,NULL,NULL,NULL,0),(7,'BPR','bone products',NULL,NULL,NULL,5,'BOC','bone carvings',NULL,NULL,NULL,NULL,NULL,NULL,NULL,0),(45,'HOS','horn scraps',NULL,NULL,NULL,43,'HOP','horn pieces',NULL,NULL,NULL,NULL,NULL,NULL,NULL,0),(50,'IVS','ivory scraps',NULL,NULL,NULL,49,'IVP','ivory pieces',NULL,NULL,NULL,NULL,NULL,NULL,NULL,0),(71,'QUI','quills',NULL,NULL,NULL,25,'FEA','feathers',NULL,NULL,NULL,NULL,NULL,NULL,NULL,0),(76,'SCR','scraps',NULL,NULL,NULL,19,'DER','derivatives',NULL,NULL,NULL,NULL,NULL,NULL,NULL,0),(83,'SKS','skin scraps',NULL,NULL,NULL,82,'SKP','skin pieces',NULL,NULL,NULL,NULL,NULL,NULL,NULL,0),(94,'TIC','timber carvings',NULL,NULL,NULL,177,'WPR','wood product',NULL,NULL,NULL,NULL,NULL,NULL,NULL,0),(95,'TIP','timber pieces',NULL,NULL,NULL,93,'TIM','timber',NULL,NULL,NULL,NULL,NULL,NULL,NULL,0),(96,'TIS','tissue cultures',NULL,NULL,NULL,18,'CUL','cultures',NULL,NULL,NULL,NULL,NULL,NULL,NULL,0),(100,'VNM','venom',NULL,NULL,NULL,24,'EXT','extract',NULL,NULL,NULL,NULL,NULL,NULL,NULL,0),(41,'HEA','heads',NULL,NULL,NULL,85,'SKU','skulls',NULL,NULL,NULL,NULL,NULL,NULL,NULL,0),(47,'FRN','furniture',NULL,NULL,NULL,177,'WPR','wood product',NULL,NULL,NULL,NULL,NULL,NULL,NULL,0),(47,'FRN','furniture',NULL,NULL,NULL,11,'CAR','carvings',NULL,NULL,NULL,NULL,NULL,NULL,NULL,0),(66,'PKY','sets of piano keys',NULL,NULL,NULL,172,'KEY','piano keys',NULL,NULL,NULL,NULL,NULL,NULL,'*',52),(80,'SID','sides',NULL,NULL,NULL,84,'SKI','skins',NULL,NULL,NULL,NULL,NULL,NULL,'/',2),(79,'SKD','sides',NULL,NULL,NULL,84,'SKI','skins',NULL,NULL,NULL,NULL,NULL,NULL,'/',2),(NULL,NULL,NULL,150,'PAI','pairs',NULL,NULL,NULL,-1,NULL,NULL,NULL,NULL,NULL,'*',2),(NULL,NULL,NULL,125,'BAG','bags',NULL,NULL,NULL,-1,NULL,NULL,NULL,NULL,NULL,NULL,0),(NULL,NULL,NULL,127,'BOT','bottles',NULL,NULL,NULL,-1,NULL,NULL,NULL,NULL,NULL,NULL,0),(NULL,NULL,NULL,128,'BOX','boxes',NULL,NULL,NULL,-1,NULL,NULL,NULL,NULL,NULL,NULL,0),(NULL,NULL,NULL,130,'CAN','cans',NULL,NULL,NULL,-1,NULL,NULL,NULL,NULL,NULL,NULL,0),(NULL,NULL,NULL,131,'CAS','cases',NULL,NULL,NULL,-1,NULL,NULL,NULL,NULL,NULL,NULL,0),(NULL,NULL,NULL,133,'CRT','cartons',NULL,NULL,NULL,-1,NULL,NULL,NULL,NULL,NULL,NULL,0),(NULL,NULL,NULL,138,'FLA','flasks',NULL,NULL,NULL,-1,NULL,NULL,NULL,NULL,NULL,NULL,0),(NULL,NULL,NULL,142,'ITE','items',NULL,NULL,NULL,-1,NULL,NULL,NULL,NULL,NULL,NULL,0),(NULL,NULL,NULL,151,'PCS','pieces',NULL,NULL,NULL,-1,NULL,NULL,NULL,NULL,NULL,NULL,0),(NULL,NULL,NULL,153,'SET','sets',NULL,NULL,NULL,-1,NULL,NULL,NULL,NULL,NULL,NULL,0),(NULL,NULL,NULL,154,'SHP','shipments',NULL,NULL,NULL,-1,NULL,NULL,NULL,NULL,NULL,NULL,0),(NULL,NULL,NULL,156,'SKI','(skins)',NULL,NULL,NULL,-1,NULL,NULL,NULL,NULL,NULL,NULL,0),(NULL,NULL,NULL,148,'MYG','microgrammes',NULL,NULL,NULL,143,'KIL','kg',NULL,NULL,NULL,'/',10),(NULL,NULL,NULL,145,'MGM','mg',NULL,NULL,NULL,143,'KIL','kg',NULL,NULL,NULL,'/',10),(NULL,NULL,NULL,139,'GRM','g',NULL,NULL,NULL,143,'KIL','kg',NULL,NULL,NULL,'/',1000),(NULL,NULL,NULL,161,'TON','metric tonnes',NULL,NULL,NULL,143,'KIL','kg',NULL,NULL,NULL,'*',1000),(NULL,NULL,NULL,146,'MLT','ml',NULL,NULL,NULL,144,'LTR','l',NULL,NULL,NULL,'/',1000),(NULL,NULL,NULL,134,'CTM','cm',NULL,NULL,NULL,147,'MTR','m',NULL,NULL,NULL,'/',100),(NULL,NULL,NULL,157,'SQC','cm2',NULL,NULL,NULL,160,'SQM','m2',NULL,NULL,NULL,'/',10),(NULL,NULL,NULL,158,'SQD','dm2',NULL,NULL,NULL,160,'SQM','m2',NULL,NULL,NULL,'/',100),(NULL,NULL,NULL,132,'CCM','cm3',NULL,NULL,NULL,136,'CUM','m3',NULL,NULL,NULL,'/',10),(NULL,NULL,NULL,149,'OUN','oz',NULL,NULL,NULL,143,'KIL','kg',NULL,NULL,NULL,'/',35),(NULL,NULL,NULL,152,'PND','lbs',NULL,NULL,NULL,143,'KIL','kg',NULL,NULL,NULL,'/',2),(NULL,NULL,NULL,141,'INC','inches',NULL,NULL,NULL,147,'MTR','m',NULL,NULL,NULL,'/',39),(NULL,NULL,NULL,137,'FEE','ft',NULL,NULL,NULL,147,'MTR','m',NULL,NULL,NULL,'/',3),(NULL,NULL,NULL,163,'YAR','yds',NULL,NULL,NULL,143,'KIL','kg',NULL,NULL,NULL,'/',1),(NULL,NULL,NULL,159,'SQF','ft2',NULL,NULL,NULL,160,'SQM','m2',NULL,NULL,NULL,'/',10),(NULL,NULL,NULL,135,'CUF','ft3',NULL,NULL,NULL,136,'CUM','m3',NULL,NULL,NULL,'/',35),(57,'LIV','live',143,'KIL','kg',NULL,NULL,NULL,-1,NULL,NULL,NULL,NULL,NULL,'/',0),(72,'COR','raw corals',-1,NULL,NULL,NULL,NULL,NULL,143,'KIL','kg',NULL,NULL,NULL,'*',0),(58,'LOG','logs',143,'KIL','kg',NULL,NULL,NULL,136,'CUM','m3',NULL,NULL,NULL,'/',725),(74,'SAW','sawn wood',143,'KIL','kg',NULL,NULL,NULL,136,'CUM','m3',NULL,NULL,NULL,'/',725),(93,'TIM','timber',143,'KIL','kg',NULL,NULL,NULL,136,'CUM','m3',NULL,NULL,NULL,'/',725),(58,'LOG','logs',143,'KIL','kg',NULL,NULL,NULL,136,'CUM','m3',NULL,NULL,NULL,'/',440),(74,'SAW','sawn wood',143,'KIL','kg',NULL,NULL,NULL,136,'CUM','m3',NULL,NULL,NULL,'/',440),(93,'TIM','timber',143,'KIL','kg',NULL,NULL,NULL,136,'CUM','m3',NULL,NULL,NULL,'/',440),(58,'LOG','logs',143,'KIL','kg',NULL,NULL,NULL,136,'CUM','m3',NULL,NULL,NULL,'/',1230),(74,'SAW','sawn wood',143,'KIL','kg',NULL,NULL,NULL,136,'CUM','m3',NULL,NULL,NULL,'/',1230),(93,'TIM','timber',143,'KIL','kg',NULL,NULL,NULL,136,'CUM','m3',NULL,NULL,NULL,'/',1230),(58,'LOG','logs',143,'KIL','kg',NULL,NULL,NULL,136,'CUM','m3',NULL,NULL,NULL,'/',730),(74,'SAW','sawn wood',143,'KIL','kg',NULL,NULL,NULL,136,'CUM','m3',NULL,NULL,NULL,'/',730),(93,'TIM','timber',143,'KIL','kg',NULL,NULL,NULL,136,'CUM','m3',NULL,NULL,NULL,'/',730),(58,'LOG','logs',143,'KIL','kg',NULL,NULL,NULL,136,'CUM','m3',NULL,NULL,NULL,'/',610),(74,'SAW','sawn wood',143,'KIL','kg',NULL,NULL,NULL,136,'CUM','m3',NULL,NULL,NULL,'/',610),(93,'TIM','timber',143,'KIL','kg',NULL,NULL,NULL,136,'CUM','m3',NULL,NULL,NULL,'/',610),(58,'LOG','logs',143,'KIL','kg',NULL,NULL,NULL,136,'CUM','m3',NULL,NULL,NULL,'/',750),(74,'SAW','sawn wood',143,'KIL','kg',NULL,NULL,NULL,136,'CUM','m3',NULL,NULL,NULL,'/',750),(93,'TIM','timber',143,'KIL','kg',NULL,NULL,NULL,136,'CUM','m3',NULL,NULL,NULL,'/',750),(58,'LOG','logs',143,'KIL','kg',NULL,NULL,NULL,136,'CUM','m3',NULL,NULL,NULL,'/',570),(74,'SAW','sawn wood',143,'KIL','kg',NULL,NULL,NULL,136,'CUM','m3',NULL,NULL,NULL,'/',570),(93,'TIM','timber',143,'KIL','kg',NULL,NULL,NULL,136,'CUM','m3',NULL,NULL,NULL,'/',570),(58,'LOG','logs',143,'KIL','kg',NULL,NULL,NULL,136,'CUM','m3',NULL,NULL,NULL,'/',480),(74,'SAW','sawn wood',143,'KIL','kg',NULL,NULL,NULL,136,'CUM','m3',NULL,NULL,NULL,'/',480),(93,'TIM','timber',143,'KIL','kg',NULL,NULL,NULL,136,'CUM','m3',NULL,NULL,NULL,'/',480),(58,'LOG','logs',143,'KIL','kg',NULL,NULL,NULL,136,'CUM','m3',NULL,NULL,NULL,'/',970),(74,'SAW','sawn wood',143,'KIL','kg',NULL,NULL,NULL,136,'CUM','m3',NULL,NULL,NULL,'/',970),(93,'TIM','timber',143,'KIL','kg',NULL,NULL,NULL,136,'CUM','m3',NULL,NULL,NULL,'/',970),(58,'LOG','logs',143,'KIL','kg',NULL,NULL,NULL,136,'CUM','m3',NULL,NULL,NULL,'/',350),(74,'SAW','sawn wood',143,'KIL','kg',NULL,NULL,NULL,136,'CUM','m3',NULL,NULL,NULL,'/',350),(93,'TIM','timber',143,'KIL','kg',NULL,NULL,NULL,136,'CUM','m3',NULL,NULL,NULL,'/',350),(58,'LOG','logs',143,'KIL','kg',NULL,NULL,NULL,136,'CUM','m3',NULL,NULL,NULL,'/',740),(74,'SAW','sawn wood',143,'KIL','kg',NULL,NULL,NULL,136,'CUM','m3',NULL,NULL,NULL,'/',740),(93,'TIM','timber',143,'KIL','kg',NULL,NULL,NULL,136,'CUM','m3',NULL,NULL,NULL,'/',740),(58,'LOG','logs',143,'KIL','kg',NULL,NULL,NULL,136,'CUM','m3','{"genus":["Gonystylus spp.", "Gonystylus"]}'::JSON,NULL,NULL,'/',660),(74,'SAW','sawn wood',143,'KIL','kg',NULL,NULL,NULL,136,'CUM','m3','{"genus":["Gonystylus spp.", "Gonystylus"]}'::JSON,NULL,NULL,'/',660),(93,'TIM','timber',143,'KIL','kg',NULL,NULL,NULL,136,'CUM','m3','{"genus":["Gonystylus spp.", "Gonystylus"]}'::JSON,NULL,NULL,'/',660),(NULL,NULL,NULL,129,'BSK','bellyskins',80,'SID','sides',-1,NULL,NULL,NULL,NULL,NULL,NULL,0),(NULL,NULL,NULL,140,'HRN','hornback skins',80,'SID','sides',-1,NULL,NULL,NULL,NULL,NULL,NULL,0),(NULL,NULL,NULL,126,'BAK','backskins',82,'SKP','skin pieces',-1,NULL,NULL,NULL,NULL,NULL,NULL,0),(NULL,NULL,NULL,155,'SID','sides',84,'SKI','skins',-1,NULL,NULL,NULL,NULL,NULL,'/',2)
      )

      SELECT ts.id AS id,ts.year AS year,ts.appendix AS appendix,ts.reported_by_exporter AS reported_by_exporter,ts.taxon_concept_id AS taxon_id,ts.taxon_concept_author_year AS author_year,ts.taxon_concept_name_status AS name_status,ts.taxon_concept_full_name AS taxon_name,ts.taxon_concept_kingdom_name AS kingdom_name,ts.taxon_concept_kingdom_id AS kingdom_id,ts.taxon_concept_phylum_name AS phylum_name,ts.taxon_concept_phylum_id AS phylum_id,ts.taxon_concept_class_name AS class_name,ts.taxon_concept_class_id AS class_id,ts.taxon_concept_order_name AS order_name,ts.taxon_concept_order_id AS order_id,ts.taxon_concept_family_name AS family_name,ts.taxon_concept_family_id AS family_id,ts.taxon_concept_genus_name AS genus_name,ts.taxon_concept_genus_id AS genus_id,ts.group AS group_name,ts.quantity AS quantity,exporters.id AS exporter_id,exporters.iso_code2 AS exporter_iso,exporters.name_en AS exporter,importers.id AS importer_id,importers.iso_code2 AS importer_iso,importers.name_en AS importer,origins.id AS origin_id,origins.iso_code2 AS origin_iso,origins.name_en AS origin,purposes.id AS purpose_id,purposes.name_en AS purpose,sources.id AS source_id,sources.name_en AS source,ranks.id AS rank_id,ranks.name AS rank_name,
             COALESCE(MAX(COALESCE(output_term_id, codes_map.term_id)), ts.term_id) AS term_id,
             COALESCE(MAX(COALESCE(output_term_code, codes_map.term_code)), terms.code)  AS term_code,
             COALESCE(MAX(COALESCE(output_term_name, codes_map.term_name)), terms.name_en) AS term,
             COALESCE(MAX(COALESCE(output_unit_id, codes_map.unit_id)), ts.unit_id) AS unit_id,
             COALESCE(MAX(COALESCE(output_unit_code, codes_map.unit_code)), units.code) AS unit_code,
             COALESCE(MAX(COALESCE(output_unit_name, codes_map.unit_name)), units.name_en) AS unit,
             MAX(term_quantity_modifier) AS term_quantity_modifier,
             MAX(term_modifier_value)::INT AS term_modifier_value,
             MAX(unit_quantity_modifier) AS unit_quantity_modifier,
             MAX(unit_modifier_value)::INT AS unit_modifier_value
        FROM trade_plus_group_view ts
        LEFT OUTER JOIN codes_map ON (
          (
            codes_map.term_id = ts.term_id AND
            (codes_map.unit_id = ts.unit_id OR codes_map.unit_id = -1 AND ts.unit_id IS NULL) AND
            (

              ts.taxon_concept_kingdom_name = ANY (STRING_TO_ARRAY(codes_map.taxa_field ->> 'kingdom', ',')) OR
              ts.taxon_concept_phylum_name = ANY (STRING_TO_ARRAY(codes_map.taxa_field ->> 'phylum', ',')) OR
              ts.taxon_concept_class_name = ANY (STRING_TO_ARRAY(codes_map.taxa_field ->> 'class', ',')) OR
              ts.taxon_concept_order_name = ANY (STRING_TO_ARRAY(codes_map.taxa_field ->> 'order', ',')) OR
              ts.taxon_concept_family_name = ANY (STRING_TO_ARRAY(codes_map.taxa_field ->> 'family', ',')) OR
              ts.taxon_concept_genus_name = ANY (STRING_TO_ARRAY(codes_map.taxa_field ->> 'genus', ',')) OR
              ts.taxon_concept_full_name = ANY (STRING_TO_ARRAY(codes_map.taxa_field ->> 'taxon_name', ',')) OR
              ts.group = ANY (STRING_TO_ARRAY(codes_map.taxa_field ->> 'group', ','))
            )
          ) OR
          (
            codes_map.term_id = ts.term_id AND
            (codes_map.unit_id = ts.unit_id OR codes_map.unit_id = -1 AND ts.unit_id IS NULL) AND
            codes_map.taxa_field IS NULL
          ) OR
          (
            codes_map.term_id = ts.term_id AND codes_map.unit_id IS NULL AND
            (
              ts.taxon_concept_kingdom_name = ANY (STRING_TO_ARRAY(codes_map.taxa_field ->> 'kingdom', ',')) OR
              ts.taxon_concept_phylum_name = ANY (STRING_TO_ARRAY(codes_map.taxa_field ->> 'phylum', ',')) OR
              ts.taxon_concept_class_name = ANY (STRING_TO_ARRAY(codes_map.taxa_field ->> 'class', ',')) OR
              ts.taxon_concept_order_name = ANY (STRING_TO_ARRAY(codes_map.taxa_field ->> 'order', ',')) OR
              ts.taxon_concept_family_name = ANY (STRING_TO_ARRAY(codes_map.taxa_field ->> 'family', ',')) OR
              ts.taxon_concept_genus_name = ANY (STRING_TO_ARRAY(codes_map.taxa_field ->> 'genus', ',')) OR
              ts.taxon_concept_full_name = ANY (STRING_TO_ARRAY(codes_map.taxa_field ->> 'taxon_name', ',')) OR
              ts.group = ANY (STRING_TO_ARRAY(codes_map.taxa_field ->> 'group', ','))
            )
          ) OR
          (
            (codes_map.unit_id = ts.unit_id OR codes_map.unit_id = -1 AND ts.unit_id IS NULL) AND
             codes_map.term_id IS NULL AND
            (
              ts.taxon_concept_kingdom_name = ANY (STRING_TO_ARRAY(codes_map.taxa_field ->> 'kingdom', ',')) OR
              ts.taxon_concept_phylum_name = ANY (STRING_TO_ARRAY(codes_map.taxa_field ->> 'phylum', ',')) OR
              ts.taxon_concept_class_name = ANY (STRING_TO_ARRAY(codes_map.taxa_field ->> 'class', ',')) OR
              ts.taxon_concept_order_name = ANY (STRING_TO_ARRAY(codes_map.taxa_field ->> 'order', ',')) OR
              ts.taxon_concept_family_name = ANY (STRING_TO_ARRAY(codes_map.taxa_field ->> 'family', ',')) OR
              ts.taxon_concept_genus_name = ANY (STRING_TO_ARRAY(codes_map.taxa_field ->> 'genus', ',')) OR
              ts.taxon_concept_full_name = ANY (STRING_TO_ARRAY(codes_map.taxa_field ->> 'taxon_name', ',')) OR
              ts.group = ANY (STRING_TO_ARRAY(codes_map.taxa_field ->> 'group', ','))
            )
          ) OR
          (codes_map.term_id = ts.term_id AND codes_map.unit_id IS NULL AND codes_map.taxa_field IS NULL) OR
          (
            (codes_map.unit_id = ts.unit_id OR codes_map.unit_id = -1 AND ts.unit_id IS NULL) AND
            codes_map.term_id IS NULL AND
            codes_map.taxa_field IS NULL
          ) OR
          (
            codes_map.term_id IS NULL AND codes_map.unit_id IS NULL AND
            (
              ts.taxon_concept_kingdom_name = ANY (STRING_TO_ARRAY(codes_map.taxa_field ->> 'kingdom', ',')) OR
              ts.taxon_concept_phylum_name = ANY (STRING_TO_ARRAY(codes_map.taxa_field ->> 'phylum', ',')) OR
              ts.taxon_concept_class_name = ANY (STRING_TO_ARRAY(codes_map.taxa_field ->> 'class', ',')) OR
              ts.taxon_concept_order_name = ANY (STRING_TO_ARRAY(codes_map.taxa_field ->> 'order', ',')) OR
              ts.taxon_concept_family_name = ANY (STRING_TO_ARRAY(codes_map.taxa_field ->> 'family', ',')) OR
              ts.taxon_concept_genus_name = ANY (STRING_TO_ARRAY(codes_map.taxa_field ->> 'genus', ',')) OR
              ts.taxon_concept_full_name = ANY (STRING_TO_ARRAY(codes_map.taxa_field ->> 'taxon_name', ',')) OR
              ts.group = ANY (STRING_TO_ARRAY(codes_map.taxa_field ->> 'group', ','))
            )
          )
        )
        LEFT OUTER JOIN trade_codes terms ON ts.term_id = terms.id
        LEFT OUTER JOIN trade_codes units ON ts.unit_id = units.id
        LEFT OUTER JOIN trade_codes sources ON ts.source_id = sources.id
        LEFT OUTER JOIN trade_codes purposes ON ts.purpose_id = purposes.id
        INNER JOIN ranks ON ranks.id = ts.taxon_concept_rank_id
        LEFT OUTER JOIN geo_entities exporters ON ts.exporter_id = exporters.id
        LEFT OUTER JOIN geo_entities importers ON ts.importer_id = importers.id
        LEFT OUTER JOIN geo_entities origins ON ts.country_of_origin_id = origins.id
        WHERE  ts.appendix NOT IN ('N')
					AND  ts.term_id NOT IN (17,63,67)

        GROUP BY ts.id,ts.year,ts.appendix,ts.reported_by_exporter,ts.taxon_concept_id,ts.taxon_concept_author_year,ts.taxon_concept_name_status,ts.taxon_concept_full_name,ts.taxon_concept_kingdom_name,ts.taxon_concept_kingdom_id,ts.taxon_concept_phylum_name,ts.taxon_concept_phylum_id,ts.taxon_concept_class_name,ts.taxon_concept_class_id,ts.taxon_concept_order_name,ts.taxon_concept_order_id,ts.taxon_concept_family_name,ts.taxon_concept_family_id,ts.taxon_concept_genus_name,ts.taxon_concept_genus_id,ts.group,ts.quantity,exporters.id,exporters.iso_code2,exporters.name_en,importers.id,importers.iso_code2,importers.name_en,origins.id,origins.iso_code2,origins.name_en,purposes.id,purposes.name_en,sources.id,sources.name_en,ranks.id,ranks.name,quantity,ts.term_id,terms.code,terms.name_en,ts.unit_id,units.code,units.name_en
