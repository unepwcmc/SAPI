class TaxonConceptStatsSerializer < ActiveModel::Serializer
  cached

  attributes :species, :trade

  def cache_key
    key = [
      self.class.name,
      @object.get_geo_entity.id,
      @object.get_kingdom,
      @object.get_trade_limit
    ]
    Rails.logger.debug "CACHE KEY: #{key.inspect}"
    key
  end
end