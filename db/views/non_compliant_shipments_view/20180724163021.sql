SELECT id, year, appendix, importer, importer_iso, exporter, exporter_iso,
       term, unit, purpose, source, taxon, genus, family, class, issue_type

FROM trade_shipments_appendix_i_mview

UNION ALL

SELECT id, year, appendix, importer, importer_iso, exporter, exporter_iso,
       term, unit, purpose, source, taxon, genus, family, class, issue_type
FROM trade_shipments_mandatory_quotas_mview

UNION ALL

SELECT id, year, appendix, importer, importer_iso, exporter, exporter_iso,
       term, unit, purpose, source, taxon, genus, family, class, issue_type
FROM trade_shipments_cites_suspensions_mview
