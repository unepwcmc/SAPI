class MTaxonConceptFilterByIdWithDescendants

  def initialize(relation, ids)
    @relation = relation || MTaxonConcept.all
    @ids = ids
    @table = @relation.from_value ? @relation.from_value.first : 'taxon_concepts_mview'
  end

  def relation(ancestor_ranks = nil)
    ancestor_ranks ||= [
      Rank::GENUS, Rank::FAMILY, Rank::ORDER, Rank::CLASS, Rank::PHYLUM,
      Rank::KINGDOM
    ] # TODO: SUBFAMILY is missing here. we don't have it in listings mviews.
    fields_to_check = (
      [:id] +
      ancestor_ranks.map { |r| "#{r.downcase}_id" }
    ).map { |c| "#{@table}.#{c}" }
    @relation.where(
      <<-SQL
      ARRAY[#{fields_to_check.join(', ')}] &&
      ARRAY[#{@ids.join(', ')}]
      SQL
    )
  end

end
