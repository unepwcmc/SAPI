WITH regulation_applicability_periods AS (
SELECT DISTINCT effective_at, end_date
FROM events
WHERE type = 'EuRegulation' AND effective_at >= '1997-06-01'
ORDER BY effective_at, end_date
), overlapping (start_date, end_date) AS (
SELECT outer_i.effective_at,
CASE WHEN inner_i.effective_at = outer_i.effective_at
THEN inner_i.end_date ELSE inner_i.effective_at END
FROM regulation_applicability_periods outer_i
JOIN regulation_applicability_periods inner_i
ON outer_i.effective_at < inner_i.effective_at
AND outer_i.end_date = inner_i.end_date
ORDER BY inner_i.effective_at
), non_overlapping (start_date, end_date) AS (
SELECT outer_i.effective_at, outer_i.end_date
FROM regulation_applicability_periods outer_i
LEFT JOIN regulation_applicability_periods inner_i
ON outer_i.effective_at < inner_i.effective_at
AND outer_i.end_date = inner_i.end_date
WHERE inner_i.effective_at IS NULL
), intervals (start_date, end_date) AS (
  SELECT start_date, MIN(end_date) FROM (
    SELECT * FROM overlapping
    UNION
    SELECT * FROM non_overlapping
  ) i GROUP BY start_date
)
SELECT intervals.start_date::DATE, intervals.end_date::DATE,
ARRAY_AGG(events.id) AS events_ids
FROM intervals
JOIN events
ON events.type = 'EuRegulation'
AND events.effective_at <= intervals.start_date
AND (
  events.end_date >= intervals.end_date
  OR events.end_date IS NULL
)
GROUP BY intervals.start_date, intervals.end_date
ORDER BY intervals.start_date;
