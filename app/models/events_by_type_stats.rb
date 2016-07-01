class EventsByTypeStats

  def initialize(start_date, end_date)
    @start_date = start_date
    @end_date = end_date
  end

  def data
    Ahoy::Event.from(<<-SQL
      (
        WITH weeks_as_timestamps AS (
          SELECT * FROM generate_series(
            '#{@start_date}'::timestamp,
            '#{@end_date}'::timestamp,
            '1 week'
          )
        ), weeks_as_dates AS (
          SELECT
            generate_series::date AS start_date,
            generate_series::date + 7 AS end_date
          FROM weeks_as_timestamps
        )
        SELECT start_date,
        SUM(CASE WHEN name = 'Taxon Concept' THEN 1 ELSE 0 END) AS taxon_concept_cnt,
        SUM(CASE WHEN name = 'Search' THEN 1 ELSE 0 END) AS search_cnt
        FROM weeks_as_dates w
        LEFT JOIN ahoy_events
          ON w.start_date <= ahoy_events.time
          AND w.end_date > ahoy_events.time
        GROUP BY start_date
        ORDER BY start_date
      ) q
      SQL
    ).select([:start_date, :taxon_concept_cnt, :search_cnt])
  end
end
