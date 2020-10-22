      SELECT DISTINCT *
      FROM(
          SELECT ts.id, ts.year, ts.appendix, ts.taxon_concept_id, ts.reported_by_exporter,
                 ts.taxon_concept_author_year AS author_year,
                 ts.taxon_concept_name_status AS name_status,
                 ts.taxon_concept_full_name AS taxon_name,
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
                 CASE 									WHEN terms.code IN ('ROO') AND ts.taxon_concept_genus_name IN ('Galanthus','Cyclamen','Sternbergia')
									THEN
										Array['LIV', (ts.quantity)::text, units.code]
									WHEN terms.code IN ('LEG') AND units.code IN ('KIL')
									THEN
										Array['MEA', (ts.quantity)::text, units.code]
									WHEN terms.code IN ('SHE') AND ts.taxon_concept_order_name IN ('Testudines')
									THEN
										Array['CAP', (ts.quantity)::text, units.code]
									WHEN terms.code IN ('DER','POW') AND ts.taxon_concept_genus_name IN ('Aloe','Euphorbia')
									THEN
										Array['EXT', (ts.quantity)::text, units.code]
									WHEN terms.code IN ('EGG') AND ts.taxon_concept_order_name IN ('Acipenseriformes')
									THEN
										Array['CAV', (ts.quantity)::text, units.code]
									WHEN terms.code IN ('DER') AND ts.taxon_concept_order_name IN ('Acipenseriformes')
									THEN
										Array['EXT', (ts.quantity)::text, units.code]
									WHEN terms.code IN ('BEL','HAN','LEA','SHO','SKO','WAL','WAT')
									THEN
										Array['LPS', (ts.quantity)::text, units.code]
									WHEN terms.code IN ('CST','FRA')
									THEN
										Array['CAR', (ts.quantity)::text, units.code]
									WHEN terms.code IN ('BPR')
									THEN
										Array['BOC', (ts.quantity)::text, units.code]
									WHEN terms.code IN ('HOS')
									THEN
										Array['HOP', (ts.quantity)::text, units.code]
									WHEN terms.code IN ('IVS')
									THEN
										Array['IVP', (ts.quantity)::text, units.code]
									WHEN terms.code IN ('QUI')
									THEN
										Array['FEA', (ts.quantity)::text, units.code]
									WHEN terms.code IN ('SCR')
									THEN
										Array['DER', (ts.quantity)::text, units.code]
									WHEN terms.code IN ('SKS')
									THEN
										Array['SKP', (ts.quantity)::text, units.code]
									WHEN terms.code IN ('TIC')
									THEN
										Array['WPR', (ts.quantity)::text, units.code]
									WHEN terms.code IN ('TIP')
									THEN
										Array['TIM', (ts.quantity)::text, units.code]
									WHEN terms.code IN ('TIS')
									THEN
										Array['CUL', (ts.quantity)::text, units.code]
									WHEN terms.code IN ('VNM')
									THEN
										Array['EXT', (ts.quantity)::text, units.code]
									WHEN terms.code IN ('HEA')
									THEN
										Array['SKU', (ts.quantity)::text, units.code]
									WHEN terms.code IN ('FRN') AND ts.group IN ('Timber')
									THEN
										Array['WPR', (ts.quantity)::text, units.code]
									WHEN terms.code IN ('FRN')
									THEN
										Array['CAR', (ts.quantity)::text, units.code]
									WHEN terms.code IN ('PKY')
									THEN
										Array['KEY', (ts.quantity*52)::text, units.code]
									WHEN terms.code IN ('SID','SKD')
									THEN
										Array['SKI', (ts.quantity/2)::text, units.code]
									WHEN units.code IN ('PAI')
									THEN
										Array[terms.code, (ts.quantity*2)::text, 'NULL']
									WHEN units.code IN ('BAG','BOT','BOX','CAN','CAS','CRT','FLA','ITE','PCS','SET','SHP','SKI')
									THEN
										Array[terms.code, (ts.quantity)::text, 'NULL']
									WHEN units.code IN ('MYG')
									THEN
										Array[terms.code, (ts.quantity*10)::text, 'KIL']
									WHEN units.code IN ('MGM')
									THEN
										Array[terms.code, (ts.quantity/10e+6)::text, 'KIL']
									WHEN units.code IN ('GRM')
									THEN
										Array[terms.code, (ts.quantity/1000)::text, 'KIL']
									WHEN units.code IN ('TON')
									THEN
										Array[terms.code, (ts.quantity*1000)::text, 'KIL']
									WHEN units.code IN ('MLT')
									THEN
										Array[terms.code, (ts.quantity/1000)::text, 'LTR']
									WHEN units.code IN ('CTM')
									THEN
										Array[terms.code, (ts.quantity/100)::text, 'MTR']
									WHEN units.code IN ('SQC')
									THEN
										Array[terms.code, (ts.quantity/10e+4)::text, 'SQM']
									WHEN units.code IN ('SQD')
									THEN
										Array[terms.code, (ts.quantity/100)::text, 'SQM']
									WHEN units.code IN ('CCM')
									THEN
										Array[terms.code, (ts.quantity/10e+6)::text, 'CUM']
									WHEN units.code IN ('OUN')
									THEN
										Array[terms.code, (ts.quantity/35.274)::text, 'KIL']
									WHEN units.code IN ('PND')
									THEN
										Array[terms.code, (ts.quantity/2.205)::text, 'KIL']
									WHEN units.code IN ('INC')
									THEN
										Array[terms.code, (ts.quantity/39.37)::text, 'MTR']
									WHEN units.code IN ('FEE')
									THEN
										Array[terms.code, (ts.quantity/3.281)::text, 'MTR']
									WHEN units.code IN ('YAR')
									THEN
										Array[terms.code, (ts.quantity/1.094)::text, 'KIL']
									WHEN units.code IN ('SQF')
									THEN
										Array[terms.code, (ts.quantity/10.764)::text, 'SQM']
									WHEN units.code IN ('CUF')
									THEN
										Array[terms.code, (ts.quantity/35.315)::text, 'CUM']
									WHEN units.code IN ('KIL') AND ts.group IN ('Coral') AND terms.code IN ('LIV')
									THEN
										Array[terms.code, (ts.quantity/0.206)::text, 'NULL']
									WHEN units.code IN ('NULL') AND ts.group IN ('Coral') AND terms.code IN ('COR')
									THEN
										Array[terms.code, (ts.quantity*0.58)::text, 'KIL']
									WHEN units.code IN ('KIL') AND terms.code IN ('LOG','SAW','TIM') AND ts.taxon_concept_full_name IN ('Pericopsis elata')
									THEN
										Array[terms.code, (ts.quantity/725)::text, 'CUM']
									WHEN units.code IN ('KIL') AND terms.code IN ('LOG','SAW','TIM') AND ts.taxon_concept_full_name IN ('Cedrela odorata')
									THEN
										Array[terms.code, (ts.quantity/440)::text, 'CUM']
									WHEN units.code IN ('KIL') AND terms.code IN ('LOG','SAW','TIM') AND ts.taxon_concept_full_name IN ('Guaiacum sanctum','Guaiacum officinale')
									THEN
										Array[terms.code, (ts.quantity/1230)::text, 'CUM']
									WHEN units.code IN ('KIL') AND terms.code IN ('LOG','SAW','TIM') AND ts.taxon_concept_full_name IN ('Swietenia macrophylla')
									THEN
										Array[terms.code, (ts.quantity/730)::text, 'CUM']
									WHEN units.code IN ('KIL') AND terms.code IN ('LOG','SAW','TIM') AND ts.taxon_concept_full_name IN ('Swietenia humilis')
									THEN
										Array[terms.code, (ts.quantity/610)::text, 'CUM']
									WHEN units.code IN ('KIL') AND terms.code IN ('LOG','SAW','TIM') AND ts.taxon_concept_full_name IN ('Swietenia mahagoni')
									THEN
										Array[terms.code, (ts.quantity/750)::text, 'CUM']
									WHEN units.code IN ('KIL') AND terms.code IN ('LOG','SAW','TIM') AND ts.taxon_concept_full_name IN ('Araucaria araucana')
									THEN
										Array[terms.code, (ts.quantity/570)::text, 'CUM']
									WHEN units.code IN ('KIL') AND terms.code IN ('LOG','SAW','TIM') AND ts.taxon_concept_full_name IN ('Fitzroya cupressoides')
									THEN
										Array[terms.code, (ts.quantity/480)::text, 'CUM']
									WHEN units.code IN ('KIL') AND terms.code IN ('LOG','SAW','TIM') AND ts.taxon_concept_full_name IN ('Dalbergia nigra')
									THEN
										Array[terms.code, (ts.quantity/970)::text, 'CUM']
									WHEN units.code IN ('KIL') AND terms.code IN ('LOG','SAW','TIM') AND ts.taxon_concept_full_name IN ('Abies guatemalensis')
									THEN
										Array[terms.code, (ts.quantity/350)::text, 'CUM']
									WHEN units.code IN ('KIL') AND terms.code IN ('LOG','SAW','TIM') AND ts.taxon_concept_full_name IN ('Prunus africana')
									THEN
										Array[terms.code, (ts.quantity/740)::text, 'CUM']
									WHEN units.code IN ('KIL') AND terms.code IN ('LOG','SAW','TIM') AND ts.taxon_concept_genus_name IN ('Gonystylus spp.','Gonystylus')
									THEN
										Array[terms.code, (ts.quantity/660)::text, 'CUM']
									WHEN units.code IN ('BSK','HRN')
									THEN
										Array['SID', (ts.quantity)::text, 'NULL']
									WHEN units.code IN ('BAK')
									THEN
										Array['SKP', (ts.quantity)::text, 'NULL']
									WHEN units.code IN ('SID')
									THEN
										Array['SKI', (ts.quantity/2)::text, 'NULL']
									ELSE										Array[terms.code, ts.quantity::text, units.code]

									END AS term_quantity_unit,
                 -- terms.id AS term_id,
                 -- terms.name_en AS term,
                 -- units.id AS unit_id,
                 -- units.name_en AS unit,
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
          INNER JOIN species_listings listings ON listings.abbreviation = ts.appendix
          INNER JOIN trade_codes sources ON ts.source_id = sources.id
          INNER JOIN trade_codes purposes ON ts.purpose_id = purposes.id
          INNER JOIN ranks ON ranks.id = ts.taxon_concept_rank_id
          LEFT OUTER JOIN trade_codes terms ON ts.term_id = terms.id
          LEFT OUTER JOIN trade_codes units ON ts.unit_id = units.id
          LEFT OUTER JOIN geo_entities exporters ON ts.exporter_id = exporters.id
          LEFT OUTER JOIN geo_entities importers ON ts.importer_id = importers.id
          LEFT OUTER JOIN geo_entities origins ON ts.country_of_origin_id = origins.id
          WHERE listings.designation_id = 1
          AND ts.year >= 2010 AND ts.year < 2019
          AND  ts.appendix NOT IN ('N')
					AND  terms.code NOT IN ('COS','OTH','PIE')

        ) AS s
