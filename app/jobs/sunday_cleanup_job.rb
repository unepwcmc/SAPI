class SundayCleanupJob < ApplicationJob
  queue_as :admin

  def perform(*args)
    # rake "dashboard_stats:cache:update"
    DashboardStatsCache.update_dashboard_stats

    # rake "db:common_names:cleanup"
    Rails.logger.warn '### rake db:common_names:cleanup'

    objects_to_delete = CommonName.where.missing(:taxon_commons)

    Rails.logger.warn "Going to delete #{objects_to_delete.count} common names"

    sql = <<-SQL.squish
      WITH objects_to_delete AS (
        #{objects_to_delete.to_sql}
      )
      DELETE FROM common_names
      USING objects_to_delete
      WHERE common_names.id = objects_to_delete.id
    SQL

    ApplicationRecord.connection.execute sql

    # rake "db:taxon_names:cleanup"
    Rails.logger.warn '### rake db:taxon_names:cleanup'

    objects_to_delete = TaxonName.where.missing(:taxon_concepts)

    Rails.logger.warn "Going to delete #{objects_to_delete.count} taxon names"

    sql = <<-SQL.squish
      WITH objects_to_delete AS (
        #{objects_to_delete.to_sql}
      )
      DELETE FROM taxon_names
      USING objects_to_delete
      WHERE taxon_names.id = objects_to_delete.id
    SQL

    ApplicationRecord.connection.execute sql
  end
end
