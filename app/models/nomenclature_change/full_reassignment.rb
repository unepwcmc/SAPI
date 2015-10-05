class NomenclatureChange::FullReassignment

  def initialize(old_taxon_concept, new_taxon_concept)
    @old_taxon_concept = old_taxon_concept
    @new_taxon_concept = new_taxon_concept
  end

  def process
    Rails.logger.debug "FULL REASSIGNMENT #{@old_taxon_concept.full_name} to #{@new_taxon_concept.full_name}"
    update_attrs = {
      taxon_concept_id: @new_taxon_concept.id
    }
    # distributions
    Rails.logger.debug "FULL REASSIGNMENT Distributions (#{@old_taxon_concept.distributions.count})"
    @old_taxon_concept.distributions.each do |d|
      d.update_attributes(update_attrs)
    end
    # references
    Rails.logger.debug "FULL REASSIGNMENT References (#{@old_taxon_concept.taxon_concept_references.count})"
    @old_taxon_concept.taxon_concept_references.each do |tcr|
      tcr.update_attributes(update_attrs)
    end
    # listing changes
    Rails.logger.debug "FULL REASSIGNMENT Listing Changes (#{@old_taxon_concept.listing_changes.count})"
    @old_taxon_concept.listing_changes.each do |lc|
      lc.update_attributes(update_attrs)
    end
    # EU opinions
    Rails.logger.debug "FULL REASSIGNMENT EU Opinions (#{@old_taxon_concept.eu_opinions.count})"
    @old_taxon_concept.eu_opinions.each do |ed|
      ed.update_attributes(update_attrs)
    end
    # EU suspensions
    Rails.logger.debug "FULL REASSIGNMENT EU Suspensions (#{@old_taxon_concept.eu_suspensions.count})"
    @old_taxon_concept.eu_suspensions.each do |ed|
      ed.update_attributes(update_attrs)
    end
    # CITES quotas
    Rails.logger.debug "FULL REASSIGNMENT CITES Quotas (#{@old_taxon_concept.quotas.count})"
    @old_taxon_concept.quotas.each do |tr|
      tr.update_attributes(update_attrs)
    end
    # CITES suspensions
    Rails.logger.debug "FULL REASSIGNMENT CITES Suspensions (#{@old_taxon_concept.cites_suspensions.count})"
    @old_taxon_concept.cites_suspensions.each do |tr|
      tr.update_attributes(update_attrs)
    end
    # common names
    Rails.logger.debug "FULL REASSIGNMENT Common names (#{@old_taxon_concept.taxon_commons.count})"
    @old_taxon_concept.taxon_commons.each do |tc|
      tc.update_attributes(update_attrs)
    end
    # shipments
    Rails.logger.debug "FULL REASSIGNMENT Shipments"
    Trade::Shipment.update_all(
      update_attrs,
      {taxon_concept_id: @old_taxon_concept.id}
    )
  end

end
