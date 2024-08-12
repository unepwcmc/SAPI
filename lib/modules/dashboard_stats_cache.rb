module DashboardStatsCache
  def self.update_dashboard_stats
    Rails.logger.debug 'Updating Dashboard Stats'
    DashboardStatsSerializer.cache.clear
    countries = GeoEntity.where(is_current: true).joins(:geo_entity_type).
      where("geo_entity_types.name in ('COUNTRY','TERRITORY')")
    countries.each do |country|
      Rails.logger.debug { "Warming up #{country.name_en}" }
      stats = DashboardStats.new(country, { kingdom: 'Animalia', trade_limit: 6,
        time_range_start: Time.zone.now.year - 7, time_range_end: Time.zone.now.year - 2 })
      DashboardStatsSerializer.new(stats).serializable_hash
    end
  end
end
