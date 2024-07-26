SELECT
  ts.*,
  tg.trade_taxon_group_code    AS group_code,
  tg.trade_taxon_group_name_en AS group_en,
  tg.trade_taxon_group_name_es AS group_es,
  tg.trade_taxon_group_name_fr AS group_fr,
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
LEFT JOIN taxon_trade_taxon_groups_view tg ON ts.taxon_concept_id = tg.taxon_concept_id