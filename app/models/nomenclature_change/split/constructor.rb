class NomenclatureChange::Split::Constructor
  include NomenclatureChange::ConstructorHelpers

  def initialize(nomenclature_change)
    @nomenclature_change = nomenclature_change
  end

  def build_input
    @nomenclature_change.build_input if @nomenclature_change.input.nil?
  end

  def build_outputs
    if @nomenclature_change.outputs.empty?
      @nomenclature_change.outputs.build(
        taxon_concept_id: @nomenclature_change.input.taxon_concept_id
      )
      @nomenclature_change.outputs.build()
    end
  end

  def build_parent_reassignments
    input = @nomenclature_change.input
    outputs = @nomenclature_change.outputs.select{ |out|
      if !out.new_scientific_name.nil? && !out.scientific_name.nil?
        !out.new_scientific_name.empty? && !out.scientific_name.empty?
      end
    }

    default_output = @nomenclature_change.outputs_intersect_inputs.first
    default_output ||= @nomenclature_change.outputs.first
    children = input.taxon_concept.children - @nomenclature_change.
      outputs.map(&:taxon_concept).compact
    _build_parent_reassignments(input, default_output, children)

    outputs.each do |output|
      _build_parent_reassignments(output, output)
    end
  end

  def build_name_reassignments
    input = @nomenclature_change.input
    outputs = @nomenclature_change.outputs.select{ |out|
      if !out.new_scientific_name.nil? && !out.scientific_name.nil?
        !out.new_scientific_name.empty? && !out.scientific_name.empty?
      end
    }
    default_output = @nomenclature_change.outputs_intersect_inputs.first
    default_output ||= @nomenclature_change.outputs.first
    _build_names_reassignments(input, [default_output], @nomenclature_change.outputs)

    outputs.each do |output|
      _build_names_reassignments(output, [output], @nomenclature_change.outputs)
    end
  end

  def build_distribution_reassignments
    input = @nomenclature_change.input
    outputs = @nomenclature_change.outputs.select{ |out|
      if !out.new_scientific_name.nil? && !out.scientific_name.nil?
        !out.new_scientific_name.empty? && !out.scientific_name.empty?
      end
    }
    default_outputs = @nomenclature_change.outputs
    _build_distribution_reassignments(input, default_outputs)

    outputs.each do |output|
      _build_distribution_reassignments(output, [output])
    end
  end

  def build_legislation_reassignments
    input = @nomenclature_change.input
    outputs = @nomenclature_change.outputs.select{ |out|
      if !out.new_scientific_name.nil? && !out.scientific_name.nil?
        !out.new_scientific_name.empty? && !out.scientific_name.empty?
      end
    }
    _build_legislation_reassignments(@nomenclature_change.input, @nomenclature_change.outputs)

    outputs.each do |output|
      _build_legislation_reassignments(output, [output])
    end
  end

  def build_common_names_reassignments
    input = @nomenclature_change.input
    outputs = @nomenclature_change.outputs.select{ |out|
      if !out.new_scientific_name.nil? && !out.scientific_name.nil?
        !out.new_scientific_name.empty? && !out.scientific_name.empty?
      end
    }
    _build_common_names_reassignments(@nomenclature_change.input, @nomenclature_change.outputs)

    outputs.each do |output|
      _build_common_names_reassignments(output, [output])
    end
  end

  def build_references_reassignments
    input = @nomenclature_change.input
    outputs = @nomenclature_change.outputs.select{ |out|
      if !out.new_scientific_name.nil? && !out.scientific_name.nil?
        !out.new_scientific_name.empty? && !out.scientific_name.empty?
      end
    }
    _build_references_reassignments(@nomenclature_change.input, @nomenclature_change.outputs)

    outputs.each do |output|
      _build_references_reassignments(output, [output])
    end
  end

  def input_split_into(input, outputs, lng)
    input_html = taxon_concept_html(input.taxon_concept.full_name, input.taxon_concept.rank.name)
    outputs_html = @nomenclature_change.outputs.map do |output|
      taxon_concept_html(output.display_full_name, output.display_rank_name)
    end.join(', ')
    I18n.with_locale(lng) do
      I18n.translate(
        'split.input_split_into',
        output_taxa: outputs_html,
        input_taxon: input_html,
        year: Date.today.year,
        default: 'Translation missing'
      )
    end
  end

  def output_split_from(output, input, lng)
    output_html = taxon_concept_html(output.display_full_name, output.display_rank_name)
    input_html = taxon_concept_html(input.taxon_concept.full_name, input.taxon_concept.rank.name)
    I18n.with_locale(lng) do
      I18n.translate(
        'split.output_split_from',
        output_taxon: output_html,
        input_taxon: input_html,
        year: Date.today.year,
        default: 'Translation missing'
      )
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
    multi_lingual_legislation_note('split.listing_change')
  end

  def multi_lingual_suspension_note
    multi_lingual_legislation_note('split.suspension')
  end

  alias :multi_lingual_cites_suspension_note :multi_lingual_suspension_note
  alias :multi_lingual_eu_suspension_note :multi_lingual_suspension_note

  def multi_lingual_eu_opinion_note
    multi_lingual_legislation_note('split.opinion')
  end

  def multi_lingual_quota_note
    multi_lingual_legislation_note('split.quota')
  end

end