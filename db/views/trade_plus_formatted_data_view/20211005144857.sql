            WITH codes_map(term_id,term_code,term_name,unit_id,unit_code,unit_name,output_term_id,output_term_code,output_term_name,output_unit_id,output_unit_code,output_unit_name,taxa_field,term_quantity_modifier,term_modifier_value,unit_quantity_modifier,unit_modifier_value) AS (
        VALUES (73,'ROO','roots',NULL,NULL,NULL,57,'LIV','live',NULL,NULL,NULL,'{"genus":"Galanthus,Cyclamen,Sternbergia"}'::JSON,'',1.0,NULL,NULL),
(56,'LEG','frog legs',143,'KGM','kg',59,'MEA','meat',NULL,NULL,NULL,NULL,NULL,NULL,'',1.0),
(78,'SHE','shells',NULL,NULL,NULL,10,'CAP','carapaces',NULL,NULL,NULL,'{"order":"Testudines"}'::JSON,'',1.0,NULL,NULL),
(19,'DER','derivatives',NULL,NULL,NULL,24,'EXT','extract',NULL,NULL,NULL,'{"genus":"Aloe,Euphorbia"}'::JSON,'',1.0,NULL,NULL),
(70,'POW','powder',NULL,NULL,NULL,24,'EXT','extract',NULL,NULL,NULL,'{"genus":"Aloe,Euphorbia"}'::JSON,'',1.0,NULL,NULL),
(22,'EGG','eggs',NULL,NULL,NULL,12,'CAV','caviar',NULL,NULL,NULL,'{"order":"Acipenseriformes"}'::JSON,'',1.0,NULL,NULL),
(19,'DER','derivatives',NULL,NULL,NULL,24,'EXT','extract',NULL,NULL,NULL,'{"order":"Acipenseriformes"}'::JSON,'',1.0,NULL,NULL),
(3,'BEL','belts',NULL,NULL,NULL,54,'LPS','leather products (small)',NULL,NULL,NULL,NULL,'',1.0,NULL,NULL),
(40,'HAN','handbags',NULL,NULL,NULL,54,'LPS','leather products (small)',NULL,NULL,NULL,NULL,'',1.0,NULL,NULL),
(64,'SHO','shoes',NULL,NULL,NULL,54,'LPS','leather products (small)',NULL,NULL,NULL,NULL,'',1.0,NULL,NULL),
(52,'SKO','leather items',NULL,NULL,NULL,54,'LPS','leather products (small)',NULL,NULL,NULL,NULL,'',1.0,NULL,NULL),
(101,'WAL','wallets',NULL,NULL,NULL,54,'LPS','leather products (small)',NULL,NULL,NULL,NULL,'',1.0,NULL,NULL),
(102,'WAT','watchstraps',NULL,NULL,NULL,54,'LPS','leather products (small)',NULL,NULL,NULL,NULL,'',1.0,NULL,NULL),
(13,'CST','chess sets',NULL,NULL,NULL,11,'CAR','carvings',NULL,NULL,NULL,NULL,'',1.0,NULL,NULL),
(88,'FRA','spectacle frames',NULL,NULL,NULL,11,'CAR','carvings',NULL,NULL,NULL,NULL,'',1.0,NULL,NULL),
(7,'BPR','bone products',NULL,NULL,NULL,5,'BOC','bone carvings',NULL,NULL,NULL,NULL,'',1.0,NULL,NULL),
(45,'HOS','horn scraps',NULL,NULL,NULL,43,'HOP','horn pieces',NULL,NULL,NULL,NULL,'',1.0,NULL,NULL),
(50,'IVS','ivory scraps',NULL,NULL,NULL,49,'IVP','ivory pieces',NULL,NULL,NULL,NULL,'',1.0,NULL,NULL),
(71,'QUI','quills',NULL,NULL,NULL,25,'FEA','feathers',NULL,NULL,NULL,'{"group":"Birds"}'::JSON,'',1.0,NULL,NULL),
(76,'SCR','scraps',NULL,NULL,NULL,19,'DER','derivatives',NULL,NULL,NULL,NULL,'',1.0,NULL,NULL),
(83,'SKS','skin scraps',NULL,NULL,NULL,82,'SKP','skin pieces',NULL,NULL,NULL,NULL,'',1.0,NULL,NULL),
(94,'TIC','timber carvings',NULL,NULL,NULL,177,'WPR','wood product',NULL,NULL,NULL,NULL,'',1.0,NULL,NULL),
(95,'TIP','timber pieces',NULL,NULL,NULL,93,'TIM','timber',NULL,NULL,NULL,NULL,'',1.0,NULL,NULL),
(96,'TIS','tissue cultures',NULL,NULL,NULL,18,'CUL','cultures',NULL,NULL,NULL,NULL,'',1.0,NULL,NULL),
(100,'VNM','venom',NULL,NULL,NULL,24,'EXT','extract',NULL,NULL,NULL,NULL,'',1.0,NULL,NULL),
(41,'HEA','heads',NULL,NULL,NULL,85,'SKU','skulls',NULL,NULL,NULL,NULL,'',1.0,NULL,NULL),
(47,'FRN','furniture',NULL,NULL,NULL,177,'WPR','wood product',NULL,NULL,NULL,'{"group":"Timber"}'::JSON,'',1.0,NULL,NULL),
(47,'FRN','furniture',NULL,NULL,NULL,11,'CAR','carvings',NULL,NULL,NULL,NULL,'',1.0,NULL,NULL),
(51,'LEA','leather',NULL,NULL,NULL,55,'LVS','leaves',NULL,NULL,NULL,'{"group":"Plants"}'::JSON,'',1.0,NULL,NULL),
(51,'LEA','leather',NULL,NULL,NULL,54,'LPS','leather products (small)',NULL,NULL,NULL,NULL,'',1.0,NULL,NULL),
(66,'PKY','sets of piano keys',NULL,NULL,NULL,172,'KEY','piano keys',NULL,NULL,NULL,NULL,'*',52.0,NULL,NULL),
(80,'SID','sides',-1,'NULL','NULL',84,'SKI','skins',NULL,NULL,NULL,NULL,NULL,NULL,'/',2.0),
(79,'SKD','sides',-1,'NULL','NULL',84,'SKI','skins',NULL,NULL,NULL,NULL,NULL,NULL,'/',2.0),
(104,'WOO','wood products',NULL,NULL,NULL,177,'WPR','wood product',NULL,NULL,NULL,NULL,'',1.0,NULL,NULL),
(NULL,NULL,NULL,150,'PAI','pairs',NULL,NULL,NULL,-1,'NULL','NULL',NULL,NULL,NULL,'*',2.0),
(NULL,NULL,NULL,125,'BAG','bags',NULL,NULL,NULL,-1,'NULL','NULL',NULL,NULL,NULL,NULL,NULL),
(NULL,NULL,NULL,127,'BOT','bottles',NULL,NULL,NULL,-1,'NULL','NULL',NULL,NULL,NULL,NULL,NULL),
(NULL,NULL,NULL,128,'BOX','boxes',NULL,NULL,NULL,-1,'NULL','NULL',NULL,NULL,NULL,NULL,NULL),
(NULL,NULL,NULL,130,'CAN','cans',NULL,NULL,NULL,-1,'NULL','NULL',NULL,NULL,NULL,NULL,NULL),
(NULL,NULL,NULL,131,'CAS','cases',NULL,NULL,NULL,-1,'NULL','NULL',NULL,NULL,NULL,NULL,NULL),
(NULL,NULL,NULL,133,'CRT','cartons',NULL,NULL,NULL,-1,'NULL','NULL',NULL,NULL,NULL,NULL,NULL),
(NULL,NULL,NULL,138,'FLA','flasks',NULL,NULL,NULL,-1,'NULL','NULL',NULL,NULL,NULL,NULL,NULL),
(NULL,NULL,NULL,142,'ITE','items',NULL,NULL,NULL,-1,'NULL','NULL',NULL,NULL,NULL,NULL,NULL),
(NULL,NULL,NULL,151,'PCS','pieces',NULL,NULL,NULL,-1,'NULL','NULL',NULL,NULL,NULL,NULL,NULL),
(NULL,NULL,NULL,153,'SET','sets',NULL,NULL,NULL,-1,'NULL','NULL',NULL,NULL,NULL,NULL,NULL),
(NULL,NULL,NULL,154,'SHP','shipments',NULL,NULL,NULL,-1,'NULL','NULL',NULL,NULL,NULL,NULL,NULL),
(NULL,NULL,NULL,156,'SKI','(skins)',NULL,NULL,NULL,-1,'NULL','NULL',NULL,NULL,NULL,NULL,NULL),
(NULL,NULL,NULL,148,'MYG','microgrammes',NULL,NULL,NULL,143,'KGM','kg',NULL,NULL,NULL,'/',1000000000.0),
(NULL,NULL,NULL,145,'MGM','mg',NULL,NULL,NULL,143,'KGM','kg',NULL,NULL,NULL,'/',1000000.0),
(NULL,NULL,NULL,139,'GRM','g',NULL,NULL,NULL,143,'KGM','kg',NULL,NULL,NULL,'/',1000.0),
(NULL,NULL,NULL,161,'TON','metric tonnes',NULL,NULL,NULL,143,'KGM','kg',NULL,NULL,NULL,'*',1000.0),
(NULL,NULL,NULL,146,'MLT','ml',NULL,NULL,NULL,144,'LTR','l',NULL,NULL,NULL,'/',1000.0),
(NULL,NULL,NULL,134,'CTM','cm',NULL,NULL,NULL,147,'MTR','m',NULL,NULL,NULL,'/',100.0),
(NULL,NULL,NULL,157,'SQC','cm2',NULL,NULL,NULL,160,'MTK','m2',NULL,NULL,NULL,'/',10000.0),
(NULL,NULL,NULL,158,'SQD','dm2',NULL,NULL,NULL,160,'MTK','m2',NULL,NULL,NULL,'/',100.0),
(NULL,NULL,NULL,132,'CMQ','cm3',NULL,NULL,NULL,136,'MTQ','m3',NULL,NULL,NULL,'/',1000000.0),
(NULL,NULL,NULL,149,'OUN','oz',NULL,NULL,NULL,143,'KGM','kg',NULL,NULL,NULL,'/',35.274),
(NULL,NULL,NULL,152,'PND','lbs',NULL,NULL,NULL,143,'KGM','kg',NULL,NULL,NULL,'/',2.205),
(NULL,NULL,NULL,141,'INC','inches',NULL,NULL,NULL,147,'MTR','m',NULL,NULL,NULL,'/',39.37),
(NULL,NULL,NULL,137,'FEE','ft',NULL,NULL,NULL,147,'MTR','m',NULL,NULL,NULL,'/',3.281),
(NULL,NULL,NULL,163,'YAR','yds',NULL,NULL,NULL,147,'MTR','m',NULL,NULL,NULL,'/',1.094),
(NULL,NULL,NULL,159,'SQF','ft2',NULL,NULL,NULL,160,'MTK','m2',NULL,NULL,NULL,'/',10.764),
(NULL,NULL,NULL,135,'CUF','ft3',NULL,NULL,NULL,136,'MTQ','m3',NULL,NULL,NULL,'/',35.315),
(57,'LIV','live',143,'KGM','kg',NULL,NULL,NULL,-1,'NULL','NULL','{"group":"Coral"}'::JSON,NULL,NULL,'/',0.206),
(72,'COR','raw corals',-1,'NULL','NULL',NULL,NULL,NULL,143,'KGM','kg','{"group":"Coral"}'::JSON,NULL,NULL,'*',0.58),
(58,'LOG','logs',143,'KGM','kg',NULL,NULL,NULL,136,'MTQ','m3','{"taxa":"Pericopsis elata"}'::JSON,NULL,NULL,'/',725.0),
(74,'SAW','sawn wood',143,'KGM','kg',NULL,NULL,NULL,136,'MTQ','m3','{"taxa":"Pericopsis elata"}'::JSON,NULL,NULL,'/',725.0),
(93,'TIM','timber',143,'KGM','kg',NULL,NULL,NULL,136,'MTQ','m3','{"taxa":"Pericopsis elata"}'::JSON,NULL,NULL,'/',725.0),
(58,'LOG','logs',143,'KGM','kg',NULL,NULL,NULL,136,'MTQ','m3','{"taxa":"Cedrela odorata"}'::JSON,NULL,NULL,'/',440.0),
(74,'SAW','sawn wood',143,'KGM','kg',NULL,NULL,NULL,136,'MTQ','m3','{"taxa":"Cedrela odorata"}'::JSON,NULL,NULL,'/',440.0),
(93,'TIM','timber',143,'KGM','kg',NULL,NULL,NULL,136,'MTQ','m3','{"taxa":"Cedrela odorata"}'::JSON,NULL,NULL,'/',440.0),
(58,'LOG','logs',143,'KGM','kg',NULL,NULL,NULL,136,'MTQ','m3','{"taxa":"Guaiacum sanctum,Guaiacum officinale"}'::JSON,NULL,NULL,'/',1230.0),
(74,'SAW','sawn wood',143,'KGM','kg',NULL,NULL,NULL,136,'MTQ','m3','{"taxa":"Guaiacum sanctum,Guaiacum officinale"}'::JSON,NULL,NULL,'/',1230.0),
(93,'TIM','timber',143,'KGM','kg',NULL,NULL,NULL,136,'MTQ','m3','{"taxa":"Guaiacum sanctum,Guaiacum officinale"}'::JSON,NULL,NULL,'/',1230.0),
(58,'LOG','logs',143,'KGM','kg',NULL,NULL,NULL,136,'MTQ','m3','{"taxa":"Swietenia macrophylla"}'::JSON,NULL,NULL,'/',730.0),
(74,'SAW','sawn wood',143,'KGM','kg',NULL,NULL,NULL,136,'MTQ','m3','{"taxa":"Swietenia macrophylla"}'::JSON,NULL,NULL,'/',730.0),
(93,'TIM','timber',143,'KGM','kg',NULL,NULL,NULL,136,'MTQ','m3','{"taxa":"Swietenia macrophylla"}'::JSON,NULL,NULL,'/',730.0),
(58,'LOG','logs',143,'KGM','kg',NULL,NULL,NULL,136,'MTQ','m3','{"taxa":"Swietenia humilis"}'::JSON,NULL,NULL,'/',610.0),
(74,'SAW','sawn wood',143,'KGM','kg',NULL,NULL,NULL,136,'MTQ','m3','{"taxa":"Swietenia humilis"}'::JSON,NULL,NULL,'/',610.0),
(93,'TIM','timber',143,'KGM','kg',NULL,NULL,NULL,136,'MTQ','m3','{"taxa":"Swietenia humilis"}'::JSON,NULL,NULL,'/',610.0),
(58,'LOG','logs',143,'KGM','kg',NULL,NULL,NULL,136,'MTQ','m3','{"taxa":"Swietenia mahagoni"}'::JSON,NULL,NULL,'/',750.0),
(74,'SAW','sawn wood',143,'KGM','kg',NULL,NULL,NULL,136,'MTQ','m3','{"taxa":"Swietenia mahagoni"}'::JSON,NULL,NULL,'/',750.0),
(93,'TIM','timber',143,'KGM','kg',NULL,NULL,NULL,136,'MTQ','m3','{"taxa":"Swietenia mahagoni"}'::JSON,NULL,NULL,'/',750.0),
(58,'LOG','logs',143,'KGM','kg',NULL,NULL,NULL,136,'MTQ','m3','{"taxa":"Araucaria araucana"}'::JSON,NULL,NULL,'/',570.0),
(74,'SAW','sawn wood',143,'KGM','kg',NULL,NULL,NULL,136,'MTQ','m3','{"taxa":"Araucaria araucana"}'::JSON,NULL,NULL,'/',570.0),
(93,'TIM','timber',143,'KGM','kg',NULL,NULL,NULL,136,'MTQ','m3','{"taxa":"Araucaria araucana"}'::JSON,NULL,NULL,'/',570.0),
(58,'LOG','logs',143,'KGM','kg',NULL,NULL,NULL,136,'MTQ','m3','{"taxa":"Fitzroya cupressoides"}'::JSON,NULL,NULL,'/',480.0),
(74,'SAW','sawn wood',143,'KGM','kg',NULL,NULL,NULL,136,'MTQ','m3','{"taxa":"Fitzroya cupressoides"}'::JSON,NULL,NULL,'/',480.0),
(93,'TIM','timber',143,'KGM','kg',NULL,NULL,NULL,136,'MTQ','m3','{"taxa":"Fitzroya cupressoides"}'::JSON,NULL,NULL,'/',480.0),
(58,'LOG','logs',143,'KGM','kg',NULL,NULL,NULL,136,'MTQ','m3','{"taxa":"Dalbergia nigra"}'::JSON,NULL,NULL,'/',970.0),
(74,'SAW','sawn wood',143,'KGM','kg',NULL,NULL,NULL,136,'MTQ','m3','{"taxa":"Dalbergia nigra"}'::JSON,NULL,NULL,'/',970.0),
(93,'TIM','timber',143,'KGM','kg',NULL,NULL,NULL,136,'MTQ','m3','{"taxa":"Dalbergia nigra"}'::JSON,NULL,NULL,'/',970.0),
(58,'LOG','logs',143,'KGM','kg',NULL,NULL,NULL,136,'MTQ','m3','{"taxa":"Abies guatemalensis"}'::JSON,NULL,NULL,'/',350.0),
(74,'SAW','sawn wood',143,'KGM','kg',NULL,NULL,NULL,136,'MTQ','m3','{"taxa":"Abies guatemalensis"}'::JSON,NULL,NULL,'/',350.0),
(93,'TIM','timber',143,'KGM','kg',NULL,NULL,NULL,136,'MTQ','m3','{"taxa":"Abies guatemalensis"}'::JSON,NULL,NULL,'/',350.0),
(58,'LOG','logs',143,'KGM','kg',NULL,NULL,NULL,136,'MTQ','m3','{"taxa":"Prunus africana"}'::JSON,NULL,NULL,'/',740.0),
(74,'SAW','sawn wood',143,'KGM','kg',NULL,NULL,NULL,136,'MTQ','m3','{"taxa":"Prunus africana"}'::JSON,NULL,NULL,'/',740.0),
(93,'TIM','timber',143,'KGM','kg',NULL,NULL,NULL,136,'MTQ','m3','{"taxa":"Prunus africana"}'::JSON,NULL,NULL,'/',740.0),
(58,'LOG','logs',143,'KGM','kg',NULL,NULL,NULL,136,'MTQ','m3','{"genus":"Gonystylus spp.,Gonystylus"}'::JSON,NULL,NULL,'/',660.0),
(74,'SAW','sawn wood',143,'KGM','kg',NULL,NULL,NULL,136,'MTQ','m3','{"genus":"Gonystylus spp.,Gonystylus"}'::JSON,NULL,NULL,'/',660.0),
(93,'TIM','timber',143,'KGM','kg',NULL,NULL,NULL,136,'MTQ','m3','{"genus":"Gonystylus spp.,Gonystylus"}'::JSON,NULL,NULL,'/',660.0),
(NULL,NULL,NULL,182,'NAR','Number of Specimens',NULL,NULL,NULL,-1,'NULL','NULL',NULL,NULL,NULL,'',1.0)
      )

      SELECT ts.id AS id,ts.year AS year,ts.appendix AS appendix,ts.reported_by_exporter AS reported_by_exporter,ts.taxon_concept_id AS taxon_id,ts.taxon_concept_author_year AS author_year,ts.taxon_concept_name_status AS name_status,ts.taxon_concept_full_name AS taxon_name,ts.taxon_concept_kingdom_name AS kingdom_name,ts.taxon_concept_kingdom_id AS kingdom_id,ts.taxon_concept_phylum_name AS phylum_name,ts.taxon_concept_phylum_id AS phylum_id,ts.taxon_concept_class_name AS class_name,ts.taxon_concept_class_id AS class_id,ts.taxon_concept_order_name AS order_name,ts.taxon_concept_order_id AS order_id,ts.taxon_concept_family_name AS family_name,ts.taxon_concept_family_id AS family_id,ts.taxon_concept_genus_name AS genus_name,ts.taxon_concept_genus_id AS genus_id,ts.group_en AS group_name_en,ts.group_es AS group_name_es,ts.group_fr AS group_name_fr,ts.quantity AS quantity,exporters.id AS exporter_id,exporters.iso_code2 AS exporter_iso,exporters.name_en AS exporter_en,exporters.name_es AS exporter_es,exporters.name_fr AS exporter_fr,importers.id AS importer_id,importers.iso_code2 AS importer_iso,importers.name_en AS importer_en,importers.name_es AS importer_es,importers.name_fr AS importer_fr,origins.id AS origin_id,origins.iso_code2 AS origin_iso,origins.name_en AS origin_en,origins.name_es AS origin_es,origins.name_fr AS origin_fr,purposes.id AS purpose_id,purposes.name_en AS purpose_en,purposes.name_es AS purpose_es,purposes.name_fr AS purpose_fr,purposes.code AS purpose_code,sources.id AS source_id,sources.name_en AS source_en,sources.name_es AS source_es,sources.name_fr AS source_fr,sources.code AS source_code,ranks.id AS rank_id,ranks.display_name_en AS rank_name_en,ranks.display_name_es AS rank_name_es,ranks.display_name_fr AS rank_name_fr,
             -- MAX functions are supposed to to merge rows together based on the join
             -- conditions and replacing NULLs with values from related rows when possible.
             -- Moreover, if ids are -1 or codes/names are 'NULL' strings, replace those with NULL
             -- after the processing is done. This is to get back to just a unique NULL representation.
             NULLIF(COALESCE(MAX(COALESCE(output_term_id, codes_map.term_id)), ts.term_id), -1) AS term_id,
             NULLIF(COALESCE(MAX(COALESCE(output_term_code, codes_map.term_code)), terms.code), 'NULL') AS term_code,
             NULLIF(COALESCE(MAX(COALESCE(output_term_name, codes_map.term_name)), terms.name_en), 'NULL') AS term_en,
             NULLIF(COALESCE(MAX(COALESCE(output_unit_id, codes_map.unit_id)), ts.unit_id), -1) AS unit_id,
             NULLIF(COALESCE(MAX(COALESCE(output_unit_code, codes_map.unit_code)), units.code), 'NULL') AS unit_code,
             NULLIF(COALESCE(MAX(COALESCE(output_unit_name, codes_map.unit_name)), units.name_en), 'NULL') AS unit_en,
             MAX(term_quantity_modifier) AS term_quantity_modifier,
             MAX(term_modifier_value)::FLOAT AS term_modifier_value,
             MAX(unit_quantity_modifier) AS unit_quantity_modifier,
             MAX(unit_modifier_value)::FLOAT AS unit_modifier_value
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
        ts.taxon_concept_full_name = ANY (STRING_TO_ARRAY(codes_map.taxa_field ->> 'taxa', ',')) OR
        ts.group_en = ANY (STRING_TO_ARRAY(codes_map.taxa_field ->> 'group', ','))
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
        ts.taxon_concept_full_name = ANY (STRING_TO_ARRAY(codes_map.taxa_field ->> 'taxa', ',')) OR
        ts.group_en = ANY (STRING_TO_ARRAY(codes_map.taxa_field ->> 'group', ','))
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
        ts.taxon_concept_full_name = ANY (STRING_TO_ARRAY(codes_map.taxa_field ->> 'taxa', ',')) OR
        ts.group_en = ANY (STRING_TO_ARRAY(codes_map.taxa_field ->> 'group', ','))
      )

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
        ) OR
        (
          codes_map.term_id IS NULL AND
          codes_map.unit_id IS NULL AND
                (
        ts.taxon_concept_kingdom_name = ANY (STRING_TO_ARRAY(codes_map.taxa_field ->> 'kingdom', ',')) OR
        ts.taxon_concept_phylum_name = ANY (STRING_TO_ARRAY(codes_map.taxa_field ->> 'phylum', ',')) OR
        ts.taxon_concept_class_name = ANY (STRING_TO_ARRAY(codes_map.taxa_field ->> 'class', ',')) OR
        ts.taxon_concept_order_name = ANY (STRING_TO_ARRAY(codes_map.taxa_field ->> 'order', ',')) OR
        ts.taxon_concept_family_name = ANY (STRING_TO_ARRAY(codes_map.taxa_field ->> 'family', ',')) OR
        ts.taxon_concept_genus_name = ANY (STRING_TO_ARRAY(codes_map.taxa_field ->> 'genus', ',')) OR
        ts.taxon_concept_full_name = ANY (STRING_TO_ARRAY(codes_map.taxa_field ->> 'taxa', ',')) OR
        ts.group_en = ANY (STRING_TO_ARRAY(codes_map.taxa_field ->> 'group', ','))
      )

        )
      )

        LEFT OUTER JOIN trade_codes terms ON ts.term_id = terms.id
        LEFT OUTER JOIN trade_codes units ON ts.unit_id = units.id
        LEFT OUTER JOIN trade_codes sources ON ts.source_id = sources.id
        LEFT OUTER JOIN trade_codes purposes ON ts.purpose_id = purposes.id
        INNER JOIN ranks ON ranks.id = ts.taxon_concept_rank_id
        LEFT OUTER JOIN geo_entities exporters ON ts.china_exporter_id = exporters.id
        LEFT OUTER JOIN geo_entities importers ON ts.china_importer_id = importers.id
        LEFT OUTER JOIN geo_entities origins ON ts.china_origin_id = origins.id
        WHERE  ts.appendix NOT IN ('N')

        GROUP BY ts.id,ts.year,ts.appendix,ts.reported_by_exporter,ts.taxon_concept_id,ts.taxon_concept_author_year,ts.taxon_concept_name_status,ts.taxon_concept_full_name,ts.taxon_concept_kingdom_name,ts.taxon_concept_kingdom_id,ts.taxon_concept_phylum_name,ts.taxon_concept_phylum_id,ts.taxon_concept_class_name,ts.taxon_concept_class_id,ts.taxon_concept_order_name,ts.taxon_concept_order_id,ts.taxon_concept_family_name,ts.taxon_concept_family_id,ts.taxon_concept_genus_name,ts.taxon_concept_genus_id,ts.group_en,ts.group_es,ts.group_fr,ts.quantity,exporters.id,exporters.iso_code2,exporters.name_en,exporters.name_es,exporters.name_fr,importers.id,importers.iso_code2,importers.name_en,importers.name_es,importers.name_fr,origins.id,origins.iso_code2,origins.name_en,origins.name_es,origins.name_fr,purposes.id,purposes.name_en,purposes.name_es,purposes.name_fr,purposes.code,sources.id,sources.name_en,sources.name_es,sources.name_fr,sources.code,ranks.id,ranks.display_name_en,ranks.display_name_es,ranks.display_name_fr,quantity,ts.term_id,terms.code,terms.name_en,terms.name_es,terms.name_fr,ts.unit_id,units.code,units.name_en,units.name_es,units.name_fr
