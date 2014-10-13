class NomenclatureChange::ReassignmentTransferProcessor < NomenclatureChange::ReassignmentProcessor

  # Each reassignable object implements find_duplicate,
  # which is called from here to make sure we're not adding a duplicate.
  def process_reassignment_to_target(target, reassignable)
    new_taxon_concept = @output.taxon_concept || @output.new_taxon_concept
    Rails.logger.debug("Processing #{reassignable.class} #{reassignable.id} transfer to #{new_taxon_concept.full_name}")

    if target.reassignment.kind_of?(NomenclatureChange::ParentReassignment) ||
      reassignable.kind_of?(Trade::Shipment)
      reassignable.parent_id = new_taxon_concept.id
      reassignable.save
    else
      transferred_object = reassignable.duplicates({
        taxon_concept_id: new_taxon_concept.id
      }).first || reassignable
      transferred_object.taxon_concept_id = new_taxon_concept.id
      if reassignable.kind_of? ListingChange ||
        reassignable.kind_of?(CitesSuspension) || reassignable.kind_of?(Quota) ||
        reassignable.kind_of?(EuSuspension) || reassignable.kind_of?(EuOpinion)
        transferred_object.assign_attributes(notes(transferred_object, target))
      end
      transferred_object.save
    end
  end

  def summary
    [
      "The following associations will be transferred from #{@input.taxon_concept.full_name}
      to #{@output.display_full_name}",
      NomenclatureChange::ReassignmentSummarizer.new(@input, @output).summary
    ]
  end
end
