class DashboardStatsSerializer < ActiveModel::Serializer
  cached

  attributes :species, :trade

  def cache_key
    key = [
      self.class.name,
      @object.geo_entity.id,
      @object.kingdom,
      @object.trade_limit
    ]
    Rails.logger.debug "CACHE KEY: #{key.inspect}"
    key
  end
end