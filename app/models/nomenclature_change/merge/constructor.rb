class NomenclatureChange::Merge::Constructor
  include NomenclatureChange::ConstructorHelpers

  def initialize(nomenclature_change)
    @nomenclature_change = nomenclature_change
  end

  def build_inputs
    2.times { @nomenclature_change.inputs.build } if @nomenclature_change.inputs.empty?
  end

  def build_output
    @nomenclature_change.build_output if @nomenclature_change.output.nil?
  end

  def build_parent_reassignments
    output = @nomenclature_change.output
    default_input = @nomenclature_change.inputs_intersect_outputs.first
    default_input ||= @nomenclature_change.inputs.first
    children = output.taxon_concept.children - @nomenclature_change.
      inputs.map(&:taxon_concept).compact
    _build_parent_reassignments(input, default_output, children)
  end

  def build_name_reassignments
    input = @nomenclature_change.input
    default_output = @nomenclature_change.outputs_intersect_inputs.first
    default_output ||= @nomenclature_change.outputs.first
    _build_names_reassignments(input, [default_output])
  end

  def build_distribution_reassignments
    input = @nomenclature_change.input
    default_outputs = @nomenclature_change.outputs
    _build_distribution_reassignments(input, default_outputs)
  end

  def build_legislation_reassignments
    _build_legislation_reassignments(@nomenclature_change.input)
  end

  def build_common_names_reassignments
    _build_common_names_reassignments(@nomenclature_change.input)
  end

  def build_references_reassignments
    _build_references_reassignments(@nomenclature_change.input)
  end

  def build_input_and_output_notes
    input = @nomenclature_change.input
    event = @nomenclature_change.event
    if input.note.blank?
      outputs = @nomenclature_change.outputs.map{ |output| output.display_full_name }.join(', ')
      input.note = "#{input.taxon_concept.full_name} was merge into #{outputs} in #{Date.today.year}"
      input.note << " following taxonomic changes adopted at #{event.try(:name)}" if event
    end
    @nomenclature_change.outputs_except_inputs.each do |output|
      if output.note.blank?
        output.note = "#{output.display_full_name} was merge from #{input.taxon_concept.full_name} in #{Date.today.year}"
        output.note << " following taxonomic changes adopted at #{event.try(:name)}" if event
      end
    end
  end
end
