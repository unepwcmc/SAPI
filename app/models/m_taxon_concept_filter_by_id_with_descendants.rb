class MTaxonConceptFilterByIdWithDescendants

  def initialize(relation = MTaxonConcept.scoped, ids)
    @relation = relation
    @ids = ids
  end

  def relation
    @relation.where(
      <<-SQL
      ARRAY[
        #{@relation.table_name}.id,
        #{@relation.table_name}.family_id, #{@relation.table_name}.order_id,
        #{@relation.table_name}.class_id, #{@relation.table_name}.phylum_id,
        #{@relation.table_name}.kingdom_id] && --overlap
      ARRAY[#{@ids.join(', ')}]
      SQL
    )
  end

end