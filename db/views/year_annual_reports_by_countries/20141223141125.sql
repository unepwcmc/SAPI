SELECT
  row_number() OVER (ORDER BY b.name_en, b.year DESC) AS no,
  b.name_en,
  b.year,
  CASE
    WHEN b.sum = 0 THEN 'I/E'::text
    WHEN b.sum = 1 THEN 'E'::text
    WHEN b.sum = (-1) THEN 'I'::text
  END AS reporter_type,
  b.year_created
FROM (
  SELECT a.name_en, a.year, sum(a.type) AS sum, a.year_created
  FROM (
    SELECT DISTINCT g.name_en, t.year, 1 AS type,
    date_part('year'::text, t.created_at) AS year_created
    FROM trade_shipments t
    LEFT JOIN geo_entities g ON t.exporter_id = g.id
    WHERE t.reported_by_exporter = true
    UNION ALL
    SELECT DISTINCT g.name_en, t.year, (-1) AS type,
    date_part('year'::text, t.created_at) AS year_created
    FROM trade_shipments t
    LEFT JOIN geo_entities g ON t.importer_id = g.id
    WHERE t.reported_by_exporter = false
  ) a
  GROUP BY a.name_en, a.year, a.year_created
) b;
