      SELECT DISTINCT *
      FROM(
          SELECT ts.id, ts.year, ts.appendix, ts.taxon_concept_id,
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
										CASE WHEN ts.reported_by_exporter IS FALSE THEN Array['LIV', (ts.quantity+0)::text, NULL, units.code]
                      ELSE Array['LIV', NULL, (ts.quantity+0)::text, units.code]
                      END
									WHEN terms.code IN ('LEG') AND units.code IN ('KIL')
									THEN 
										CASE WHEN ts.reported_by_exporter IS FALSE THEN Array['MEA', (ts.quantity+0)::text, NULL, units.code]
                      ELSE Array['MEA', NULL, (ts.quantity+0)::text, units.code]
                      END
									WHEN terms.code IN ('SHE') AND ts.taxon_concept_order_name IN ('Testudines')
									THEN 
										CASE WHEN ts.reported_by_exporter IS FALSE THEN Array['CAP', (ts.quantity+0)::text, NULL, units.code]
                      ELSE Array['CAP', NULL, (ts.quantity+0)::text, units.code]
                      END
									WHEN terms.code IN ('DER','POW') AND ts.taxon_concept_genus_name IN ('Aloe','Euphorbia')
									THEN 
										CASE WHEN ts.reported_by_exporter IS FALSE THEN Array['EXT', (ts.quantity+0)::text, NULL, units.code]
                      ELSE Array['EXT', NULL, (ts.quantity+0)::text, units.code]
                      END
									WHEN terms.code IN ('EGG') AND ts.taxon_concept_order_name IN ('Acipenseriformes')
									THEN 
										CASE WHEN ts.reported_by_exporter IS FALSE THEN Array['CAV', (ts.quantity+0)::text, NULL, units.code]
                      ELSE Array['CAV', NULL, (ts.quantity+0)::text, units.code]
                      END
									WHEN terms.code IN ('DER') AND ts.taxon_concept_order_name IN ('Acipenseriformes')
									THEN 
										CASE WHEN ts.reported_by_exporter IS FALSE THEN Array['EXT', (ts.quantity+0)::text, NULL, units.code]
                      ELSE Array['EXT', NULL, (ts.quantity+0)::text, units.code]
                      END
									WHEN terms.code IN ('BEL','HAN','LEA','SHO','SKO','WAL','WAT')
									THEN 
										CASE WHEN ts.reported_by_exporter IS FALSE THEN Array['LPS', (ts.quantity+0)::text, NULL, units.code]
                      ELSE Array['LPS', NULL, (ts.quantity+0)::text, units.code]
                      END
									WHEN terms.code IN ('CST','FRA')
									THEN 
										CASE WHEN ts.reported_by_exporter IS FALSE THEN Array['CAR', (ts.quantity+0)::text, NULL, units.code]
                      ELSE Array['CAR', NULL, (ts.quantity+0)::text, units.code]
                      END
									WHEN terms.code IN ('BPR')
									THEN 
										CASE WHEN ts.reported_by_exporter IS FALSE THEN Array['BOC', (ts.quantity+0)::text, NULL, units.code]
                      ELSE Array['BOC', NULL, (ts.quantity+0)::text, units.code]
                      END
									WHEN terms.code IN ('HOS')
									THEN 
										CASE WHEN ts.reported_by_exporter IS FALSE THEN Array['HOP', (ts.quantity+0)::text, NULL, units.code]
                      ELSE Array['HOP', NULL, (ts.quantity+0)::text, units.code]
                      END
									WHEN terms.code IN ('IVS')
									THEN 
										CASE WHEN ts.reported_by_exporter IS FALSE THEN Array['IVP', (ts.quantity+0)::text, NULL, units.code]
                      ELSE Array['IVP', NULL, (ts.quantity+0)::text, units.code]
                      END
									WHEN terms.code IN ('QUI')
									THEN 
										CASE WHEN ts.reported_by_exporter IS FALSE THEN Array['FEA', (ts.quantity+0)::text, NULL, units.code]
                      ELSE Array['FEA', NULL, (ts.quantity+0)::text, units.code]
                      END
									WHEN terms.code IN ('SCR')
									THEN 
										CASE WHEN ts.reported_by_exporter IS FALSE THEN Array['DER', (ts.quantity+0)::text, NULL, units.code]
                      ELSE Array['DER', NULL, (ts.quantity+0)::text, units.code]
                      END
									WHEN terms.code IN ('SKS')
									THEN 
										CASE WHEN ts.reported_by_exporter IS FALSE THEN Array['SKP', (ts.quantity+0)::text, NULL, units.code]
                      ELSE Array['SKP', NULL, (ts.quantity+0)::text, units.code]
                      END
									WHEN terms.code IN ('TIC')
									THEN 
										CASE WHEN ts.reported_by_exporter IS FALSE THEN Array['WPR', (ts.quantity+0)::text, NULL, units.code]
                      ELSE Array['WPR', NULL, (ts.quantity+0)::text, units.code]
                      END
									WHEN terms.code IN ('TIP')
									THEN 
										CASE WHEN ts.reported_by_exporter IS FALSE THEN Array['TIM', (ts.quantity+0)::text, NULL, units.code]
                      ELSE Array['TIM', NULL, (ts.quantity+0)::text, units.code]
                      END
									WHEN terms.code IN ('TIS')
									THEN 
										CASE WHEN ts.reported_by_exporter IS FALSE THEN Array['CUL', (ts.quantity+0)::text, NULL, units.code]
                      ELSE Array['CUL', NULL, (ts.quantity+0)::text, units.code]
                      END
									WHEN terms.code IN ('VNM')
									THEN 
										CASE WHEN ts.reported_by_exporter IS FALSE THEN Array['EXT', (ts.quantity+0)::text, NULL, units.code]
                      ELSE Array['EXT', NULL, (ts.quantity+0)::text, units.code]
                      END
									WHEN terms.code IN ('HEA')
									THEN 
										CASE WHEN ts.reported_by_exporter IS FALSE THEN Array['SKU', (ts.quantity+0)::text, NULL, units.code]
                      ELSE Array['SKU', NULL, (ts.quantity+0)::text, units.code]
                      END
									WHEN terms.code IN ('FRN') AND ts.group IN ('Timber')
									THEN 
										CASE WHEN ts.reported_by_exporter IS FALSE THEN Array['WPR', (ts.quantity+0)::text, NULL, units.code]
                      ELSE Array['WPR', NULL, (ts.quantity+0)::text, units.code]
                      END
									WHEN terms.code IN ('FRN')
									THEN 
										CASE WHEN ts.reported_by_exporter IS FALSE THEN Array['CAR', (ts.quantity+0)::text, NULL, units.code]
                      ELSE Array['CAR', NULL, (ts.quantity+0)::text, units.code]
                      END
									WHEN terms.code IN ('PKY')
									THEN 
										CASE WHEN ts.reported_by_exporter IS FALSE THEN Array['KEY', (ts.quantity*52)::text, NULL, units.code]
                      ELSE Array['KEY', NULL, (ts.quantity*52)::text, units.code]
                      END
									WHEN terms.code IN ('SID','SKD')
									THEN 
										CASE WHEN ts.reported_by_exporter IS FALSE THEN Array['SKI', (ts.quantity/2)::text, NULL, units.code]
                      ELSE Array['SKI', NULL, (ts.quantity/2)::text, units.code]
                      END
									WHEN units.code IN ('PAI')
									THEN 
										CASE WHEN ts.reported_by_exporter IS FALSE THEN Array[terms.code, (ts.quantity*2)::text, NULL, 'NULL']
                      ELSE Array[terms.code, NULL, (ts.quantity*2)::text, 'NULL']
                      END
									WHEN units.code IN ('BAG','BOT','BOX','CAN','CAS','CRT','FLA','ITE','PCS','SET','SHP','SKI')
									THEN 
										CASE WHEN ts.reported_by_exporter IS FALSE THEN Array[terms.code, (ts.quantity+0)::text, NULL, 'NULL']
                      ELSE Array[terms.code, NULL, (ts.quantity+0)::text, 'NULL']
                      END
									WHEN units.code IN ('MYG')
									THEN 
										CASE WHEN ts.reported_by_exporter IS FALSE THEN Array[terms.code, (ts.quantity*10)::text, NULL, 'KIL']
                      ELSE Array[terms.code, NULL, (ts.quantity*10)::text, 'KIL']
                      END
									WHEN units.code IN ('MGM')
									THEN 
										CASE WHEN ts.reported_by_exporter IS FALSE THEN Array[terms.code, (ts.quantity/10e+6)::text, NULL, 'KIL']
                      ELSE Array[terms.code, NULL, (ts.quantity/10e+6)::text, 'KIL']
                      END
									WHEN units.code IN ('GRM')
									THEN 
										CASE WHEN ts.reported_by_exporter IS FALSE THEN Array[terms.code, (ts.quantity/1000)::text, NULL, 'KIL']
                      ELSE Array[terms.code, NULL, (ts.quantity/1000)::text, 'KIL']
                      END
									WHEN units.code IN ('TON')
									THEN 
										CASE WHEN ts.reported_by_exporter IS FALSE THEN Array[terms.code, (ts.quantity*1000)::text, NULL, 'KIL']
                      ELSE Array[terms.code, NULL, (ts.quantity*1000)::text, 'KIL']
                      END
									WHEN units.code IN ('MLT')
									THEN 
										CASE WHEN ts.reported_by_exporter IS FALSE THEN Array[terms.code, (ts.quantity/1000)::text, NULL, 'LTR']
                      ELSE Array[terms.code, NULL, (ts.quantity/1000)::text, 'LTR']
                      END
									WHEN units.code IN ('CTM')
									THEN 
										CASE WHEN ts.reported_by_exporter IS FALSE THEN Array[terms.code, (ts.quantity/100)::text, NULL, 'MTR']
                      ELSE Array[terms.code, NULL, (ts.quantity/100)::text, 'MTR']
                      END
									WHEN units.code IN ('SQC')
									THEN 
										CASE WHEN ts.reported_by_exporter IS FALSE THEN Array[terms.code, (ts.quantity/10e+4)::text, NULL, 'SQM']
                      ELSE Array[terms.code, NULL, (ts.quantity/10e+4)::text, 'SQM']
                      END
									WHEN units.code IN ('SQD')
									THEN 
										CASE WHEN ts.reported_by_exporter IS FALSE THEN Array[terms.code, (ts.quantity/100)::text, NULL, 'SQM']
                      ELSE Array[terms.code, NULL, (ts.quantity/100)::text, 'SQM']
                      END
									WHEN units.code IN ('CCM')
									THEN 
										CASE WHEN ts.reported_by_exporter IS FALSE THEN Array[terms.code, (ts.quantity/10e+6)::text, NULL, 'CUM']
                      ELSE Array[terms.code, NULL, (ts.quantity/10e+6)::text, 'CUM']
                      END
									WHEN units.code IN ('OUN')
									THEN 
										CASE WHEN ts.reported_by_exporter IS FALSE THEN Array[terms.code, (ts.quantity/35.274)::text, NULL, 'KIL']
                      ELSE Array[terms.code, NULL, (ts.quantity/35.274)::text, 'KIL']
                      END
									WHEN units.code IN ('PND')
									THEN 
										CASE WHEN ts.reported_by_exporter IS FALSE THEN Array[terms.code, (ts.quantity/2.205)::text, NULL, 'KIL']
                      ELSE Array[terms.code, NULL, (ts.quantity/2.205)::text, 'KIL']
                      END
									WHEN units.code IN ('INC')
									THEN 
										CASE WHEN ts.reported_by_exporter IS FALSE THEN Array[terms.code, (ts.quantity/39.37)::text, NULL, 'MTR']
                      ELSE Array[terms.code, NULL, (ts.quantity/39.37)::text, 'MTR']
                      END
									WHEN units.code IN ('FEE')
									THEN 
										CASE WHEN ts.reported_by_exporter IS FALSE THEN Array[terms.code, (ts.quantity/3.281)::text, NULL, 'MTR']
                      ELSE Array[terms.code, NULL, (ts.quantity/3.281)::text, 'MTR']
                      END
									WHEN units.code IN ('YAR')
									THEN 
										CASE WHEN ts.reported_by_exporter IS FALSE THEN Array[terms.code, (ts.quantity/1.094)::text, NULL, 'KIL']
                      ELSE Array[terms.code, NULL, (ts.quantity/1.094)::text, 'KIL']
                      END
									WHEN units.code IN ('SQF')
									THEN 
										CASE WHEN ts.reported_by_exporter IS FALSE THEN Array[terms.code, (ts.quantity/10.764)::text, NULL, 'SQM']
                      ELSE Array[terms.code, NULL, (ts.quantity/10.764)::text, 'SQM']
                      END
									WHEN units.code IN ('CUF')
									THEN 
										CASE WHEN ts.reported_by_exporter IS FALSE THEN Array[terms.code, (ts.quantity/35.315)::text, NULL, 'CUM']
                      ELSE Array[terms.code, NULL, (ts.quantity/35.315)::text, 'CUM']
                      END
									WHEN units.code IN ('KIL') AND ts.group IN ('Coral') AND terms.code IN ('LIV')
									THEN 
										CASE WHEN ts.reported_by_exporter IS FALSE THEN Array[terms.code, (ts.quantity/0.206)::text, NULL, 'NULL']
                      ELSE Array[terms.code, NULL, (ts.quantity/0.206)::text, 'NULL']
                      END
									WHEN units.code IN ('NULL') AND ts.group IN ('Coral') AND terms.code IN ('COR')
									THEN 
										CASE WHEN ts.reported_by_exporter IS FALSE THEN Array[terms.code, (ts.quantity*0.58)::text, NULL, 'KIL']
                      ELSE Array[terms.code, NULL, (ts.quantity*0.58)::text, 'KIL']
                      END
									WHEN units.code IN ('KIL') AND terms.code IN ('LOG','SAW','TIM') AND ts.taxon_concept_full_name IN ('Pericopsis elata')
									THEN 
										CASE WHEN ts.reported_by_exporter IS FALSE THEN Array[terms.code, (ts.quantity/725)::text, NULL, 'CUM']
                      ELSE Array[terms.code, NULL, (ts.quantity/725)::text, 'CUM']
                      END
									WHEN units.code IN ('KIL') AND terms.code IN ('LOG','SAW','TIM') AND ts.taxon_concept_full_name IN ('Cedrela odorata')
									THEN 
										CASE WHEN ts.reported_by_exporter IS FALSE THEN Array[terms.code, (ts.quantity/440)::text, NULL, 'CUM']
                      ELSE Array[terms.code, NULL, (ts.quantity/440)::text, 'CUM']
                      END
									WHEN units.code IN ('KIL') AND terms.code IN ('LOG','SAW','TIM') AND ts.taxon_concept_full_name IN ('Guaiacum sanctum','Guaiacum officinale')
									THEN 
										CASE WHEN ts.reported_by_exporter IS FALSE THEN Array[terms.code, (ts.quantity/1230)::text, NULL, 'CUM']
                      ELSE Array[terms.code, NULL, (ts.quantity/1230)::text, 'CUM']
                      END
									WHEN units.code IN ('KIL') AND terms.code IN ('LOG','SAW','TIM') AND ts.taxon_concept_full_name IN ('Swietenia macrophylla')
									THEN 
										CASE WHEN ts.reported_by_exporter IS FALSE THEN Array[terms.code, (ts.quantity/730)::text, NULL, 'CUM']
                      ELSE Array[terms.code, NULL, (ts.quantity/730)::text, 'CUM']
                      END
									WHEN units.code IN ('KIL') AND terms.code IN ('LOG','SAW','TIM') AND ts.taxon_concept_full_name IN ('Swietenia humilis')
									THEN 
										CASE WHEN ts.reported_by_exporter IS FALSE THEN Array[terms.code, (ts.quantity/610)::text, NULL, 'CUM']
                      ELSE Array[terms.code, NULL, (ts.quantity/610)::text, 'CUM']
                      END
									WHEN units.code IN ('KIL') AND terms.code IN ('LOG','SAW','TIM') AND ts.taxon_concept_full_name IN ('Swietenia mahagoni')
									THEN 
										CASE WHEN ts.reported_by_exporter IS FALSE THEN Array[terms.code, (ts.quantity/750)::text, NULL, 'CUM']
                      ELSE Array[terms.code, NULL, (ts.quantity/750)::text, 'CUM']
                      END
									WHEN units.code IN ('KIL') AND terms.code IN ('LOG','SAW','TIM') AND ts.taxon_concept_full_name IN ('Araucaria araucana')
									THEN 
										CASE WHEN ts.reported_by_exporter IS FALSE THEN Array[terms.code, (ts.quantity/570)::text, NULL, 'CUM']
                      ELSE Array[terms.code, NULL, (ts.quantity/570)::text, 'CUM']
                      END
									WHEN units.code IN ('KIL') AND terms.code IN ('LOG','SAW','TIM') AND ts.taxon_concept_full_name IN ('Fitzroya cupressoides')
									THEN 
										CASE WHEN ts.reported_by_exporter IS FALSE THEN Array[terms.code, (ts.quantity/480)::text, NULL, 'CUM']
                      ELSE Array[terms.code, NULL, (ts.quantity/480)::text, 'CUM']
                      END
									WHEN units.code IN ('KIL') AND terms.code IN ('LOG','SAW','TIM') AND ts.taxon_concept_full_name IN ('Dalbergia nigra')
									THEN 
										CASE WHEN ts.reported_by_exporter IS FALSE THEN Array[terms.code, (ts.quantity/970)::text, NULL, 'CUM']
                      ELSE Array[terms.code, NULL, (ts.quantity/970)::text, 'CUM']
                      END
									WHEN units.code IN ('KIL') AND terms.code IN ('LOG','SAW','TIM') AND ts.taxon_concept_full_name IN ('Abies guatemalensis')
									THEN 
										CASE WHEN ts.reported_by_exporter IS FALSE THEN Array[terms.code, (ts.quantity/350)::text, NULL, 'CUM']
                      ELSE Array[terms.code, NULL, (ts.quantity/350)::text, 'CUM']
                      END
									WHEN units.code IN ('KIL') AND terms.code IN ('LOG','SAW','TIM') AND ts.taxon_concept_full_name IN ('Prunus africana')
									THEN 
										CASE WHEN ts.reported_by_exporter IS FALSE THEN Array[terms.code, (ts.quantity/740)::text, NULL, 'CUM']
                      ELSE Array[terms.code, NULL, (ts.quantity/740)::text, 'CUM']
                      END
									WHEN units.code IN ('KIL') AND terms.code IN ('LOG','SAW','TIM') AND ts.taxon_concept_genus_name IN ('Gonystylus spp.','Gonystylus')
									THEN 
										CASE WHEN ts.reported_by_exporter IS FALSE THEN Array[terms.code, (ts.quantity/660)::text, NULL, 'CUM']
                      ELSE Array[terms.code, NULL, (ts.quantity/660)::text, 'CUM']
                      END
									WHEN units.code IN ('BSK','HRN')
									THEN 
										CASE WHEN ts.reported_by_exporter IS FALSE THEN Array['SID', (ts.quantity+0)::text, NULL, 'NULL']
                      ELSE Array['SID', NULL, (ts.quantity+0)::text, 'NULL']
                      END
									WHEN units.code IN ('BAK')
									THEN 
										CASE WHEN ts.reported_by_exporter IS FALSE THEN Array['SKP', (ts.quantity+0)::text, NULL, 'NULL']
                      ELSE Array['SKP', NULL, (ts.quantity+0)::text, 'NULL']
                      END
									WHEN units.code IN ('SID')
									THEN 
										CASE WHEN ts.reported_by_exporter IS FALSE THEN Array['SKI', (ts.quantity/2)::text, NULL, 'NULL']
                      ELSE Array['SKI', NULL, (ts.quantity/2)::text, 'NULL']
                      END
									ELSE
										CASE WHEN ts.reported_by_exporter IS FALSE THEN Array[terms.code, ts.quantity::text, NULL, units.code]
                    ELSE Array[terms.code, NULL, ts.quantity::text, units.code]
                    END

									END AS term_imp_exp_unit,
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
