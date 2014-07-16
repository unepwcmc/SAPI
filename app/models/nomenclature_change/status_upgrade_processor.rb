class NomenclatureChange::StatusUpgradeProcessor

  def initialize(input_or_output, synonyms = [])
    @input_or_output = input_or_output
    @synonyms = synonyms
    @old_status = @input_or_output.taxon_concept.name_status.dup
  end

  def run
    unless @input_or_output.taxon_concept.name_status == 'A'
      @input_or_output.taxon_concept.update_column(:name_status, 'A')
    end
    if @old_status == 'S'
      # if was S and now is A
      # remove has_synonym associations
      @input_or_output.taxon_concept.inverse_synonym_relationships.
        includes(:taxon_concept).each do |rel|
        Rails.logger.debug "Removing HAS_SYNONYM relationship with #{rel.taxon_concept.full_name}"
        rel.destroy
      end
      has_synonym_rel_type = TaxonRelationshipType.
        find_by_name(TaxonRelationshipType::HAS_SYNONYM)
      # set input_or_input_or_output as accepted name of synonyms
      @synonyms.each do |synonym|
        @input_or_output.taxon_concept.synonym_relationships << TaxonRelationship.new(
          :taxon_relationship_type_id => has_synonym_rel_type.id,
          :other_taxon_concept_id => synonym.taxon_concept.id
        )
      end
      Rails.logger.debug "Updating shipments where reported taxon concept = #{@input_or_output.taxon_concept.full_name} to have taxon concept = #{@input_or_output.taxon_concept.full_name}"
      Trade::Shipment.update_all(
        {taxon_concept_id: @input_or_output.id},
        {reported_taxon_concept_id: @input_or_output.id}
      )
    elsif @old_status == 'T'
      # if was T and now is A
      # remove has_trade_name associations
      @input_or_output.taxon_concept.inverse_trade_name_relationships.
        includes(:taxon_concept).each do |rel|
        Rails.logger.debug "Removing HAS_TRADE_NAME relationship with #{rel.taxon_concept.full_name}"
        rel.destroy
      end
      Rails.logger.debug "Updating shipments where reported taxon concept = #{@input_or_output.taxon_concept.full_name} to have taxon concept = #{@input_or_output.taxon_concept.full_name}"
      Trade::Shipment.update_all(
        {taxon_concept_id: @input_or_output.id},
        {reported_taxon_concept_id: @input_or_output.id}
      )
    end
  end

  def summary
    txt = "#{@input_or_output.taxon_concept.full_name} will be promoted to accepted name"
    unless @synonyms.empty?
      [
        txt + " with the following synonyms:",
        @synonyms.map(&:taxon_concept).map(&:full_name)
      ]
    end
  end

end
