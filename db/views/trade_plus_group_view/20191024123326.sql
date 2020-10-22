    SELECT
      ts.*,
      CASE 			WHEN ts.taxon_concept_class_name IN ('Mammalia') THEN 'Mammals'
			WHEN ts.taxon_concept_class_name IN ('Aves') THEN 'Birds'
			WHEN ts.taxon_concept_class_name IN ('Reptilia') THEN 'Reptiles'
			WHEN ts.taxon_concept_class_name IN ('Amphibia') THEN 'Amphibians'
			WHEN ts.taxon_concept_class_name IN ('Elasmobranchii','Actinopteri','Coelacanthi','Dipneusti','Actinopterygii') THEN 'Fish'
			WHEN ts.taxon_concept_class_name IN ('Holothuroidea','Arachnida','Insecta','Hirudinoidea','Bivalvia','Gastropoda') THEN 'Non-coral invertebrates'
			WHEN ts.taxon_concept_class_name IN ('Anthozoa','Hydrozoa') THEN 'Coral'
			WHEN ts.taxon_concept_genus_name IN ('Aquilaria','Pericopsis','Cedrela','Guaiacum','Swietenia','Dalbergia','Prunus','Gonystylus','Diospyros','Abies','Guarea','Guibourtia','Gyrinops','Platymiscium','Pterocarpus','Taxus') THEN 'Timber'
			WHEN ts.taxon_concept_full_name IN ('Araucaria araucana','Fitzroya cupressoides','Abies guatemalensis','Pterocarpus santalinus','Pilgerodendron uviferum','Aniba rosaeodora','Caesalpinia echinata','Bulnesia sarmientoi','Dipteryx panamensis','Pinus koraiensis','Caryocar costaricense','Celtis aetnensis','Cynometra hemitomophylla','Magnolia liliifera','Oreomunnea pterocarpa','Osyris lanceolata','Pterygota excelsa','Tachigali versicolor') THEN 'Timber'
			WHEN ts.taxon_concept_class_name IS NULL AND (ts.taxon_concept_genus_name NOT IN ('Aquilaria','Pericopsis','Cedrela','Guaiacum','Swietenia','Dalbergia','Prunus','Gonystylus','Diospyros','Abies','Guarea','Guibourtia','Gyrinops','Platymiscium','Pterocarpus','Taxus')
      OR ts.taxon_concept_full_name NOT IN ('Araucaria araucana','Fitzroya cupressoides','Abies guatemalensis','Pterocarpus santalinus','Pilgerodendron uviferum','Aniba rosaeodora','Caesalpinia echinata','Bulnesia sarmientoi','Dipteryx panamensis','Pinus koraiensis','Caryocar costaricense','Celtis aetnensis','Cynometra hemitomophylla','Magnolia liliifera','Oreomunnea pterocarpa','Osyris lanceolata','Pterygota excelsa','Tachigali versicolor'))
      THEN 'Plants'
			END AS group
    FROM trade_shipments_with_taxa_view ts
