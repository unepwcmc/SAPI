class NomenclatureChange::StatusSwap::Constructor
  include NomenclatureChange::ConstructorHelpers
  include NomenclatureChange::StatusChange::ConstructorHelpers

  def initialize(nomenclature_change)
    @nomenclature_change = nomenclature_change
    @event = @nomenclature_change.event
  end

  def build_secondary_output_note
    secondary_note = multi_lingual_public_output_note(
      @nomenclature_change.secondary_output,
      @nomenclature_change.primary_output,
      @event
    )
    @nomenclature_change.secondary_output.note_en = secondary_note[:en]
    @nomenclature_change.secondary_output.note_es = secondary_note[:es]
    @nomenclature_change.secondary_output.note_fr = secondary_note[:fr]
  end

  private

  def legislation_note(lng)
    input = @nomenclature_change.input
    output = @nomenclature_change.secondary_output
    output = taxon_concept_html(output.display_full_name, output.display_rank_name)
    input = taxon_concept_html(input.taxon_concept.full_name, input.taxon_concept.rank.name)
    note = '<p>'
    note << yield(input, output)
    note << in_year(@event, lng)
    if @event
      note << following_taxonomic_changes(@event, lng)
    end
    note + '.</p>'
  end

end
