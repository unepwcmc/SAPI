module DashboardStatsCache

  def self.update_dashboard_stats
    puts "Updating Dashboard Stats"
    DashboardStatsSerializer.cache.clear
    countries = GeoEntity.where(:is_current => true).joins(:geo_entity_type).
      where("geo_entity_types.name in ('COUNTRY','TERRITORY')")
    countries.each do |country|
      stats = DashboardStats.new(country, 'Animalia', 6)
      DashboardStatsSerializer.new(stats).serializable_hash
    end
  end
end
