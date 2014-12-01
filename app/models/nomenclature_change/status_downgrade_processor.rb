class NomenclatureChange::StatusDowngradeProcessor < NomenclatureChange::StatusChangeProcessor

  def run
    Rails.logger.debug "#{@input_or_output.taxon_concept.full_name} status downgrade from #{@old_status}"
    @linked_names = @linked_inputs_or_outputs.map do |an|
      an.new_taxon_concept || an.taxon_concept
    end.compact
    # if output given with new taxon concept present, it becomes the accepted name
    if @input_or_output.kind_of?(NomenclatureChange::Output) && @input_or_output.new_taxon_concept
      @linked_names << @input_or_output.new_taxon_concept
    end
    higher_taxa_hstore_fields = Rank.in_range(nil, nil).map do |r|
      ["#{r.downcase}_id", "#{r.downcase}_name"]
    end.flatten
    new_data = @input_or_output.taxon_concept.data &&
      @input_or_output.taxon_concept.data.except(*higher_taxa_hstore_fields) ||
      {}

    # work-around to avoid 3 separate update_column calls
    TaxonConcept.where(id: @input_or_output.taxon_concept_id).update_all(
      name_status: 'S',
      parent_id: nil,
      data: ActiveRecord::Coders::Hstore.dump(
        new_data
      )
    )

    if @old_status == 'T'
      run_t_to_s
    else
      run_an_to_s
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
    destroy_relationships(
      @input_or_output.taxon_concept.inverse_trade_name_relationships
    )
    rel_type = TaxonRelationshipType.
      find_by_name(TaxonRelationshipType::HAS_SYNONYM)
    # set input_or_output as synonym of linked names
    create_inverse_relationships(@input_or_output.taxon_concept, rel_type)
    default_accepted_name = @linked_names.first
    if default_accepted_name
      update_shipments(@input_or_output.taxon_concept, default_accepted_name)
    end
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
    default_accepted_name = @linked_names.first
    if default_accepted_name
      update_shipments(@input_or_output.taxon_concept, default_accepted_name)
    end
  end

  def update_shipments(old_taxon_concept, new_taxon_concept)
    Rails.logger.debug "Updating shipments where taxon concept = #{old_taxon_concept.full_name} to have taxon concept = #{new_taxon_concept.full_name}"
    Trade::Shipment.update_all(
      {taxon_concept_id: new_taxon_concept.id},
      {taxon_concept_id: old_taxon_concept.id}
    )
  end

end
