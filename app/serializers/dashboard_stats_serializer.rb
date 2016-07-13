class DashboardStatsSerializer < ActiveModel::Serializer
  cached

  attributes :species, :trade, :meta

  def meta
    {
      :trade => {
        :country_of_origin_id => nil,
        :term => "LIV",
        :unit => nil,
        :source => "W"
      },
      :species => {
        :cites_listed => 'IS NOT NULL'
      }
    }
  end

  def cache_key
    key = [
      self.class.name,
      @object.geo_entity.id,
      @object.kingdom,
      @object.trade_limit,
      @object.time_range_start,
      @object.time_range_end
    ]
    Rails.logger.debug "CACHE KEY: #{key.inspect}"
    key
  end
end
