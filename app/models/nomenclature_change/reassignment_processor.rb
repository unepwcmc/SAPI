class NomenclatureChange::ReassignmentProcessor

  # if copy == true, dup associations rather than transfer
  def initialize(input, output, copy = false)
    @input = input
    @output = output
    @nc = output.nomenclature_change
    @copy = copy
  end

  def run
    @input.reassignments.each do |reassignment|
      process_reassignment(reassignment)
    end
  end

  private

  # all objects of reassignable_type that are linked to input taxon
  def reassignables_by_class(reassignable_type)
    reassignable_type.constantize.where(
      :taxon_concept_id => @input.taxon_concept.id
    )
  end

  def process_reassignment(reassignment)
    Rails.logger.debug("Processing #{reassignment.reassignable_type} reassignment from #{@input.taxon_concept.full_name}")
    reassignment.reassignment_targets.select do |target|
      target.output.taxon_concept != @input.taxon_concept
    end.each do |target|
      if reassignment.reassignable_id.blank?
        reassignables_by_class(reassignment.reassignable_type).each do |reassignable|
          if @copy
            process_copy_to_target(target, reassignable)
          else
            process_transfer_to_target(target, reassignable)
          end
        end
      else
        if @copy
          process_copy_to_target(target, reassignment.reassignable)
        else
          process_transfer_to_target(target, reassignment.reassignable)
        end
      end
    end
  end

  # Each reassignable object implements find_duplicate,
  # which is called from here to make sure we're not adding a duplicate.
  def process_transfer_to_target(target, reassignable)
    new_taxon_concept = target.output.taxon_concept || target.output.new_taxon_concept
    Rails.logger.debug("Processing #{reassignable.class} #{reassignable.id} transfer to #{new_taxon_concept.full_name}")

    if target.reassignment.kind_of? NomenclatureChange::ParentReassignment
      reassignable.parent_id = new_taxon_concept.id
      reassignable.save
    else
      transferred_object = reassignable.duplicates({
        taxon_concept_id: new_taxon_concept.id
      }).first || reassignable
      transferred_object.taxon_concept_id = new_taxon_concept.id
      transferred_object.save
    end
  end

  def process_copy_to_target(target, reassignable)
    new_taxon_concept = target.output.taxon_concept || target.output.new_taxon_concept
    Rails.logger.debug("Processing #{reassignable.class} #{reassignable.id} copy to #{new_taxon_concept.full_name}")

    if target.reassignment.kind_of? NomenclatureChange::ParentReassignment
      reassignable.parent_id = new_taxon_concept.id
      reassignable.save
    else
      copied_object = reassignable.duplicates({
        taxon_concept_id: new_taxon_concept.id
      }).first || reassignable.dup
      copied_object.taxon_concept_id = new_taxon_concept.id
      if reassignable.class == 'Distribution'
        # for distributions this needs to copy distribution references
        reassignable.distribution_references.each do |distr_ref|
          !copied_object.new_record? && distr_ref.duplicates({
            distribution_id: copied_object.id
          }).first || copied_object.distribution_references.build(distr_ref.attributes)
        end
      elsif reassignable.class == 'ListingChange'
        # for listing changes this needs to copy listing distributions and exceptions
        reassignable.listing_distributions.each do |listing_distr|
          !copied_object.new_record? && listing_distr.duplicates({
            listing_change_id: copied_object.id
          }).first || copied_object.listing_distributions.build(listing_distr.attributes)
        end
        # party distribution
        party_listing_distribution = copied_object.party_listing_distribution
        !copied_object.new_record? && party_listing_distribution &&
          party_listing_distribution.duplicates({
            listing_change_id: copied_object.id
          }).first || copied_object.build_party_listing_distributions(
            party_listing_distribution.attributes
          )
        # taxonomic exclusions (population exclusions already duplicated)
        reassignable.exclusions.where('taxon_concept_id IS NOT NULL').each do |exclusion|
          !copied_object.new_record? && exclusion.duplicates({
            listing_change_id: copied_object.id
          }).first || copied_object.exclusions.build(exclusion.attributes)
        end
      elsif reassignable.class == 'Quota' || reassignable.class == 'CitesSuspension'
        # for trade restrictions this needs to copy purpose / source / term links
        reassignable.trade_restriction_terms.each do |trade_restr_term|
          !copied_object.new_record? && trade_restr_term.duplicates({
            trade_restriction_id: copied_object.id
          }).first || copied_object.trade_restriction_terms.build(trade_restr_term.attributes)
        end
        reassignable.trade_restriction_sources.each do |trade_restr_source|
          !copied_object.new_record? && trade_restr_source.duplicates({
            trade_restriction_id: copied_object.id
          }).first || copied_object.trade_restriction_terms.build(trade_restr_source.attributes)
        end
        reassignable.trade_restriction_purposes.each do |trade_restr_purpose|
          !copied_object.new_record? && trade_restr_purpose.duplicates({
            trade_restriction_id: copied_object.id
          }).first || copied_object.trade_restriction_terms.build(trade_restr_purpose.attributes)
        end
      end
      copied_object.save # hope that saves the duplicated associations as well
    end
  end

end
