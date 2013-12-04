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
    END AS reporter_type
    , created_at
    , updated_at

FROM
  (SELECT name_en,
          year,
          SUM(type),
          created_at,
          updated_at
   FROM
     (SELECT DISTINCT name_en,
                      year,
                      1 AS type,
                      t.created_at,
                      t.updated_at
      FROM trade_shipments t 
      LEFT JOIN geo_entities g ON t.exporter_id = g.id
      WHERE t.reported_by_exporter = 't'
      UNION ALL SELECT DISTINCT name_en,
                                year,
                                -1 AS type,
                                t.created_at,
                                t.updated_at
      FROM trade_shipments t
      LEFT JOIN geo_entities g ON t.importer_id = g.id
      WHERE t.reported_by_exporter = 'f') a
   GROUP BY a.name_en
            , a.year
            , a.created_at
            , a.updated_at) b ;
