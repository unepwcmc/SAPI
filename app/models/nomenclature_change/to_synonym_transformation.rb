class NomenclatureChange::ToSynonymTransformation
  def initialize(accepted_taxon_concept, new_accepted_name)
    @accepted_taxon_concept = accepted_taxon_concept
    @new_accepted_name = new_accepted_name
  end

  def process
    # any existing synonyms or trade names need to be re-linked with new accepted name
    relink_relationships(
      @accepted_taxon_concept.synonym_relationships, @new_accepted_name
    )
    relink_relationships(
      @accepted_taxon_concept.trade_name_relationships, @new_accepted_name
    )
    # detach from parent and turn into a synonym
    @accepted_taxon_concept.update_attributes(parent_id: nil, name_status: 'S')
    # turn current name into synonym of new name
    rel_type = TaxonRelationshipType.find_by_name(TaxonRelationshipType::HAS_SYNONYM)
    @new_accepted_name.taxon_relationships << TaxonRelationship.new(
      taxon_relationship_type_id: rel_type.id,
      other_taxon_concept_id: @accepted_taxon_concept.id
    )
  end

  def relink_relationships(relationships, new_taxon_concept)
    relationships.includes(:taxon_concept, :taxon_relationship_type).each do |rel|
      Rails.logger.debug "Relinking #{rel.taxon_relationship_type.name} relationship from #{rel.taxon_concept.full_name} to #{new_taxon_concept.full_name}"
      rel.update_attributes(taxon_concept_id: new_taxon_concept.id)
    end
  end

end