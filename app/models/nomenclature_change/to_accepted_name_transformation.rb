class NomenclatureChange::ToAcceptedNameTransformation
  def initialize(non_accepted_taxon_concept, new_parent)
    @non_accepted_taxon_concept = non_accepted_taxon_concept
    @new_parent = new_parent
  end

  def process
    # destroy any synonym or trade name relationships
    destroy_relationships(
      @non_accepted_taxon_concept.inverse_synonym_relationships
    )
    destroy_relationships(
      @non_accepted_taxon_concept.inverse_trade_name_relationships
    )

    @non_accepted_taxon_concept.update_attributes(
      parent_id: @new_parent.id,
      name_status: 'A'
    )
  end

  def destroy_relationships(relationships)
    relationships.includes(:taxon_concept, :taxon_relationship_type).each do |rel|
      Rails.logger.debug "Removing #{rel.taxon_relationship_type.name} relationship with #{rel.taxon_concept.full_name}"
      rel.destroy
    end
  end
end
