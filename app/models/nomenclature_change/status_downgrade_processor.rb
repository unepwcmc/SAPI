class NomenclatureChange::StatusDowngradeProcessor < NomenclatureChange::StatusChangeProcessor

  def initialize(input_or_output, linked_inputs_or_outputs = [])
    super(input_or_output, linked_inputs_or_outputs)
    @where_to_reassign_trade_from = @input_or_output
    @where_to_reassign_trade_to = @linked_inputs_or_outputs.first ||
      @input_or_output.kind_of?(NomenclatureChange::Output) &&
      @input_or_output.will_create_taxon? &&
      @input_or_output
    @trade_to_reassign = Trade::Shipment.where([
      "taxon_concept_id = :taxon_concept_id OR
      reported_taxon_concept_id = :taxon_concept_id",
      taxon_concept_id: @where_to_reassign_trade_from.taxon_concept_id
    ])
  end

  def run
    Rails.logger.debug "#{@input_or_output.taxon_concept.full_name} status downgrade from #{@old_status}"
    @linked_names = @linked_inputs_or_outputs.map do |an|
      an.new_taxon_concept || an.taxon_concept
    end.compact
    # if output given with new taxon concept present, it becomes the accepted name
    if @input_or_output.kind_of?(NomenclatureChange::Output) && @input_or_output.new_taxon_concept
      @linked_names << @input_or_output.new_taxon_concept
    end

    TaxonConcept.where(id: @input_or_output.taxon_concept_id).update_all(
      name_status: 'S'
    )

    if @old_status == 'T'
      run_t_to_s
    else
      run_an_to_s
    end

    default_accepted_name = @where_to_reassign_trade_to.kind_of?(NomenclatureChange::Output) &&
      @where_to_reassign_trade_to.new_taxon_concept ||
      @where_to_reassign_trade_to.taxon_concept
    if default_accepted_name
      Rails.logger.debug "Updating shipments to have taxon concept = #{default_accepted_name.full_name}"
      @trade_to_reassign.update_all(taxon_concept_id: default_accepted_name.id)
    end
  end

  private

  def summary_line
    "#{@input_or_output.taxon_concept.full_name} will be turned into a synonym"
  end

  def summary_line_long
    summary_line + " with the following accepted names:"
  end

  def run_t_to_s
    # if was a trade name and now is a synonym
    # remove has_trade_name associations
    old_accepted_names = @input_or_output.taxon_concept.accepted_names_for_trade_name.all
    destroy_relationships(
      @input_or_output.taxon_concept.inverse_trade_name_relationships
    )
    rel_type = TaxonRelationshipType.
      find_by_name(TaxonRelationshipType::HAS_SYNONYM)
    # set input_or_output as synonym of linked names
    create_inverse_relationships(@input_or_output.taxon_concept, rel_type)
  end

  def run_an_to_s
    # if was A / N and now is S
    # remove has_synonym associations
    destroy_relationships(
      @input_or_output.taxon_concept.synonym_relationships
    )
    # remove has_trade_name associations
    destroy_relationships(
      @input_or_output.taxon_concept.trade_name_relationships
    )
    rel_type = TaxonRelationshipType.
      find_by_name(TaxonRelationshipType::HAS_SYNONYM)
    # set input_or_output as synonym of linked names
    create_inverse_relationships(@input_or_output.taxon_concept, rel_type)
  end

end
