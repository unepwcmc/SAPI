class NomenclatureChange::Lump::Constructor
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
    @nomenclature_change.inputs.each do |input|
      children = input.taxon_concept.children - [@nomenclature_change.
        output.taxon_concept]
      _build_parent_reassignments(input, output, children)
    end
  end

  def build_name_reassignments
    @nomenclature_change.inputs.each do |input|
      _build_names_reassignments(input)
    end
  end

  def build_distribution_reassignments
    @nomenclature_change.inputs.each do |input|
      _build_distribution_reassignments(input)
    end
  end

  def build_legislation_reassignments
    @nomenclature_change.inputs.each do |input|
      _build_legislation_reassignments(input)
    end
  end

  def build_common_names_reassignments
    @nomenclature_change.inputs.each do |input|
      _build_common_names_reassignments(input)
    end
  end

  def build_references_reassignments
    @nomenclature_change.inputs.each do |input|
      _build_references_reassignments(input)
    end
  end

  def build_input_and_output_notes
    inputs = @nomenclature_change.inputs.map{ |input| input.taxon_concept.full_name }.join(', ')
    output = @nomenclature_change.output
    event = @nomenclature_change.event
    @nomenclature_change.inputs_except_outputs.each do |input|
      if input.note.blank?
        input.note = "#{inputs} were lumped into #{output.display_full_name} in #{Date.today.year}"
        input.note << " following taxonomic changes adopted at #{event.try(:name)}" if event
      end
    end
    if output.note.blank?
      output.note = "#{output.display_full_name} was lumped from #{inputs} in #{Date.today.year}"
      output.note << " following taxonomic changes adopted at #{event.try(:name)}" if event
    end
  end
end
