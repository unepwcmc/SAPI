class NomenclatureChange::ReassignmentTransferProcessor < NomenclatureChange::ReassignmentProcessor

  # Each reassignable object implements find_duplicate,
  # which is called from here to make sure we're not adding a duplicate.
  def process_reassignment_to_target(target, reassignable)
    new_taxon_concept = @output.taxon_concept
    if target.output.will_create_taxon?
      new_taxon_concept = @output.new_taxon_concept
    end
    Rails.logger.debug("Processing #{reassignable.class} #{reassignable.id} transfer to #{new_taxon_concept.full_name}")

    if target.reassignment.kind_of?(NomenclatureChange::ParentReassignment) ||
      reassignable.kind_of?(Trade::Shipment)
      reassignable.parent_id = new_taxon_concept.id
      reassignable.save
    else
      transferred_object = reassignable.duplicates({
        "taxon_concept_id" => new_taxon_concept.id
      }).first || reassignable
      transferred_object.taxon_concept_id = new_taxon_concept.id
      if reassignable.kind_of? ListingChange
        transferred_object.inclusion_taxon_concept_id = nil
        transferred_object.assign_attributes(notes(transferred_object, target.reassignment))
      elsif reassignable.kind_of?(CitesSuspension) || reassignable.kind_of?(Quota) ||
        reassignable.kind_of?(EuSuspension) || reassignable.kind_of?(EuOpinion)
        transferred_object.assign_attributes(notes(transferred_object, target.reassignment))
      end
      transferred_object.save
    end
  end

  def process_reassignment_to_output(reassignment, reassignable)
    byebug
    new_taxon_concept = @output.new_taxon_concept || @output.taxon_concept
    Rails.logger.debug("Processing #{reassignable.class} #{reassignable.id} transfer to #{new_taxon_concept.full_name}")

    if reassignment.kind_of?(NomenclatureChange::OutputParentReassignment) ||
      reassignable.kind_of?(Trade::Shipment)
      reassignable.parent_id = new_taxon_concept.id
      reassignable.save
    else
      transferred_object = reassignable.duplicates({
        "taxon_concept_id" => new_taxon_concept.id
      }).first || reassignable
      transferred_object.taxon_concept_id = new_taxon_concept.id
      if reassignable.kind_of? ListingChange
        transferred_object.inclusion_taxon_concept_id = nil
        transferred_object.assign_attributes(notes(transferred_object,reassignment))
      elsif reassignable.kind_of?(CitesSuspension) || reassignable.kind_of?(Quota) ||
        reassignable.kind_of?(EuSuspension) || reassignable.kind_of?(EuOpinion)
        transferred_object.assign_attributes(notes(transferred_object, reassignment))
      end
      transferred_object.save
    end
  end

  def summary_line
    "The following associations will be transferred from #{@input.taxon_concept.full_name}
      to #{@output.display_full_name}"
  end

end
