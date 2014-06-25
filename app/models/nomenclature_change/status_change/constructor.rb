class NomenclatureChange::StatusChange::Constructor
  include NomenclatureChange::ConstructorHelpers

  def initialize(nomenclature_change)
    @nomenclature_change = nomenclature_change
  end

  def build_primary_output
    if @nomenclature_change.primary_output.nil?
      @nomenclature_change.build_primary_output(
        :is_primary_output => true
      )
    end
  end

  def build_secondary_output
    if @nomenclature_change.needs_to_relay_associations? &&
      @nomenclature_change.secondary_output.nil?
      @nomenclature_change.build_secondary_output(
        :is_primary_output => false
      )
    end
  end

  def build_input
    input = @nomenclature_change.input
    output = @nomenclature_change.primary_output
    if @nomenclature_change.needs_to_relay_associations? && (
      input.nil? || input.taxon_concept_id != output.taxon_concept_id
      )
      # we need to create an input with same taxon as this output
      @nomenclature_change.build_input(
        taxon_concept_id: output.taxon_concept_id
      )
    elsif @nomenclature_change.needs_to_receive_associations? && input.nil?
      @nomenclature_change.build_input
    end
  end

  def build_reassignments
    input = @nomenclature_change.input
    output = if @nomenclature_change.needs_to_relay_associations?
      @nomenclature_change.secondary_output
    elsif @nomenclature_change.needs_to_receive_associations?
      @nomenclature_change.primary_output
    end
    return false unless input && output
    _build_parent_reassignments(input, output)
    _build_names_reassignments(input, [output])
    _build_distribution_reassignments(input, [output])
    _build_legislation_reassignments(input, [output])
    _build_common_names_reassignments(input, [output])
    _build_references_reassignments(input, [output])
  end

  def build_output_notes
    event = @nomenclature_change.event

    if @nomenclature_change.primary_output.note.blank?
      output = @nomenclature_change.primary_output
      output.note = "#{output.display_full_name} status change from #{output.taxon_concept.name_status} to #{output.new_name_status} in #{Date.today.year}"
      output.note << " following taxonomic changes adopted at #{event.try(:name)}" if event
    end

    if @nomenclature_change.is_swap? && @nomenclature_change.secondary_output.note.blank?
      output = @nomenclature_change.secondary_output
      output.note = "#{output.display_full_name} status change from #{output.taxon_concept.name_status} to #{output.new_name_status} in #{Date.today.year}"
      output.note << " following taxonomic changes adopted at #{event.try(:name)}" if event
    end
  end
end