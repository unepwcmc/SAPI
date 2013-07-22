class MTaxonConceptFilterByIdWithDescendants

  def initialize(relation, ids)
    @relation = relation || MTaxonConcept.scoped
    @ids = ids
  end

  def relation
    @relation.where(
      <<-SQL
      ARRAY[
        taxon_concepts_mview.id,
        taxon_concepts_mview.family_id, taxon_concepts_mview.order_id,
        taxon_concepts_mview.class_id, taxon_concepts_mview.phylum_id,
        taxon_concepts_mview.kingdom_id] && --overlap
      ARRAY[#{@ids.join(', ')}]
      SQL
    )
  end

end