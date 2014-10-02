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

  def input_split_into(input, outputs, lng)
    input_html = taxon_concept_html(input.taxon_concept.full_name, input.taxon_concept.rank.name)
    outputs_html = @nomenclature_change.outputs.map do |output|
      taxon_concept_html(output.display_full_name, output.display_rank_name)
    end.join(', ')
    case lng
    when :es
      "ES #{input_html} was split into #{outputs_html} in #{Date.today.year}"
    when :fr
      "FR #{input_html} was split into #{outputs_html} in #{Date.today.year}"
    else
      "#{input_html} was split into #{outputs_html} in #{Date.today.year}"
    end
  end

  def output_split_from(output, input, lng)
    output_html = taxon_concept_html(output.display_full_name, output.display_rank_name)
    input_html = taxon_concept_html(input.taxon_concept.full_name, input.taxon_concept.rank.name)
    case lng
    when :es
      "ES #{output_html} was split from #{input_html} in #{Date.today.year}"
    when :fr
      "FR #{output_html} was split from #{input_html} in #{Date.today.year}"
    else
      "#{output_html} was split from #{input_html} in #{Date.today.year}"
    end
  end

  def multi_lingual_input_note(input, outputs, event)
    result = {}
    [:en, :es, :fr].each do |lng|
      note = '<p>'
      note << input_split_into(input, @nomenclature_change.outputs, lng)
      note << following_taxonomic_changes(event, lng) if event
      note << '.</p>'
      result[lng] = note
    end
    result
  end

  def multi_lingual_output_note(output, input, event)
    result = {}
    [:en, :es, :fr].each do |lng|
      note = '<p>'
      note << output_split_from(output, input, lng)
      note << following_taxonomic_changes(event, lng) if event
      note << '.</p>'
      result[lng] = note
    end
    result
  end

  def build_input_and_output_notes
    input = @nomenclature_change.input
    event = @nomenclature_change.event
    if input.note_en.blank?
      note = multi_lingual_input_note(input, @nomenclature_change.outputs, event)
      input.note_en = note[:en]
      input.note_es = note[:es]
      input.note_fr = note[:fr]
    end
    @nomenclature_change.outputs_except_inputs.each do |output|
      if output.note_en.blank?
        note = multi_lingual_output_note(output, input, event)
        output.note_en = note[:en]
        output.note_es = note[:es]
        output.note_fr = note[:fr]
      end
    end
  end

  def legislation_note(lng)
    input = @nomenclature_change.input
    input_html = taxon_concept_html(input.taxon_concept.full_name, input.taxon_concept.rank.name)
    output_html = taxon_concept_html('[[output]]', input.taxon_concept.rank.name)
    note = '<p>'
    note << yield(input_html, output_html)
    if @nomenclature_change.event
      note << following_taxonomic_changes(@nomenclature_change.event, lng)
    end
    note + '.</p>'
  end

  def multi_lingual_listing_change_note
    {
      en: legislation_note(:en) do |input_html, output_html|
        "Originally listed as #{input_html}, from which #{output_html} was split"
      end,
      es: legislation_note(:en) do |input_html, output_html|
        "ES Originally listed as #{input_html}, from which #{output_html} was split"
      end,
      fr: legislation_note(:en) do |input_html, output_html|
        "FR Originally listed as #{input_html}, from which #{output_html} was split"
      end
    }
  end

  def multi_lingual_suspension_note
    {
      en: legislation_note(:en) do |input_html, output_html|
        "Suspension originally formed for #{input_html}, from which #{output_html} was split"
      end,
      es: legislation_note(:es) do |input_html, output_html|
        "ES Suspension originally formed for #{input_html}, from which #{output_html} was split"
      end,
      fr: legislation_note(:fr) do |input_html, output_html|
        "FR Suspension originally formed for #{input_html}, from which #{output_html} was split"
      end
    }
  end

  def multi_lingual_opinion_note
    {
      en: legislation_note(:en) do |input_html, output_html|
        "Opinion originally formed for #{input_html}, from which #{output_html} was split"
      end,
      es: legislation_note(:es) do |input_html, output_html|
        "ES Opinion originally formed for #{input_html}, from which #{output_html} was split"
      end,
      fr: legislation_note(:fr) do |input_html, output_html|
        "FR Opinion originally formed for #{input_html}, from which #{output_html} was split"
      end
    }
  end

  def multi_lingual_quota_note
    {
      en: legislation_note(:en) do |input_html, output_html|
        "Quota originally published for #{input_html}, from which #{output_html} was split"
      end,
      es: legislation_note(:es) do |input_html, output_html|
        "ES Quota originally published for #{input_html}, from which #{output_html} was split"
      end,
      fr: legislation_note(:fr) do |input_html, output_html|
        "FR Quota originally published for #{input_html}, from which #{output_html} was split"
      end
    }
  end

end