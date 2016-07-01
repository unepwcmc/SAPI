module DashboardStatsCache

  def self.update_dashboard_stats
    puts "Updating Dashboard Stats"
    DashboardStatsSerializer.cache.clear
    countries = GeoEntity.where(:is_current => true).joins(:geo_entity_type).
      where("geo_entity_types.name in ('COUNTRY','TERRITORY')")
    countries.each do |country|
      puts "Warming up #{country.name_en}"
      stats = DashboardStats.new(country, { :kingdom => 'Animalia', :trade_limit => 6,
        :time_range_start => Time.now.year - 7, :time_range_end => Time.now.year - 2 })
      DashboardStatsSerializer.new(stats).serializable_hash
    end
  end
end
