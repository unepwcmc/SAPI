class TaxonConceptStatsSerializer < ActiveModel::Serializer
  cached

  attributes :species, :trade

  def cache_key
    key = [
      self.class.name,
      Distribution.count,
      TaxonConcept.count,
      ListingChange.count,
      ListingDistribution.count,
      Trade::Shipment.count,
      @object.get_geo_entity.id,
      @object.get_kingdom
    ]
    Rails.logger.debug "CACHE KEY: #{key.inspect}"
    key
  end
end