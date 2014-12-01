class NomenclatureChange::StatusSwap::Constructor
  include NomenclatureChange::ConstructorHelpers
  include NomenclatureChange::StatusChange::ConstructorHelpers

  def initialize(nomenclature_change)
    @nomenclature_change = nomenclature_change
    @event = @nomenclature_change.event
  end

  def build_secondary_output_note
    if @nomenclature_change.secondary_output.note_en.blank?
      if @nomenclature_change.secondary_output.needs_public_note?
        secondary_note = multi_lingual_public_output_note(
          @nomenclature_change.secondary_output,
          @event
        )
        @nomenclature_change.secondary_output.note_en = secondary_note[:en]
        @nomenclature_change.secondary_output.note_es = secondary_note[:es]
        @nomenclature_change.secondary_output.note_fr = secondary_note[:fr]
      else
        secondary_note = private_output_note(
          @nomenclature_change.secondary_output,
          @event,
          :en
        )
        @nomenclature_change.secondary_output.internal_note = secondary_note
      end
    end
  end

  def build_output_notes
    build_primary_output_note
    build_secondary_output_note
  end

  private
  def legislation_note(lng)
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
    if @event
      note << following_taxonomic_changes(@event, lng)
    end
    note + '.</p>'
  end

end
