task :map_eu_suspensions_to_terminating_regulations => :environment do
  update_query = <<-SQL
  WITH suspension_regulations AS (
    SELECT events1.id, events1.name, events1.effective_at, events2.id AS end_event_id, events2.name, events2.effective_at
    FROM events events1
    JOIN events events2
    ON events1.type = events2.type AND events1.end_date = events2.effective_at
    WHERE events1.type = 'EuSuspensionRegulation'
  ), eu_suspensions_without_end_event AS (
    SELECT *
    FROM eu_decisions
    WHERE type = 'EuSuspension' AND end_event_id IS NULL AND NOT is_current
  )
  UPDATE eu_decisions
  SET end_event_id = suspension_regulations.end_event_id
  FROM suspension_regulations
  WHERE suspension_regulations.id = eu_decisions.start_event_id
  RETURNING *;
  SQL
  res = ActiveRecord::Base.connection.execute update_query
  puts "#{res.cmd_tuples} rows linked to terminating EU Suspension Regulations"
end
