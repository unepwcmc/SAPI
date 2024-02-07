##
#
# This module can be invoked via either:
#
# ```
# $ bundle exec rake db:trade_plus:rebuild
# irb> Trade::RebuildTradePlusViews.run
# ```
#
# The module uses the data in `lib/data/trade_mapping.yml` to rebuild the views
#
# - trade_plus_formatted_data_view and
# - trade_plus_formatted_data_final_view
#
# In the long term it would surely be better if the yml file were simply
# read into the db, and referenced from the view, which then would not need to
# change, rather than hard-coding the values into the view.
#
# Once completed, two new files will be added, with datestamps in `db/views/`.
# You will then need to:
#
# - Check the two files into git
# - Create a migration to apply them. See the migration named
#   `UpdateConversionRulesForTradePlusFormattedDataView` for an example.

module Trade::RebuildTradePlusViews
  def self.run
    time = "#{Time.now.hour}#{Time.now.min}#{Time.now.sec}"
    timestamp = Date.today.to_s.gsub('-', '') + time
    # WARNING: localisation manually added to the group view, so if you want to recreate the group view using this script, localisation will be lost
    # puts "Rebuild group SQL view..."
    # self.rebuild_sql_views(:group, timestamp)
    # self.rebuild_trade_plus_view(:group)
    puts "Rebuild trade codes SQL views..."
    self.rebuild_sql_views(:trade_codes, timestamp)
    self.rebuild_sql_views(:final_trade_codes, timestamp)
    self.rebuild_trade_plus_view(:formatted_data)
    self.rebuild_trade_plus_view(:formatted_data_final)
  end

  def self.rebuild_sql_views(type, timestamp)
    view_type =
      case type
      when :group then Trade::TradePlusGroupView
      when :trade_codes then Trade::FormattedCodes::TradePlusFormattedCodes
      when :final_trade_codes then Trade::FormattedCodes::TradePlusFormattedFinalCodes
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
    ApplicationRecord.transaction do
      command = "DROP VIEW IF EXISTS #{view_name} CASCADE"
      puts command
      db.execute(command)

      command = "CREATE VIEW #{view_name} AS #{ActiveRecord::Migration.view_sql(sql_view, view_name)}"
      puts command
      db.execute(command)
    end
  end

  def self.db
    ApplicationRecord.connection
  end
end
