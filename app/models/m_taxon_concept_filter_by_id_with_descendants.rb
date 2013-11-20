class MTaxonConceptFilterByIdWithDescendants

  def initialize(relation, ids)
    @relation = relation || MTaxonConcept.scoped
    @ids = ids
    @table = @relation.from_value || 'taxon_concepts_mview'
  end

  def relation
    @relation.where(
      <<-SQL
      ARRAY[
        #{@table}.id, #{@table}.genus_id,
        #{@table}.family_id, #{@table}.order_id,
        #{@table}.class_id, #{@table}.phylum_id,
        #{@table}.kingdom_id] && --overlap
      ARRAY[#{@ids.join(', ')}]
      SQL
    )
  end

end