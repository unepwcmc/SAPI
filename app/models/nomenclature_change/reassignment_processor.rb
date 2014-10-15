class NomenclatureChange::ReassignmentProcessor

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
    if reassignment.reassignable_id.blank?
      process_reassignment_of_anonymous_reassignable(reassignment)
    else
      available_targets(reassignment).each do |target|
        process_reassignment_to_target(target, reassignment.reassignable)
      end
    end
  end

  def process_reassignment_of_anonymous_reassignable(reassignment)
    if reassignment.reassignable_type == 'Trade::Shipment'
      new_taxon_concept = @output.taxon_concept || @output.new_taxon_concept
      Trade::Shipment.update_all(
        {taxon_concept_id: new_taxon_concept.id},
        {taxon_concept_id: reassignment.input.taxon_concept_id}
      )
    else
      @input.reassignables_by_class(reassignment.reassignable_type).each do |reassignable|
        available_targets(reassignment).each do |target|
          process_reassignment_to_target(target, reassignable)
        end
      end
    end
  end

  def process_reassignment_to_target(target, reassignable); end

  def available_targets(reassignment)
    reassignment.reassignment_targets.select do |target|
      @output.new_taxon_concept_id &&
        @output.new_taxon_concept_id != @input.taxon_concept.id ||
        @output.taxon_concept_id != @input.taxon_concept.id
    end
  end

  def notes(reassigned_object, target)
    {
      nomenclature_note_en: (reassigned_object.nomenclature_note_en || '') +
        target.reassignment.note_with_resolved_placeholders_en(@input, @output),
      nomenclature_note_es: (reassigned_object.nomenclature_note_es || '') +
        target.reassignment.note_with_resolved_placeholders_es(@input, @output),
      nomenclature_note_fr: (reassigned_object.nomenclature_note_fr || '') +
        target.reassignment.note_with_resolved_placeholders_fr(@input, @output),
      internal_notes: (reassigned_object.internal_notes || '') +
        target.reassignment.internal_note_with_resolved_placeholders(@input, @output)
    }
  end

end
