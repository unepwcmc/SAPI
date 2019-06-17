class NomenclatureChange::TradeShipmentsResolver

  def initialize(taxon_relationship, old_taxon_relationship)
    @taxon_relationship = taxon_relationship
    @old_taxon_relationship = old_taxon_relationship
  end

  # update all shipments where reported name now resolves to a new accepted name
  def process
    Trade::Shipment.where(taxon_concept_id: @old_taxon_relationship.taxon_concept_id,
                          reported_taxon_concept_id: @taxon_relationship.other_taxon_concept_id)
                   .update_all(taxon_concept_id: @taxon_relationship.taxon_concept_id)
  end

end
