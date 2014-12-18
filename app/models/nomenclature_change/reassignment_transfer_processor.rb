class NomenclatureChange::ReassignmentTransferProcessor < NomenclatureChange::ReassignmentProcessor

  def process_reassignment(reassignment, reassignable)
    object_before_reassignment = reassignable.dup
    reassigned_object = transferred_object_before_save(reassignment, reassignable)
    if reassigned_object
      reassigned_object.save(validate: false)
      post_process(reassigned_object, object_before_reassignment)
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

end
