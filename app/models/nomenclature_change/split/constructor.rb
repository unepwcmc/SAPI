class NomenclatureChange::Split::Constructor
  include NomenclatureChange::ConstructorHelpers

  def initialize(nomenclature_change)
    @nomenclature_change = nomenclature_change
  end

  def build_input
    @nomenclature_change.build_input if @nomenclature_change.input.nil?
  end

  def build_outputs
    @nomenclature_change.outputs.build() if @nomenclature_change.outputs.empty?
  end

  def build_parent_reassignments
    input = @nomenclature_change.input
    default_output = @nomenclature_change.outputs_intersect_inputs.first
    default_output ||= @nomenclature_change.outputs.first
    children = input.taxon_concept.children - @nomenclature_change.
      outputs.map(&:taxon_concept).compact
    _build_parent_reassignments(input, default_output, children)
  end

  def build_name_reassignments
    input = @nomenclature_change.input
    default_output = @nomenclature_change.outputs_intersect_inputs.first
    default_output ||= @nomenclature_change.outputs.first
    _build_names_reassignments(input, [default_output], @nomenclature_change.outputs)
  end

  def build_distribution_reassignments
    input = @nomenclature_change.input
    default_outputs = @nomenclature_change.outputs
    _build_distribution_reassignments(input, default_outputs)
  end

  def build_legislation_reassignments
    _build_legislation_reassignments(@nomenclature_change.input, @nomenclature_change.outputs)
  end

  def build_common_names_reassignments
    _build_common_names_reassignments(@nomenclature_change.input, @nomenclature_change.outputs)
  end

  def build_references_reassignments
    _build_references_reassignments(@nomenclature_change.input, @nomenclature_change.outputs)
  end

  def build_input_and_output_notes
    input = @nomenclature_change.input
    input_html = taxon_concept_html(input.taxon_concept.full_name, input.taxon_concept.rank.name)
    event = @nomenclature_change.event
    if input.note.blank?
      outputs_html = @nomenclature_change.outputs.map do |output|
        taxon_concept_html(output.display_full_name, output.display_rank_name)
      end.join(', ')
      input.note = "<p>#{input_html} was split into #{outputs_html} in #{Date.today.year}"
      input.note << " following taxonomic changes adopted at #{event.name}" if event
      input.note << '.</p>'
    end
    @nomenclature_change.outputs_except_inputs.each do |output|
      if output.note.blank?
        output_html = taxon_concept_html(output.display_full_name, output.display_rank_name)
        output.note = "<p>#{output_html} was split from #{input_html} in #{Date.today.year}"
        output.note << " following taxonomic changes adopted at #{event.name}" if event
        output.note << '.</p>'
      end
    end
  end

  def legislation_note
    input = @nomenclature_change.input
    input_html = taxon_concept_html(input.taxon_concept.full_name, input.taxon_concept.rank.name)
    output_html = taxon_concept_html('[[output]]', input.taxon_concept.rank.name)
    note = '<p>'
    note << yield(input_html, output_html)
    note << " following #{@nomenclature_change.event.name}" if @nomenclature_change.event
    note + '.</p>'
  end

  def listing_change_note
    legislation_note do |input_html, output_html|
      "Originally listed as #{input_html}, from which #{output_html} was split"
    end
  end

  def suspension_note
    legislation_note do |input_html, output_html|
      "Suspension originally formed for #{input_html}, from which #{output_html} was split"
    end
  end

  def opinion_note
    legislation_note do |input_html, output_html|
      "Opinion originally formed for #{input_html}, from which #{output_html} was split"
    end
  end

  def quota_note
    legislation_note do |input_html, output_html|
      "Quota originally published for #{input_html}, from which #{output_html} was split"
    end
  end

end