class NomenclatureChange::StatusChangeProcessor

  def initialize(input_or_output, linked_inputs_or_outputs = [])
    @input_or_output = input_or_output
    @linked_inputs_or_outputs = linked_inputs_or_outputs
    @old_status =
      if @input_or_output.kind_of? NomenclatureChange::Output
        @input_or_output.name_status.dup
      else
        @input_or_output.taxon_concept.name_status.dup
      end
  end

  def summary
    unless @linked_inputs_or_outputs.empty?
      [
        summary_line_long,
        @linked_inputs_or_outputs.map do |l|
          if l.kind_of?(NomenclatureChange::Output)
            l.display_full_name
          elsif l.taxon_concept
            l.taxon_concept.full_name
          else
            l.new_full_name
          end
        end.compact
      ]
    else
      [summary_line]
    end + [
      "#{@trade_to_reassign.count} shipments will be reassigned
      from #{@where_to_reassign_trade_from.taxon_concept.full_name}
      to #{@where_to_reassign_trade_to.display_full_name}
      (accepted taxon concept)"
    ]
  end

  private

  def create_relationships(taxon_concept, rel_type)
    @linked_names.each do |linked_name|
      Rails.logger.debug "Creating #{rel_type.name} relationship with #{linked_name.full_name}"
      taxon_concept.taxon_relationships << TaxonRelationship.new(
        :taxon_relationship_type_id => rel_type.id,
        :other_taxon_concept_id => linked_name.id
      )
    end
  end

  def create_inverse_relationships(taxon_concept, rel_type)
    @linked_names.each do |linked_name|
      Rails.logger.debug "Creating #{rel_type.name} inverse relationship with #{linked_name.full_name}"
      linked_name.taxon_relationships << TaxonRelationship.new(
        :taxon_relationship_type_id => rel_type.id,
        :other_taxon_concept_id => taxon_concept.id
      )
    end
  end

  def destroy_relationships(relationships)
    relationships.includes(:taxon_concept, :taxon_relationship_type).each do |rel|
      Rails.logger.debug "Removing #{rel.taxon_relationship_type.name} relationship with #{rel.taxon_concept.full_name}"
      rel.destroy
    end
  end

end
