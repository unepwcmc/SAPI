class NomenclatureChange::StatusToSynonym::Constructor
  include NomenclatureChange::ConstructorHelpers
  include NomenclatureChange::StatusChange::ConstructorHelpers

  def initialize(nomenclature_change)
    @nomenclature_change = nomenclature_change
    @event = @nomenclature_change.event
  end

  def build_secondary_output
    if @nomenclature_change.secondary_output.nil?
      secondary_output_tc =
        if @nomenclature_change.requires_accepted_name_assignment?
          primary_output_tc = @nomenclature_change.primary_output.try(:taxon_concept)
          primary_output_tc && primary_output_tc.accepted_names_for_trade_name.first
        end
      @nomenclature_change.build_secondary_output(
        is_primary_output: false,
        taxon_concept_id: secondary_output_tc.try(:id)
      )
    end
  end

end
