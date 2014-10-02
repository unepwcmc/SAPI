class NomenclatureChange::ReassignmentProcessor

  def initialize(input, output, copy = false)
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
      @output.new_taxon_concept_id &&
        @output.new_taxon_concept_id != @input.taxon_concept.id ||
        @output.taxon_concept_id != @input.taxon_concept.id
    end.each do |target|
      if reassignment.reassignable_id.blank?
        if reassignment.reassignable_type == 'Trade::Shipment'
          new_taxon_concept = @output.taxon_concept || @output.new_taxon_concept
          Trade::Shipment.update_all(
            {taxon_concept_id: new_taxon_concept.id},
            {taxon_concept_id: reassignment.input.taxon_concept_id}
          )
        else
          @input.reassignables_by_class(reassignment.reassignable_type).each do |reassignable|
            process_transfer_to_target(target, reassignable)
          end
        end
      else
        process_transfer_to_target(target, reassignment.reassignable)
      end
    end
  end

  # Each reassignable object implements find_duplicate,
  # which is called from here to make sure we're not adding a duplicate.
  def process_transfer_to_target(target, reassignable)
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
      if reassignable.kind_of? ListingChange
        transferred_object.nomenclature_note_en = (transferred_object.nomenclature_note_en || '') +
          target.reassignment.note_with_resolved_placeholders_en(@input, @output)
        transferred_object.nomenclature_note_es = (transferred_object.nomenclature_note_es || '') +
          target.reassignment.note_with_resolved_placeholders_es(@input, @output)
        transferred_object.nomenclature_note_fr = (transferred_object.nomenclature_note_fr || '') +
          target.reassignment.note_with_resolved_placeholders_fr(@input, @output)
      elsif reassignable.kind_of?(CitesSuspension) || reassignable.kind_of?(Quota) ||
        reassignable.kind_of?(EuSuspension) || reassignable.kind_of?(EuOpinion)
        transferred_object.nomenclature_note = (transferred_object.nomenclature_note || '') +
          target.reassignment.note_with_resolved_placeholders_en(@input, @output)
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
