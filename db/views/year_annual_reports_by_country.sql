DROP VIEW IF EXISTS year_annual_reports_by_countries;
CREATE VIEW year_annual_reports_by_countries AS
SELECT ROW_NUMBER() OVER (
                          ORDER BY name_en ASC, year DESC) AS no
    , name_en
    , year
    , CASE
           WHEN SUM = 0 THEN 'I/E'
           WHEN SUM = 1 THEN 'E'
           WHEN SUM = -1 THEN 'I'
    END AS type
FROM
  (SELECT name_en,
          year,
          SUM(type)
   FROM
     (SELECT DISTINCT name_en,
                      year,
                      1 AS type
      FROM trade_shipments
      LEFT JOIN geo_entities ON trade_shipments.exporter_id = geo_entities.id
      WHERE trade_shipments.reported_by_exporter = 't'
      UNION ALL SELECT DISTINCT name_en,
                                year,
                                -1 AS type
      FROM trade_shipments
      LEFT JOIN geo_entities ON trade_shipments.importer_id = geo_entities.id
      WHERE trade_shipments.reported_by_exporter = 'f') a
   GROUP BY a.name_en,
            a.year) b ;
