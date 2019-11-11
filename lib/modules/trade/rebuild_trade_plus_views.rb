module Trade::RebuildTradePlusViews
  def self.run
    time = "#{Time.now.hour}#{Time.now.min}#{Time.now.sec}"
    timestamp = Date.today.to_s.gsub('-', '') + time
    puts "Rebuild group SQL view..."
    self.rebuild_sql_views(:group, timestamp)
    self.rebuild_trade_plus_view(:group)
    puts "Rebuild trade codes SQL view..."
    self.rebuild_sql_views(:trade_codes, timestamp)
    self.rebuild_trade_plus_view(:formatted_data)
  end

  def self.rebuild_sql_views(type, timestamp)
    view_type =
      case type
      when :group then Trade::TradePlusGroupView
      when :trade_codes then Trade::TradePlusFormattedCodes
      end
    view_type.new.generate_view(timestamp)
  end

  def self.rebuild_trade_plus_view(type)
    views = Dir["db/views/trade_plus_#{type}_view/*"]
    latest_view = views.map { |v| v.split("/").last }.sort.last.split('.').first
    self.recreate_view(type, latest_view)
  end

  def self.recreate_view(type, sql_view)
    view_name = "trade_plus_#{type}_view"
    ActiveRecord::Base.transaction do
      command = "DROP VIEW IF EXISTS #{view_name} CASCADE"
      puts command
      db.execute(command)

      command = "CREATE VIEW #{view_name} AS #{ActiveRecord::Migration.view_sql(sql_view, view_name)}"
      puts command
      db.execute(command)
    end
  end

  def self.db
    ActiveRecord::Base.connection
  end
end
