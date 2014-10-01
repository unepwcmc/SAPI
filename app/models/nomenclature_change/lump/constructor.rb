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
      children = input.taxon_concept.children - [output.taxon_concept]
      _build_parent_reassignments(input, output, children)
    end
  end

  def build_name_reassignments
    @nomenclature_change.inputs.each do |input|
      _build_names_reassignments(input, [@nomenclature_change.output])
    end
  end

  def build_distribution_reassignments
    @nomenclature_change.inputs.each do |input|
      _build_distribution_reassignments(input, [@nomenclature_change.output])
    end
  end

  def build_legislation_reassignments
    @nomenclature_change.inputs.each do |input|
      _build_legislation_reassignments(input, [@nomenclature_change.output])
    end
  end

  def build_common_names_reassignments
    @nomenclature_change.inputs.each do |input|
      _build_common_names_reassignments(input, [@nomenclature_change.output])
    end
  end

  def build_references_reassignments
    @nomenclature_change.inputs.each do |input|
      _build_references_reassignments(input, [@nomenclature_change.output])
    end
  end

  def input_lumped_into(input, output)
    input_html = taxon_concept_html(input.taxon_concept.full_name, input.taxon_concept.rank.name)
    output_html = taxon_concept_html(output.display_full_name, output.display_rank_name)
    "#{input_html} was lumped into #{output_html} in #{Date.today.year}"
  end

  def output_lumped_from(output, inputs)
    output_html = taxon_concept_html(output.display_full_name, output.display_rank_name)
    inputs_html = @nomenclature_change.inputs.map do |input|
      taxon_concept_html(input.taxon_concept.full_name, input.taxon_concept.rank.name)
    end.join(', ')
    "#{output_html} was lumped from #{inputs_html} in #{Date.today.year}"
  end

  def input_note(input, output, event)
    note = '<p>'
    note << input_lumped_into(input, output)
    note << following_taxonomic_changes(event) if event
    note << '.</p>'
    note
  end

  def output_note(output, inputs, event)
    note = '<p>'
    note << output_lumped_from(output, @nomenclature_change.inputs)
    note << following_taxonomic_changes(event) if event
    note << '.</p>'
    note
  end

  def build_input_and_output_notes
    output = @nomenclature_change.output
    event = @nomenclature_change.event
    @nomenclature_change.inputs_except_outputs.each do |input|
      if input.note.blank?
        input.note = input_note(input, output, event)
      end
    end
    if output.note.blank?
      output.note = output_note(output, @nomenclature_change.inputs, event)
    end
  end

  def legislation_note
    output = @nomenclature_change.output
    input_html = taxon_concept_html('[[input]]', output.display_rank_name)
    output_html = taxon_concept_html(output.display_full_name, output.display_rank_name)
    note = '<p>'
    note << yield(input_html, output_html)
    note << " following #{@nomenclature_change.event.name}" if @nomenclature_change.event
    note + '.</p>'
  end

  def listing_change_note
    legislation_note do |input_html, output_html|
      "Originally listed as #{input_html}, which was lumped into #{output_html}"
    end
  end

  def suspension_note
    legislation_note do |input_html, output_html|
      "Suspension originally formed for #{input_html}, which was lumped into #{output_html}"
    end
  end

  def opinion_note
    legislation_note do |input_html, output_html|
      "Opinion originally formed for #{input_html}, which was lumped into #{output_html}"
    end
  end

  def quota_note
    legislation_note do |input_html, output_html|
      "Quota originally published for #{input_html}, which was lumped into #{output_html}"
    end
  end
end
