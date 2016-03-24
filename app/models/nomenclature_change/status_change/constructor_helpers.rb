module NomenclatureChange::StatusChange::ConstructorHelpers

  def build_primary_output
    if @nomenclature_change.primary_output.nil?
      @nomenclature_change.build_primary_output(
        :is_primary_output => true
      )
    end
  end

  def build_secondary_output
    if @nomenclature_change.secondary_output.nil?
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

  def status_change_note(locale_key, output, lng)
    output_html = taxon_concept_html(
      output.display_full_name,
      output.display_rank_name
    )
    I18n.with_locale(lng) do
      I18n.translate(
        "status_change.#{locale_key}",
        output_taxon: output_html,
        old_status: output.taxon_concept.name_status,
        new_status: output.new_name_status,
        default: 'Translation missing'
      )
    end
  end

  def status_change_from_to(output, lng)
    status_change_note('status_change_from_to', output, lng)
  end

  def status_elevated_to_accepted_name(output, lng)
    status_change_note('status_elevated_to_accepted_name', output, lng)
  end

  def multi_lingual_public_output_note(output, event)
    result = {}
    [:en, :es, :fr].each do |lng|
      result[lng] = public_output_note(output, event, lng)
    end
    result
  end

  def public_output_note(output, event, lng)
    note = '<p>'
    note << status_elevated_to_accepted_name(output, lng)
    note << in_year(event, lng)
    note << following_taxonomic_changes(event, lng) if event
    note << '.</p>'
    note
  end

  def private_output_note(output, event, lng)
    note = '<p>'
    note << status_change_from_to(output, lng)
    note << in_year(event, lng)
    note << following_taxonomic_changes(event, lng) if event
    note << '.</p>'
    note
  end

  def build_primary_output_note
    if @nomenclature_change.primary_output.needs_public_note?
      primary_note = multi_lingual_public_output_note(
        @nomenclature_change.primary_output,
        @event
      )
      @nomenclature_change.primary_output.note_en = primary_note[:en]
      @nomenclature_change.primary_output.note_es = primary_note[:es]
      @nomenclature_change.primary_output.note_fr = primary_note[:fr]
    end
  end

  def build_output_notes
    build_primary_output_note
  end

  def multi_lingual_listing_change_note
    multi_lingual_legislation_note('status_change.listing_change')
  end

  def multi_lingual_suspension_note
    multi_lingual_legislation_note('status_change.suspension')
  end

  alias :multi_lingual_cites_suspension_note :multi_lingual_suspension_note
  alias :multi_lingual_eu_suspension_note :multi_lingual_suspension_note

  def multi_lingual_eu_opinion_note
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
    nil
  end

end
