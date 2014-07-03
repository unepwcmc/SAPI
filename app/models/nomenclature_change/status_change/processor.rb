class NomenclatureChange::StatusChange::Processor

  def initialize(nc)
    @nc = nc
    @input = nc.input
    @primary_output = nc.primary_output
    @secondary_output = nc.secondary_output
    @swap = @nc.is_swap?
    @primary_old_status = @primary_output.taxon_concept.name_status.dup
    @primary_new_status = @primary_output.new_name_status
    @secondary_old_status = @secondary_output && @secondary_output.taxon_concept.name_status.dup
  end

  def run
    Rails.logger.warn("[#{@nc.type}] BEGIN")
    output = if @nc.needs_to_relay_associations?
      @secondary_output
    elsif @nc.needs_to_receive_associations?
      @primary_output
    end
    Rails.logger.debug("[#{@nc.type}] Processing primary output #{@primary_output.display_full_name}")
    processor = NomenclatureChange::StatusChange::TransformationProcessor.new(@primary_output)
    processor.run
    if @swap
      Rails.logger.debug("[#{@nc.type}] Processing secondary output #{@secondary_output.display_full_name}")
      processor = NomenclatureChange::StatusChange::TransformationProcessor.new(@secondary_output)
      processor.run
    end

    if @input && output
      Rails.logger.debug("[#{@nc.type}] Processing reassignments from #{@input.taxon_concept.full_name}")
      # if input is not one of outputs, that means it only acts as a template
      # for associations and reassignment processor should copy rather than
      # transfer associations
      copy = ![@primary_output, @secondary_output].compact.map(&:taxon_concept).include?(
        @input.taxon_concept
      )
      processor = NomenclatureChange::ReassignmentProcessor.new(@input, output, copy)
      processor.run
    end

    process_status_change
    Rails.logger.warn("[#{@nc.type}] END")
  end

  def process_status_change
    if @primary_new_status == 'A'
      if @primary_old_status == 'S'
        # if was S and now is A
        # remove has_synonym associations
        @primary_output.taxon_concept.inverse_synonym_relationships.includes(:taxon_concept).each do |rel|
          Rails.logger.debug "Removing HAS_SYNONYM relationship with #{rel.taxon_concept.full_name}"
          rel.destroy
        end
        if @swap
          has_synonym_rel_type = TaxonRelationshipType.
            find_by_name(TaxonRelationshipType::HAS_SYNONYM)
          # set secondary output as synonym of primary output
          @primary_output.taxon_concept.synonym_relationships << TaxonRelationship.new(
            :taxon_relationship_type_id => has_synonym_rel_type.id,
            :other_taxon_concept_id => @secondary_output.taxon_concept.id
          )
        end
      elsif @primary_old_status == 'T'
        # if was T and now is A
        # remove has_trade_name associations
        @primary_output.taxon_concept.inverse_trade_name_relationships.includes(:taxon_concept).each do |rel|
          Rails.logger.debug "Removing HAS_TRADE_NAME relationship with #{rel.taxon_concept.full_name}"
          rel.destroy
        end
        if @swap
          Rails.logger.warn "Unexpected status swap with status #{@secondary_old_status}"
        end
      end
    elsif @primary_new_status == 'S'
      if @primary_old_status == 'T'
        # if was a trade name and now is a synonym
        # update has_trade_name associations with has_synonym
        has_synonym_rel_type = TaxonRelationshipType.
          find_by_name(TaxonRelationshipType::HAS_SYNONYM)
        @primary_output.taxon_concept.inverse_trade_name_relationships.
          includes(:taxon_concept).each do |rel|
          Rails.logger.debug "Changing relationship with #{rel.taxon_concept.full_name} from HAS_TRADE_NAME to HAS_SYNONYM"
          rel.update_attribute(
            :taxon_relationship_type_id, has_synonym_rel_type.id
          )
        end
        if @swap
          Rails.logger.warn "Unexpected status swap with status #{@secondary_old_status}"
        end
      else
        # if was A / N and now is S
        # set primary output as synonym of secondary output
        has_synonym_rel_type = TaxonRelationshipType.
          find_by_name(TaxonRelationshipType::HAS_SYNONYM)
        @secondary_output.taxon_concept.synonym_relationships << TaxonRelationship.new(
          :taxon_relationship_type_id => has_synonym_rel_type.id,
          :other_taxon_concept_id => @primary_output.taxon_concept.id
        )
      end
    else
      Rails.logger.warn "Unexpected status change to status #{@primary_new_status}"
    end
  end

end
