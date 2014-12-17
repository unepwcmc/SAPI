class NomenclatureChange::ReassignmentCopyProcessor < NomenclatureChange::ReassignmentProcessor

  def process_reassignment(reassignment, reassignable)
    o = copied_object_before_save(reassignment, reassignable)
    o.save(validate: false) # hope that saves the duplicated associations as well
    if o.is_a?(TaxonConcept)
      resolver = NomenclatureChange::TaxonomicTreeNameResolver.new(o)
      resolver.process
    end
    o
  end

  def copied_object_before_save(reassignment, reassignable)
    new_taxon_concept = @output.new_taxon_concept || @output.taxon_concept
    Rails.logger.debug("Processing #{reassignable.class} #{reassignable.id} copy to #{new_taxon_concept.full_name}")
    if reassignment.kind_of?(NomenclatureChange::ParentReassignment)
      reassignable.parent_id = new_taxon_concept.id
      reassignable
    elsif reassignable.kind_of?(Trade::Shipment)
      reassignable.taxon_concept_id = new_taxon_concept.id
      reassignable
    elsif reassignable.is_a?(TaxonRelationship) &&
      reassignable.taxon_relationship_type.name == TaxonRelationshipType::HAS_TRADE_NAME

      reassignable.taxon_concept_id = new_taxon_concept.id
      reassignable
    else
      # Each reassignable object implements find_duplicate,
      # which is called from here to make sure we're not adding a duplicate.
      copied_object = reassignable.duplicates({
        taxon_concept_id: new_taxon_concept.id
      }).first || reassignable.dup
      copied_object.taxon_concept_id = new_taxon_concept.id
      if reassignable.kind_of? ListingChange
        copied_object.inclusion_taxon_concept_id = nil
      end
      if reassignment.is_a?(NomenclatureChange::Reassignment) && (
        reassignable.is_a?(ListingChange) ||
        reassignable.is_a?(CitesSuspension) || reassignable.is_a?(Quota) ||
        reassignable.is_a?(EuSuspension) || reassignable.is_a?(EuOpinion)
        )
        copied_object.assign_attributes(notes(copied_object, reassignment))
      end
      if reassignable.kind_of? Distribution
        build_distribution_associations(reassignable, copied_object)
      elsif reassignable.kind_of? ListingChange
        build_listing_change_associations(reassignable, copied_object)
      elsif reassignable.kind_of?(Quota) || reassignable.kind_of?(CitesSuspension)
        build_trade_restriction_associations(reassignable, copied_object)
      end
      copied_object
    end
  end

  def summary_line
    "The following associations will be copied from #{@input.taxon_concept.full_name}
      to #{@output.display_full_name}"
  end

  private

  def build_distribution_associations(reassignable, copied_object)
    # for distributions this needs to copy distribution references and tags
    reassignable.distribution_references.each do |distr_ref|
      !copied_object.new_record? && distr_ref.duplicates({
        distribution_id: copied_object.id
      }).first || copied_object.distribution_references.build(distr_ref.comparison_attributes)
    end
    # taggings
    reassignable.taggings.each do |tagging|
      !copied_object.new_record? && tagging.duplicates({
        taggable_id: copied_object.id
      }).first || copied_object.taggings.build(tagging.comparison_attributes)
    end
  end

  def build_listing_change_associations(reassignable, copied_object)
    # for listing changes this needs to copy listing distributions and exceptions
    reassignable.listing_distributions.each do |listing_distr|
      !copied_object.new_record? && listing_distr.duplicates({
        listing_change_id: copied_object.id
      }).first || copied_object.listing_distributions.build(listing_distr.comparison_attributes)
    end
    # party distribution
    party_listing_distribution = reassignable.party_listing_distribution
    !copied_object.new_record? && party_listing_distribution &&
      party_listing_distribution.duplicates({
        listing_change_id: copied_object.id
      }).first || party_listing_distribution &&
        copied_object.build_party_listing_distribution(
        party_listing_distribution.comparison_attributes
      )
    # taxonomic exclusions (population exclusions already duplicated)
    reassignable.exclusions.where('taxon_concept_id IS NOT NULL').each do |exclusion|
      !copied_object.new_record? && exclusion.duplicates({
        parent_id: copied_object.id
      }).first || copied_object.exclusions.build(
        exclusion.comparison_attributes, :without_protection => true
      )
    end
  end

  def build_trade_restriction_associations(reassignable, copied_object)
    # for trade restrictions this needs to copy purpose / source / term links
    [
      :trade_restriction_terms,
      :trade_restriction_sources,
      :trade_restriction_purposes
    ].each do |trade_restriction_codes|
      reassignable.send(trade_restriction_codes).each do |trade_restr_code|
        !copied_object.new_record? && trade_restr_code.duplicates({
          trade_restriction_id: copied_object.id
        }).first || copied_object.send(trade_restriction_codes).build(
          trade_restr_code.comparison_attributes, :without_protection => true
        )
      end
    end
  end

end
