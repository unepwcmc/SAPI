class NomenclatureChange::StatusSwap::Constructor
  include NomenclatureChange::ConstructorHelpers
  include NomenclatureChange::StatusChange::ConstructorHelpers

  def initialize(nomenclature_change)
    @nomenclature_change = nomenclature_change
    @event = @nomenclature_change.event
  end

  def build_output_notes
    build_new_accepted_name_note
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
    note << in_year(@event, lng)
    if @event
      note << following_taxonomic_changes(@event, lng)
    end
    note + '.</p>'
  end

end
