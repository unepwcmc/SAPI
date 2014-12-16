class NomenclatureChange::FullReassignment

  def initialize(old_taxon_concept, new_taxon_concept)
    @old_taxon_concept = old_taxon_concept
    @new_taxon_concept = new_taxon_concept
  end

  def process
    update_attrs = {
      taxon_concept_id: @new_taxon_concept.id
    }
    # distributions
    @old_taxon_concept.distributions.each do |d|
      d.update_attributes(update_attrs)
    end
    # references
    @old_taxon_concept.taxon_concept_references.each do |tcr|
      tcr.update_attributes(update_attrs)
    end
    # listing changes
    @old_taxon_concept.listing_changes.each do |lc|
      lc.update_attributes(update_attrs)
    end
    # EU opinions
    @old_taxon_concept.eu_opinions.each do |ed|
      ed.update_attributes(update_attrs)
    end
    # EU suspensions
    @old_taxon_concept.eu_suspensions.each do |ed|
      ed.update_attributes(update_attrs)
    end
    # CITES quotas
    @old_taxon_concept.quotas do |tr|
      tr.update_attributes(update_attrs)
    end
    # CITES suspensions
    @old_taxon_concept.cites_suspensions do |tr|
      tr.update_attributes(update_attrs)
    end
    # common names
    @old_taxon_concept.taxon_commons do |tc|
      tc.update_attributes(update_attrs)
    end
    # shipments
    Rails.logger.debug "Updating shipments where taxon concept = #{@old_taxon_concept.full_name} to have taxon concept = #{@new_taxon_concept.full_name}"
    Trade::Shipment.update_all(
      update_attrs,
      {taxon_concept_id: @old_taxon_concept.id}
    )
  end

end
