class NomenclatureChange::StatusDowngradeProcessor

  def initialize(input_or_output, accepted_names = [])
    @input_or_output = input_or_output
    @old_status = @input_or_output.taxon_concept.name_status.dup
    @accepted_names = accepted_names
  end

  def run
    @accepted_names = @accepted_names.map{ |an| an.new_taxon_concept || an.taxon_concept }
    # if output given with new taxon concept present, it becomes the accepted name
    if @input_or_output.kind_of?(NomenclatureChange::Output) && @input_or_output.new_taxon_concept
      @accepted_names << @input_or_output.new_taxon_concept
    end
    unless @input_or_output.taxon_concept.name_status == 'S'
      @input_or_output.taxon_concept.update_column(:name_status, 'S')
    end
    has_synonym_rel_type = TaxonRelationshipType.
      find_by_name(TaxonRelationshipType::HAS_SYNONYM)
    if @old_status == 'T'
      # if was a trade name and now is a synonym
      # update has_trade_name associations with has_synonym
      @input_or_output.taxon_concept.inverse_trade_name_relationships.
        includes(:taxon_concept).each do |rel|
        Rails.logger.debug "Changing relationship with #{rel.taxon_concept.full_name} from HAS_TRADE_NAME to HAS_SYNONYM"
        rel.update_attribute(
          :taxon_relationship_type_id, has_synonym_rel_type.id
        )
      end
    else
      # if was A / N and now is S
      # set input_or_output as synonym of accepted_names
      @accepted_names.each do |accepted_name|
        accepted_name.synonym_relationships << TaxonRelationship.new(
          :taxon_relationship_type_id => has_synonym_rel_type.id,
          :other_taxon_concept_id => @input_or_output.taxon_concept_id
        )
      end
      default_accepted_name = @accepted_names.first
      if default_accepted_name
        Rails.logger.debug "Updating shipments where taxon concept = #{@input_or_output.taxon_concept.full_name} to have taxon concept = #{default_accepted_name.full_name}"
        Trade::Shipment.update_all(
          {taxon_concept_id: default_accepted_name.id},
          {taxon_concept_id: @input_or_output.taxon_concept_id}
        )
      end
    end
  end

  def summary
    txt = "#{@input_or_output.taxon_concept.full_name} will be turned into a synonym"
    unless @accepted_names.empty?
      [
        txt + " with the following accepted names:",
        @accepted_names.map(&:taxon_concept).map(&:full_name)
      ]
    else
      [txt]
    end
  end

end
