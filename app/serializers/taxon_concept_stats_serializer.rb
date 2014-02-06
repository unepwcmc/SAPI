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
      @object.getGeoEntity.id,
      @object.getKingdom
    ]
    Rails.logger.debug "CACHE KEY: #{key.inspect}"
    key
  end
end