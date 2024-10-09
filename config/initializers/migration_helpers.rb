# http://pivotallabs.com/rails-and-sql-views-part-2-migrations/
ActiveRecord::Migration.class_eval do
  def view_sql(timestamp, view)
    Rails.root.join("db/views/#{view}/#{timestamp}.sql").read
  end

  def function_sql(timestamp, function)
    Rails.root.join("db/functions/#{function}/#{timestamp}.sql").read
  end
end
