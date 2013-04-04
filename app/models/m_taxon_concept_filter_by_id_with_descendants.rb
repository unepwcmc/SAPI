class MTaxonConceptFilterByIdWithDescendants

  def initialize(relation = MTaxonConcept.scoped, ids)
    @relation = relation
    @ids = ids
  end

  def relation
    @relation.where(
      <<-SQL
      ARRAY[#{@relation.table_name}.id, family_id, order_id, class_id, phylum_id, kingdom_id] @>
      ARRAY[#{ids.join(', ')}]
      SQL
    )
  end

end