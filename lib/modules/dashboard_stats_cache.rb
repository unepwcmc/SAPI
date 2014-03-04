module DashboardStatsCache

  def self.update_dashboard_stats
    puts "Updating Dashboard Stats"
    DashboardStatsSerializer.cache.clear
    countries = GeoEntity.where(:geo_entity_type_id => 1)
    countries.each do |country|
      stats = DashboardStats.new(country, 'Animalia', 6)
      DashboardStatsSerializer.new(stats).serializable_hash
    end
  end
end
