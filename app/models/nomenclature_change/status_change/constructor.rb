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
    if (@nomenclature_change.needs_to_relay_associations? ||
      @nomenclature_change.needs_to_receive_associations?) &&
      @nomenclature_change.secondary_output.nil?
      @nomenclature_change.build_secondary_output(
        :is_primary_output => false,
        :new_name_status => @nomenclature_change.primary_output.taxon_concept.name_status
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

  def build_parent_reassignments
    input_output_for_reassignment do |input, output|
      _build_parent_reassignments(input, output)
    end
  end

  def build_name_reassignments
    input_output_for_reassignment do |input, output|
      _build_names_reassignments(input, [output])
    end
  end

  def build_distribution_reassignments
    input_output_for_reassignment do |input, output|
      _build_distribution_reassignments(input, [output])
    end
  end

  def build_legislation_reassignments
    input_output_for_reassignment do |input, output|
      _build_legislation_reassignments(input, [output])
    end
  end

  def build_common_names_reassignments
    input_output_for_reassignment do |input, output|
      _build_common_names_reassignments(input, [output])
    end
  end

  def build_references_reassignments
    input_output_for_reassignment do |input, output|
      _build_references_reassignments(input, [output])
    end
  end

  def build_trade_reassignments
    input_output_for_reassignment do |input, output|
      _build_trade_reassignments(input, output)
    end
  end

  def status_change_from_to(output, lng)
    output_html = taxon_concept_html(
      output.display_full_name,
      output.display_rank_name
    )
    I18n.with_locale(lng) do
      I18n.translate(
        'status_change.status_change_from_to',
        output_taxon: output_html,
        old_status: output.taxon_concept.name_status,
        new_status: output.new_name_status,
        year: Date.today.year,
        default: 'Translation missing'
      )
    end
  end

  def multi_lingual_output_note(output, event)
    result = {}
    [:en, :es, :fr].each do |lng|
      note = '<p>'
      note << status_change_from_to(output, lng)
      note << following_taxonomic_changes(event, lng) if event
      note << '.</p>'
      result[lng] = note
    end
    result
  end

  def build_output_notes
    event = @nomenclature_change.event
    if @nomenclature_change.primary_output.note_en.blank?
      primary_note = multi_lingual_output_note(
        @nomenclature_change.primary_output,
        event
      )
      if @nomenclature_change.primary_output.needs_public_note?
        @nomenclature_change.primary_output.note_en = primary_note[:en]
        @nomenclature_change.primary_output.note_es = primary_note[:es]
        @nomenclature_change.primary_output.note_fr = primary_note[:fr]
      else
        @nomenclature_change.primary_output.internal_note = primary_note[:en]
      end
    end

    if @nomenclature_change.is_swap? &&
      @nomenclature_change.secondary_output.note_en.blank?
      secondary_note = multi_lingual_output_note(
        @nomenclature_change.secondary_output,
        event
      )
      if @nomenclature_change.secondary_output.needs_public_note?
        @nomenclature_change.secondary_output.note_en = secondary_note[:en]
        @nomenclature_change.secondary_output.note_es = secondary_note[:es]
        @nomenclature_change.secondary_output.note_fr = secondary_note[:fr]
      else
        @nomenclature_change.secondary_output.internal_note = secondary_note[:en]
      end
    end
  end

  def multi_lingual_listing_change_note
    multi_lingual_legislation_note('status_change.listing_change')
  end

  def multi_lingual_suspension_note
    multi_lingual_legislation_note('status_change.suspension')
  end

  def multi_lingual_opinion_note
    multi_lingual_legislation_note('status_change.opinion')
  end

  def multi_lingual_quota_note
    multi_lingual_legislation_note('status_change.quota')
  end

  private

  def input_output_for_reassignment
    input = @nomenclature_change.input
    output = if @nomenclature_change.needs_to_relay_associations?
      @nomenclature_change.secondary_output
    elsif @nomenclature_change.needs_to_receive_associations?
      @nomenclature_change.primary_output
    end
    return false unless input && output
    yield(input, output)
  end

  def legislation_note(lng)
    return nil unless @nomenclature_change.is_swap?
    input = @nomenclature_change.input
    output = if @nomenclature_change.needs_to_relay_associations?
      @nomenclature_change.secondary_output
    elsif @nomenclature_change.needs_to_receive_associations?
      @nomenclature_change.primary_output
    end
    output = taxon_concept_html(output.display_full_name, output.display_rank_name)
    input = taxon_concept_html(input.taxon_concept.full_name, input.taxon_concept.rank.name)
    note = '<p>'
    note << yield(input, output)
    if @nomenclature_change.event
      note << following_taxonomic_changes(@nomenclature_change.event, lng)
    end
    note + '.</p>'
  end

end