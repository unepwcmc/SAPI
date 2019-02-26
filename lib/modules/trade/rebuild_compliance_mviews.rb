module Trade::RebuildComplianceMviews
  def self.run
    [
      :appendix_i,
      :mandatory_quotas,
      :cites_suspensions
    ].each do |p|
      puts "Rebuild #{p} mview..."
      self.rebuild_compliance_mview(p)
    end
  end

  def self.rebuild_compliance_mview(type)
    views = Dir["db/views/trade_shipments_#{type}_view/*"]
    latest_view = views.map { |v| v.split("/").last }.sort.last.split('.').first
    self.recreate_mview(type, latest_view)
  end

  def self.recreate_mview(type, sql_view)
    view_name = "trade_shipments_#{type}_view"
    mview_name = "trade_shipments_#{type}_mview"
    ActiveRecord::Base.transaction do
      command = "DROP MATERIALIZED VIEW IF EXISTS #{mview_name} CASCADE"
      puts command
      puts db.execute(command)

      command = "DROP VIEW IF EXISTS #{view_name}"
      puts command
      db.execute(command)

      command = "CREATE VIEW #{view_name} AS #{ActiveRecord::Migration.view_sql(sql_view, view_name)}"
      puts command
      db.execute(command)

      command = "CREATE MATERIALIZED VIEW #{mview_name} AS SELECT * FROM #{view_name}"
      puts command
      db.execute(command)
    end
  end

  def self.db
    ActiveRecord::Base.connection
  end
end
