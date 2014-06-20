class NomenclatureChange::StatusChange::Constructor
  include NomenclatureChange::ConstructorHelpers

  def initialize(nomenclature_change)
    @nomenclature_change = nomenclature_change
  end

  def build_outputs
    @nomenclature_change.outputs.build if @nomenclature_change.outputs.empty?
  end

  def build_input
    output = @nomenclature_change.output_that_needs_reassignments
    if output
      input = @nomenclature_change.input
      if input.nil? || input.taxon_concept_id != output_nr.taxon_concept_id
        # we need to create an input with same taxon as this output
        @nomenclature_change.build_input(taxon_concept_id: output.taxon_concept_id)
      end
    else
      #TODO check if necessary, consider swaps
      @nomenclature_change.build_input
    end
  end

  def build_reassignments
    return false unless @nomenclature_change.needs_reassignments?
    input = @nomenclature_change.input
    return false unless input
    # there needs to be a second output, which will be the reassignment target
    output = @nomenclature_change.output_that_receives_reassignments
    _build_parent_reassignments(input, output)
    _build_names_reassignments(input, [outputs])
    _build_distribution_reassignments(input, [output])
    _build_legislation_reassignments(input, [output])
    _build_common_names_reassignments(input, [output])
    _build_references_reassignments(input, [output])
  end

  def build_output_notes
    event = @nomenclature_change.event
    @nomenclature_change.outputs_except_inputs.each do |output|
      if output.note.blank?
        output.note = "#{output.display_full_name} status change from #{output.taxon_concept.name_status} to #{output.new_name_status} in #{Date.today.year}"
        output.note << " following taxonomic changes adopted at #{event.try(:name)}" if event
      end
    end
  end
end