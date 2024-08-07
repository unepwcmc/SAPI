SELECT
  ts.*,
  tg.trade_taxon_group_code    AS group_code,
  tg.trade_taxon_group_name_en AS group_en,
  tg.trade_taxon_group_name_es AS group_es,
  tg.trade_taxon_group_name_fr AS group_fr
FROM trade_plus_shipments_view ts
LEFT JOIN taxon_trade_taxon_groups_view tg
  ON ts.taxon_concept_id = tg.taxon_concept_id