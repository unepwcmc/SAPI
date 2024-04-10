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

  def build_document_reassignments
    @nomenclature_change.inputs.each do |input|
      _build_document_reassignments(input, [@nomenclature_change.output])
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
    I18n.with_locale(lng) do
      I18n.translate(
        'lump.input_lumped_into',
        input_taxon: input_html,
        output_taxon: output_html,
        default: ''
      )
    end
  end

  def output_lumped_from(output, inputs, lng)
    output_html = taxon_concept_html(output.display_full_name, output.display_rank_name)
    inputs_html = @nomenclature_change.inputs.map do |input|
      taxon_concept_html(input.taxon_concept.full_name, input.taxon_concept.rank.name)
    end.join(', ')
    I18n.with_locale(lng) do
      I18n.translate(
        'lump.output_lumped_from',
        output_taxon: output_html,
        input_taxa: inputs_html,
        default: ''
      )
    end
  end

  def multi_lingual_input_note(input, output, event)
    result = {}
    [:en, :es, :fr].each do |lng|
      note = '<p>'
      note << input_lumped_into(input, output, lng)
      note << in_year(event, lng)
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
      note << in_year(event, lng)
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
      note = multi_lingual_input_note(input, output, event)
      input.note_en = note[:en]
      input.note_es = note[:es]
      input.note_fr = note[:fr]
    end
    note = multi_lingual_output_note(output, @nomenclature_change.inputs, event)
    output.note_en = note[:en]
    output.note_es = note[:es]
    output.note_fr = note[:fr]
  end

  def legislation_note(lng)
    output = @nomenclature_change.output
    input_html = taxon_concept_html('[[input]]', output.display_rank_name)
    output_html = taxon_concept_html(output.display_full_name, output.display_rank_name)
    note = ''
    note << yield(input_html, output_html)
    note << in_year(@nomenclature_change.event, lng)
    if @nomenclature_change.event
      note << following_taxonomic_changes(@nomenclature_change.event, lng)
    end
    note = "<p>#{note}.</p>" if note.present?
  end

  def multi_lingual_listing_change_note
    multi_lingual_legislation_note('lump.listing_change')
  end

  def multi_lingual_suspension_note
    multi_lingual_legislation_note('lump.suspension')
  end

  alias :multi_lingual_cites_suspension_note :multi_lingual_suspension_note
  alias :multi_lingual_eu_suspension_note :multi_lingual_suspension_note

  def multi_lingual_eu_opinion_note
    multi_lingual_legislation_note('lump.opinion')
  end

  def multi_lingual_quota_note
    multi_lingual_legislation_note('lump.quota')
  end
end
