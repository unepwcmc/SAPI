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

  def input_lumped_into(input, output, lng)
    input_html = taxon_concept_html(input.taxon_concept.full_name, input.taxon_concept.rank.name)
    output_html = taxon_concept_html(output.display_full_name, output.display_rank_name)
    case lng
    when :es
      "ES #{input_html} was lumped into #{output_html} in #{Date.today.year}"
    when :fr
      "FR #{input_html} was lumped into #{output_html} in #{Date.today.year}"
    else
      "#{input_html} was lumped into #{output_html} in #{Date.today.year}"
    end
  end

  def output_lumped_from(output, inputs, lng)
    output_html = taxon_concept_html(output.display_full_name, output.display_rank_name)
    inputs_html = @nomenclature_change.inputs.map do |input|
      taxon_concept_html(input.taxon_concept.full_name, input.taxon_concept.rank.name)
    end.join(', ')
    case lng
    when :es
      "ES #{output_html} was lumped from #{inputs_html} in #{Date.today.year}"
    when :fr
      "FR #{output_html} was lumped from #{inputs_html} in #{Date.today.year}"
    else
      "#{output_html} was lumped from #{inputs_html} in #{Date.today.year}"
    end
  end

  def multi_lingual_input_note(input, output, event)
    result = {}
    [:en, :es, :fr].each do |lng|
      note = '<p>'
      note << input_lumped_into(input, output, lng)
      note << following_taxonomic_changes(event, lng) if event
      note << '.</p>'
      result[lng] = note
    end
    result
  end

  def multi_lingual_output_note(output, inputs, event)
    result = {}
    [:en, :es, :fr].each do |lng|
      note = '<p>'
      note << output_lumped_from(output, @nomenclature_change.inputs, lng)
      note << following_taxonomic_changes(event, lng) if event
      note << '.</p>'
      result[lng] = note
    end
    result
  end

  def build_input_and_output_notes
    output = @nomenclature_change.output
    event = @nomenclature_change.event
    @nomenclature_change.inputs_except_outputs.each do |input|
      if input.note_en.blank?
        note = multi_lingual_input_note(input, output, event)
        input.note_en = note[:en]
        input.note_es = note[:es]
        input.note_fr = note[:fr]
      end
    end
    if output.note_en.blank?
      note = multi_lingual_output_note(output, @nomenclature_change.inputs, event)
        output.note_en = note[:en]
        output.note_es = note[:es]
        output.note_fr = note[:fr]
    end
  end

  def legislation_note(lng)
    output = @nomenclature_change.output
    input_html = taxon_concept_html('[[input]]', output.display_rank_name)
    output_html = taxon_concept_html(output.display_full_name, output.display_rank_name)
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
        "Originally listed as #{input_html}, which was lumped into #{output_html}"
      end,
      es: legislation_note(:es) do |input_html, output_html|
        "ES Originally listed as #{input_html}, which was lumped into #{output_html}"
      end,
      fr: legislation_note(:fr) do |input_html, output_html|
        "FR Originally listed as #{input_html}, which was lumped into #{output_html}"
      end
    }
  end

  def multi_lingual_suspension_note
    {
      en: legislation_note(:en) do |input_html, output_html|
        "Suspension originally formed for #{input_html}, which was lumped into #{output_html}"
      end,
      es: legislation_note(:es) do |input_html, output_html|
        "ES Suspension originally formed for #{input_html}, which was lumped into #{output_html}"
      end,
      fr: legislation_note(:fr) do |input_html, output_html|
        "FR Suspension originally formed for #{input_html}, which was lumped into #{output_html}"
      end
    }
  end

  def multi_lingual_opinion_note
    {
      en: legislation_note(:en) do |input_html, output_html|
        "Opinion originally formed for #{input_html}, which was lumped into #{output_html}"
      end,
      es: legislation_note(:es) do |input_html, output_html|
        "ES Opinion originally formed for #{input_html}, which was lumped into #{output_html}"
      end,
      fr: legislation_note(:fr) do |input_html, output_html|
        "FR Opinion originally formed for #{input_html}, which was lumped into #{output_html}"
      end
    }
    
  end

  def multi_lingual_quota_note
    {
      en: legislation_note(:en) do |input_html, output_html|
        "Quota originally published for #{input_html}, which was lumped into #{output_html}"
      end,
      es: legislation_note(:es) do |input_html, output_html|
        "ES Quota originally published for #{input_html}, which was lumped into #{output_html}"
      end,
      fr: legislation_note(:fr) do |input_html, output_html|
        "FR Quota originally published for #{input_html}, which was lumped into #{output_html}"
      end,
    }
  end
end
