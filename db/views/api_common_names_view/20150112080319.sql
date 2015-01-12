SELECT
  taxon_commons.id,
  taxon_concept_id,
  languages.iso_code1,
  languages.name_en AS language_name_en,
  languages.name_es AS language_name_es,
  languages.name_fr AS language_name_fr,
  common_names.name
FROM taxon_commons
JOIN common_names ON common_names.id = taxon_commons.common_name_id
JOIN languages ON languages.id = common_names.language_id;
