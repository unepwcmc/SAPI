class NomenclatureChange::StatusUpgradeProcessor < NomenclatureChange::StatusChangeProcessor

  def run
    Rails.logger.debug "#{@input_or_output.taxon_concept.full_name} status upgrade from #{@old_status}"
    @linked_names = @linked_inputs_or_outputs.map do |an|
      an.new_taxon_concept || an.taxon_concept
    end.compact
    if !@input_or_output.taxon_concept.name_status == 'A' &&
      @input_or_output.new_taxon_concept.nil?
      @input_or_output.taxon_concept.update_column(:name_status, 'A')
    end
    if @old_status == 'S'
      run_s_to_a
    elsif @old_status == 'T'
      run_t_to_a
    end
  end

  private

  def summary_line
    "#{@input_or_output.taxon_concept.full_name} will be promoted to accepted name"
  end

  def summary_line_long
    summary_line + " with the following linked names:"
  end

  def run_s_to_a
    # if was S and now is A
    # remove has_synonym associations
    destroy_relationships(
      @input_or_output.taxon_concept.inverse_synonym_relationships
    )
    rel_type = TaxonRelationshipType.
      find_by_name(TaxonRelationshipType::HAS_SYNONYM)
    # set input_or_input_or_output as accepted name of synonyms
    create_inverse_relationships(@input_or_output.taxon_concept, rel_type)
    Rails.logger.debug "Updating shipments where reported taxon concept = #{@input_or_output.taxon_concept.full_name} to have taxon concept = #{@input_or_output.taxon_concept.full_name}"
    Trade::Shipment.update_all(
      {taxon_concept_id: @input_or_output.taxon_concept_id},
      {reported_taxon_concept_id: @input_or_output.taxon_concept_id}
    )
  end

  def run_t_to_a
    # if was T and now is A
    # remove has_trade_name associations
    destroy_relationships(
      @input_or_output.taxon_concept.inverse_trade_name_relationships
    )
    rel_type = TaxonRelationshipType.
      find_by_name(TaxonRelationshipType::HAS_TRADE_NAME)
    # set input_or_input_or_output as accepted name of trade_names
    create_relationships(@input_or_output.taxon_concept, rel_type)
    Rails.logger.debug "Updating shipments where reported taxon concept = #{@input_or_output.taxon_concept.full_name} to have taxon concept = #{@input_or_output.taxon_concept.full_name}"
    Trade::Shipment.update_all(
      {taxon_concept_id: @input_or_output.taxon_concept_id},
      {reported_taxon_concept_id: @input_or_output.taxon_concept_id}
    )
  end

end
