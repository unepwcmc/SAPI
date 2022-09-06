    SELECT
      ts.*,
      CASE 			WHEN ts.taxon_concept_class_name IN ('Mammalia') THEN 'Mammals'
			WHEN ts.taxon_concept_class_name IN ('Aves') THEN 'Birds'
			WHEN ts.taxon_concept_class_name IN ('Reptilia') THEN 'Reptiles'
			WHEN ts.taxon_concept_class_name IN ('Amphibia') THEN 'Amphibians'
			WHEN ts.taxon_concept_class_name IN ('Elasmobranchii','Actinopteri','Coelacanthi','Dipneusti','Actinopterygii') THEN 'Fish'
			WHEN ts.taxon_concept_class_name IN ('Holothuroidea','Arachnida','Insecta','Hirudinoidea','Bivalvia','Gastropoda','Cephalopoda') THEN 'Non-coral invertebrates'
			WHEN ts.taxon_concept_class_name IN ('Anthozoa','Hydrozoa') THEN 'Coral'
			WHEN ts.taxon_concept_genus_name IN ('Aquilaria','Pericopsis','Cedrela','GuaiaMTQ','Swietenia','Dalbergia','Prunus','Gonystylus','Diospyros','Abies','Guarea','Guibourtia','Gyrinops','Platymiscium','Pterocarpus','Taxus') THEN 'Plants (timber)'
			WHEN ts.taxon_concept_full_name IN ('Araucaria araucana','Fitzroya cupressoides','Abies guatemalensis','Pterocarpus santalinus','Pilgerodendron uviferum','Aniba rosaeodora','Caesalpinia echinata','Bulnesia sarmientoi','Dipteryx panamensis','Pinus koraiensis','Caryocar costaricense','Celtis aetnensis','Cynometra hemitomophylla','Magnolia liliifera','Oreomunnea pterocarpa','Osyris lanceolata','Pterygota excelsa','Tachigali versicolor') THEN 'Plants (timber)'
			WHEN ts.taxon_concept_class_name IS NULL AND (ts.taxon_concept_genus_name NOT IN ('Aquilaria','Pericopsis','Cedrela','Guaiacum','Swietenia','Dalbergia','Prunus','Gonystylus','Diospyros','Abies','Guarea','Guibourtia','Gyrinops','Platymiscium','Pterocarpus','Taxus')
      OR ts.taxon_concept_full_name NOT IN ('Araucaria araucana','Fitzroya cupressoides','Abies guatemalensis','Pterocarpus santalinus','Pilgerodendron uviferum','Aniba rosaeodora','Caesalpinia echinata','Bulnesia sarmientoi','Dipteryx panamensis','Pinus koraiensis','Caryocar costaricense','Celtis aetnensis','Cynometra hemitomophylla','Magnolia liliifera','Oreomunnea pterocarpa','Osyris lanceolata','Pterygota excelsa','Tachigali versicolor'))
      THEN 'Plants (other than timber)'
			END AS group_en,

      CASE 			WHEN ts.taxon_concept_class_name IN ('Mammalia') THEN 'Mamiferos'
			WHEN ts.taxon_concept_class_name IN ('Aves') THEN 'Aves'
			WHEN ts.taxon_concept_class_name IN ('Reptilia') THEN 'Reptiles'
			WHEN ts.taxon_concept_class_name IN ('Amphibia') THEN 'Anfibios'
			WHEN ts.taxon_concept_class_name IN ('Elasmobranchii','Actinopteri','Coelacanthi','Dipneusti','Actinopterygii') THEN 'Pez'
			WHEN ts.taxon_concept_class_name IN ('Holothuroidea','Arachnida','Insecta','Hirudinoidea','Bivalvia','Gastropoda','Cephalopoda') THEN 'Invertebrados no coralinos'
			WHEN ts.taxon_concept_class_name IN ('Anthozoa','Hydrozoa') THEN 'Coral'
			WHEN ts.taxon_concept_genus_name IN ('Aquilaria','Pericopsis','Cedrela','GuaiaMTQ','Swietenia','Dalbergia','Prunus','Gonystylus','Diospyros','Abies','Guarea','Guibourtia','Gyrinops','Platymiscium','Pterocarpus','Taxus') THEN 'Plantas (madera)'
			WHEN ts.taxon_concept_full_name IN ('Araucaria araucana','Fitzroya cupressoides','Abies guatemalensis','Pterocarpus santalinus','Pilgerodendron uviferum','Aniba rosaeodora','Caesalpinia echinata','Bulnesia sarmientoi','Dipteryx panamensis','Pinus koraiensis','Caryocar costaricense','Celtis aetnensis','Cynometra hemitomophylla','Magnolia liliifera','Oreomunnea pterocarpa','Osyris lanceolata','Pterygota excelsa','Tachigali versicolor') THEN 'Plantas (madera)'
			WHEN ts.taxon_concept_class_name IS NULL AND (ts.taxon_concept_genus_name NOT IN ('Aquilaria','Pericopsis','Cedrela','Guaiacum','Swietenia','Dalbergia','Prunus','Gonystylus','Diospyros','Abies','Guarea','Guibourtia','Gyrinops','Platymiscium','Pterocarpus','Taxus')
      OR ts.taxon_concept_full_name NOT IN ('Araucaria araucana','Fitzroya cupressoides','Abies guatemalensis','Pterocarpus santalinus','Pilgerodendron uviferum','Aniba rosaeodora','Caesalpinia echinata','Bulnesia sarmientoi','Dipteryx panamensis','Pinus koraiensis','Caryocar costaricense','Celtis aetnensis','Cynometra hemitomophylla','Magnolia liliifera','Oreomunnea pterocarpa','Osyris lanceolata','Pterygota excelsa','Tachigali versicolor'))
      THEN 'Plantas (otro que madera)'
			END AS group_es,

      CASE 			WHEN ts.taxon_concept_class_name IN ('Mammalia') THEN 'Mammifères'
			WHEN ts.taxon_concept_class_name IN ('Aves') THEN 'Oiseaux'
			WHEN ts.taxon_concept_class_name IN ('Reptilia') THEN 'Reptiles'
			WHEN ts.taxon_concept_class_name IN ('Amphibia') THEN 'Amphibiens'
			WHEN ts.taxon_concept_class_name IN ('Elasmobranchii','Actinopteri','Coelacanthi','Dipneusti','Actinopterygii') THEN 'Poissons'
			WHEN ts.taxon_concept_class_name IN ('Holothuroidea','Arachnida','Insecta','Hirudinoidea','Bivalvia','Gastropoda','Cephalopoda') THEN 'Invertébrés autres que les coraux'
			WHEN ts.taxon_concept_class_name IN ('Anthozoa','Hydrozoa') THEN 'Coraux'
			WHEN ts.taxon_concept_genus_name IN ('Aquilaria','Pericopsis','Cedrela','GuaiaMTQ','Swietenia','Dalbergia','Prunus','Gonystylus','Diospyros','Abies','Guarea','Guibourtia','Gyrinops','Platymiscium','Pterocarpus','Taxus') THEN 'Plantes (bois)'
			WHEN ts.taxon_concept_full_name IN ('Araucaria araucana','Fitzroya cupressoides','Abies guatemalensis','Pterocarpus santalinus','Pilgerodendron uviferum','Aniba rosaeodora','Caesalpinia echinata','Bulnesia sarmientoi','Dipteryx panamensis','Pinus koraiensis','Caryocar costaricense','Celtis aetnensis','Cynometra hemitomophylla','Magnolia liliifera','Oreomunnea pterocarpa','Osyris lanceolata','Pterygota excelsa','Tachigali versicolor') THEN 'Plantes (bois)'
			WHEN ts.taxon_concept_class_name IS NULL AND (ts.taxon_concept_genus_name NOT IN ('Aquilaria','Pericopsis','Cedrela','Guaiacum','Swietenia','Dalbergia','Prunus','Gonystylus','Diospyros','Abies','Guarea','Guibourtia','Gyrinops','Platymiscium','Pterocarpus','Taxus')
      OR ts.taxon_concept_full_name NOT IN ('Araucaria araucana','Fitzroya cupressoides','Abies guatemalensis','Pterocarpus santalinus','Pilgerodendron uviferum','Aniba rosaeodora','Caesalpinia echinata','Bulnesia sarmientoi','Dipteryx panamensis','Pinus koraiensis','Caryocar costaricense','Celtis aetnensis','Cynometra hemitomophylla','Magnolia liliifera','Oreomunnea pterocarpa','Osyris lanceolata','Pterygota excelsa','Tachigali versicolor'))
      THEN 'Plantes (autres que le bois)'
			END AS group_fr,

      -- mapping Taiwan trades to China trades, so that they appear as the same country on Tradeplus
      CASE WHEN ts.importer_id = 218 THEN 160
      ELSE ts.importer_id
      END AS china_importer_id,
      CASE WHEN ts.exporter_id = 218 THEN 160
      ELSE ts.exporter_id
      END AS china_exporter_id,
      CASE WHEN ts.country_of_origin_id = 218 THEN 160
      ELSE ts.country_of_origin_id
      END AS china_origin_id
    FROM trade_plus_shipments_view ts
