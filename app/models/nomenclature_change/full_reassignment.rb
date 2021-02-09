class NomenclatureChange::FullReassignment

  def initialize(old_taxon_concept, new_taxon_concept)
    @old_taxon_concept = old_taxon_concept
    @new_taxon_concept = new_taxon_concept
  end

  def process
    Rails.logger.debug "FULL REASSIGNMENT #{@old_taxon_concept.full_name} to #{@new_taxon_concept.full_name}"
    update_timestamp = Time.now
    update_attrs = {
      taxon_concept_id: @new_taxon_concept.id,
      updated_at: update_timestamp,
      updated_by_id: nil
    }
    # distributions
    Rails.logger.debug "FULL REASSIGNMENT Distributions (#{@old_taxon_concept.distributions.count})"
    @old_taxon_concept.distributions.update_all(update_attrs)
    # references
    Rails.logger.debug "FULL REASSIGNMENT References (#{@old_taxon_concept.taxon_concept_references.count})"
    @old_taxon_concept.taxon_concept_references.update_all(update_attrs)
    # listing changes
    Rails.logger.debug "FULL REASSIGNMENT Listing Changes (#{@old_taxon_concept.listing_changes.count})"
    @old_taxon_concept.listing_changes.update_all(update_attrs)
    # EU opinions
    Rails.logger.debug "FULL REASSIGNMENT EU Opinions (#{@old_taxon_concept.eu_opinions.count})"
    @old_taxon_concept.eu_opinions.update_all(update_attrs)
    # EU suspensions
    Rails.logger.debug "FULL REASSIGNMENT EU Suspensions (#{@old_taxon_concept.eu_suspensions.count})"
    @old_taxon_concept.eu_suspensions.update_all(update_attrs)
    # CITES quotas
    Rails.logger.debug "FULL REASSIGNMENT CITES Quotas (#{@old_taxon_concept.quotas.count})"
    @old_taxon_concept.quotas.update_all(update_attrs)
    # CITES suspensions
    Rails.logger.debug "FULL REASSIGNMENT CITES Suspensions (#{@old_taxon_concept.cites_suspensions.count})"
    @old_taxon_concept.cites_suspensions.update_all(update_attrs)
    # common names
    Rails.logger.debug "FULL REASSIGNMENT Common names (#{@old_taxon_concept.taxon_commons.count})"
    @old_taxon_concept.taxon_commons.update_all(update_attrs)
    # document citations
    Rails.logger.debug "FULL REASSIGNMENT Document Citations (#{@old_taxon_concept.document_citation_taxon_concepts.count})"
    # need validations to be applied to avoid duplicates exception
    @old_taxon_concept.document_citation_taxon_concepts.each do |dctc|
      dctc.update_attributes(update_attrs)
    end
    # shipments
    Rails.logger.debug "FULL REASSIGNMENT Shipments"
    Trade::Shipment.where(taxon_concept_id: @old_taxon_concept.id).update_all(update_attrs)
    @old_taxon_concept.update_attributes(dependents_updated_at: update_timestamp)
    @old_taxon_concept.reload
    @new_taxon_concept.update_attributes(dependents_updated_at: update_timestamp)
  end

end
