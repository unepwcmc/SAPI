class NomenclatureChange::ReassignmentTransferProcessor < NomenclatureChange::ReassignmentProcessor

  def process_reassignment(reassignment, reassignable)
    object_before_reassignment = reassignable.dup
    reassigned_object = transferred_object_before_save(reassignment, reassignable)
    if reassigned_object
      reassigned_object.save(validate: false)
      post_process(reassigned_object, object_before_reassignment)
      transfer_associations(reassigned_object, reassignable)
    end
    reassigned_object
  end

  def transferred_object_before_save(reassignment, reassignable)
    return nil if conflicting_listing_change_reassignment?(reassignment, reassignable)
    new_taxon_concept = @output.new_taxon_concept || @output.taxon_concept

    Rails.logger.debug("Processing #{reassignable.class} #{reassignable.id} transfer to #{new_taxon_concept.full_name}")
    if reassignment.kind_of?(NomenclatureChange::ParentReassignment) ||
      reassignment.kind_of?(NomenclatureChange::OutputParentReassignment)
      reassignable.parent_id = new_taxon_concept.id
      reassignable
    elsif reassignable.kind_of?(Trade::Shipment)
      reassignable.taxon_concept_id = new_taxon_concept.id
      reassignable
    else
      # Each reassignable object implements find_duplicate,
      # which is called from here to make sure we're not adding a duplicate.
      transferred_object = reassignable.duplicates({
        taxon_concept_id: new_taxon_concept.id
      }).first || reassignable
      transferred_object.taxon_concept_id = new_taxon_concept.id
      if reassignable.is_a?(ListingChange)
        transferred_object.inclusion_taxon_concept_id = nil
      end
      if reassignment.is_a?(NomenclatureChange::Reassignment) && (
        reassignable.is_a?(ListingChange) ||
        reassignable.is_a?(CitesSuspension) || reassignable.is_a?(Quota) ||
        reassignable.is_a?(EuSuspension) || reassignable.is_a?(EuOpinion)
        )
        transferred_object.assign_attributes(notes(transferred_object, reassignment))
      end
      transferred_object
    end
  end

  def summary_line
    "The following associations will be transferred from #{@input.taxon_concept.full_name}
      to #{@output.display_full_name}"
  end

  protected

  def transfer_associations(reassigned_object, reassignable)
    return if reassigned_object.id == reassignable.id
    if reassigned_object.is_a?(Distribution)
      # that means the distribution is a duplicate and was not transferred
      # but it might have some distribution references and taggings
      transfer_distribution_references(reassigned_object, reassignable)
      transfer_distribution_taggings(reassigned_object, reassignable)
    end
    # destroy the original object
    reassignable.delete
  end

  def transfer_distribution_references(reassigned_object, reassignable)
    return if reassignable.distribution_references.count == 0
    distribution_references_to_transfer = reassignable.distribution_references
    if reassigned_object.distribution_references.count > 0
      distribution_references_to_transfer = distribution_references_to_transfer.
      where(
        'reference_id NOT IN (?)',
        reassigned_object.distribution_references.select(:reference_id)
          .map(&:reference_id)
      )
    end
    distribution_references_to_transfer.update_all(distribution_id: reassigned_object.id)
  end

  def transfer_distribution_taggings(reassigned_object, reassignable)
    return if reassignable.taggings.count == 0
    taggings_to_transfer = reassignable.taggings
    if reassigned_object.taggings.count > 0
      taggings_to_transfer = taggings_to_transfer.
      where(
        'tag_id NOT IN (?)',
        reassigned_object.taggings.select(:tag_id).map(&:tag_id)
      )
    end
    taggings_to_transfer.update_all(taggable_id: reassigned_object.id)
  end

end
