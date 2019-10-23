SELECT DISTINCT *
FROM(
    SELECT ts.*,
           ts.term_imp_exp_unit[1] AS term_code,
           ts.term_imp_exp_unit[2] AS importer_reported_quantity,
           ts.term_imp_exp_unit[3] AS exporter_reported_quantity,
           ts.term_imp_exp_unit[4] AS unit_code
           -- terms.id AS term_id,
           -- terms.name_en AS term,
           -- units.id AS unit_id,
           -- units.name_en AS unit
    FROM trade_plus_with_taxa_view ts
  ) AS s
