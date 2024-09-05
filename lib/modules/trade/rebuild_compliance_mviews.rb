module Trade::RebuildComplianceMviews
  def self.run
    Rails.logger.debug 'Trade::RebuildComplianceMviews.run starting'

    [
      :appendix_i,
      :mandatory_quotas,
      :cites_suspensions
    ].each do |p|
      time = "#{Time.now.hour}#{Time.now.min}#{Time.now.sec}"
      timestamp = Date.today.to_s.gsub('-', '') + time

      Rails.logger.debug { "Rebuild #{p} SQL script..." }

      self.rebuild_sql_views(p, timestamp)

      Rails.logger.debug { "Rebuild #{p} mview..." }

      self.rebuild_compliance_mview(p)
    end

    recreate_non_compliant_view

    Rails.logger.debug 'Trade::RebuildComplianceMviews.run complete'
  end

  def self.rebuild_sql_views(type, timestamp)
    compliance_type =
      case type
      when :appendix_i then Trade::AppendixIReservationsShipments
      when :mandatory_quotas then Trade::MandatoryQuotasShipments
      when :cites_suspensions then Trade::CitesSuspensionsShipments
      end
    compliance_type.new.generate_view(timestamp)
  end

  def self.rebuild_compliance_mview(type)
    views = Dir["db/views/trade_shipments_#{type}_view/*"]
    latest_view = views.map { |v| v.split('/').last }.sort.last.split('.').first

    self.recreate_mview(type, latest_view)
  end

  def self.recreate_mview(type, sql_view)
    view_name = "trade_shipments_#{type}_view"
    mview_name = "trade_shipments_#{type}_mview"

    ApplicationRecord.transaction do
      command = "DROP MATERIALIZED VIEW IF EXISTS #{mview_name} CASCADE"

      Rails.logger.debug command
      Rails.logger.debug db.execute(command)

      command = "DROP VIEW IF EXISTS #{view_name}"

      Rails.logger.debug command
      db.execute(command)

      command = "CREATE VIEW #{view_name} AS #{ActiveRecord::Migration.view_sql(sql_view, view_name)}"

      Rails.logger.debug command
      db.execute(command)

      command = "CREATE MATERIALIZED VIEW #{mview_name} AS SELECT * FROM #{view_name}"

      Rails.logger.debug command
      db.execute(command)
    end
  end

  def self.recreate_non_compliant_view
    command = 'SELECT rebuild_non_compliant_shipments_view()'
    Rails.logger.debug command
    db.execute(command)
  end

  def self.db
    ApplicationRecord.connection
  end
end
