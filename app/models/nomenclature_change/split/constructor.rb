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
    _build_names_reassignments(input, [default_output])
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
    event = @nomenclature_change.event
    if input.note.blank?
      outputs = @nomenclature_change.outputs.map{ |output| output.display_full_name }.join(', ')
      input.note = "#{input.taxon_concept.full_name} was split into #{outputs} in #{Date.today.year}"
      input.note << " following taxonomic changes adopted at #{event.try(:name)}" if event
    end
    @nomenclature_change.outputs_except_inputs.each do |output|
      if output.note.blank?
        output.note = "#{output.display_full_name} was split from #{input.taxon_concept.full_name} in #{Date.today.year}"
        output.note << " following taxonomic changes adopted at #{event.try(:name)}" if event
      end
    end
  end

  def legislation_note
    input = @nomenclature_change.input
    note = yield(input)
    note << " following #{@nomenclature_change.event.try(:name)}" if @nomenclature_change.event
    note + '.'
  end

  def listing_change_note
    legislation_note do |input|
      "Originally listed as #{input.taxon_concept.full_name}, from which [[output]] was split"
    end
  end

  def suspension_note
    legislation_note do |input|
      "Suspension originally formed for #{input.taxon_concept.full_name}, from which [[output]] was split"
    end
  end

  def opinion_note
    legislation_note do |input|
      "Opinion originally formed for #{input.taxon_concept.full_name}, from which [[output]] was split"
    end
  end

  def quota_note
    legislation_note do |input|
      "Quota originally published for #{input.taxon_concept.full_name}, from which [[output]] was split"
    end
  end

end