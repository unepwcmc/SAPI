SELECT taxon_commons.id, taxon_concept_id, languages.iso_code1, common_names.name
FROM taxon_commons
JOIN common_names ON common_names.id = taxon_commons.common_name_id
JOIN languages ON languages.id = common_names.language_id;
