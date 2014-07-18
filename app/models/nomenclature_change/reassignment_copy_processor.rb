class NomenclatureChange::ReassignmentCopyProcessor

  def initialize(input, output)
    @input = input
    @output = output
  end

  def run
    @input.reassignments.each do |reassignment|
      process_reassignment(reassignment)
    end
  end

  def process_reassignment(reassignment)
    Rails.logger.debug("Processing #{reassignment.reassignable_type} reassignment from #{@input.taxon_concept.full_name}")
    reassignment.reassignment_targets.select do |target|
      target.output.new_taxon_concept_id &&
        target.output.new_taxon_concept_id != @input.taxon_concept.id ||
        target.output.taxon_concept_id != @input.taxon_concept.id
    end.each do |target|
      if reassignment.reassignable_id.blank?
        if reassignment.reassignable_type == 'Trade::Shipment'
          new_taxon_concept = target.output.taxon_concept || target.output.new_taxon_concept
          Trade::Shipment.update_all(
            {taxon_concept_id: new_taxon_concept.id},
            {taxon_concept_id: reassignment.input.taxon_concept_id}
          )
        else
          @input.reassignables_by_class(reassignment.reassignable_type).each do |reassignable|
            process_copy_to_target(target, reassignable)
          end
        end
      else
        process_copy_to_target(target, reassignment.reassignable)
      end
    end
  end

  def process_copy_to_target(target, reassignable)
    new_taxon_concept = target.output.taxon_concept || target.output.new_taxon_concept
    Rails.logger.debug("Processing #{reassignable.class} #{reassignable.id} copy to #{new_taxon_concept.full_name}")

    if target.reassignment.kind_of?(NomenclatureChange::ParentReassignment) ||
      reassignable.kind_of?(Trade::Shipment)
      reassignable.parent_id = new_taxon_concept.id
      reassignable.save
    else
      copied_object = reassignable.duplicates({
        taxon_concept_id: new_taxon_concept.id
      }).first || reassignable.dup
      copied_object.taxon_concept_id = new_taxon_concept.id
      if reassignable.kind_of? Distribution
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
      elsif reassignable.kind_of? ListingChange
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
            listing_change_id: copied_object.id
          }).first || copied_object.exclusions.build(
            exclusion.comparison_attributes, :without_protection => true
          )
        end
      elsif reassignable.kind_of?(Quota) || reassignable.kind_of?(CitesSuspension)
        # for trade restrictions this needs to copy purpose / source / term links
        reassignable.trade_restriction_terms.each do |trade_restr_term|
          !copied_object.new_record? && trade_restr_term.duplicates({
            trade_restriction_id: copied_object.id
          }).first || copied_object.trade_restriction_terms.build(
            trade_restr_term.comparison_attributes, :without_protection => true
          )
        end
        reassignable.trade_restriction_sources.each do |trade_restr_source|
          !copied_object.new_record? && trade_restr_source.duplicates({
            trade_restriction_id: copied_object.id
          }).first || copied_object.trade_restriction_sources.build(
            trade_restr_source.comparison_attributes, :without_protection => true
          )
        end
        reassignable.trade_restriction_purposes.each do |trade_restr_purpose|
          !copied_object.new_record? && trade_restr_purpose.duplicates({
            trade_restriction_id: copied_object.id
          }).first || copied_object.trade_restriction_purposes.build(
            trade_restr_purpose.comparison_attributes, :without_protection => true
          )
        end
      end
      copied_object.save # hope that saves the duplicated associations as well
    end
  end

  def summary
    [
      "The following associations will be copied from #{@input.taxon_concept.full_name}
      to #{@output.display_full_name}",
      NomenclatureChange::ReassignmentSummarizer.new(@input, @output).summary
    ]
  end

end
