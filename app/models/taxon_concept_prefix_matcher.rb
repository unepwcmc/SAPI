class TaxonConceptPrefixMatcher
  attr_reader :taxon_concepts
  # taxonomy => {:id => x}
  # rank => {:id => x, :scope => [parent|ancestors]}
  # scientific_name
  def initialize(options = {})
    puts options.inspect
    @taxon_concepts = TaxonConcept.where(:name_status => 'A').
      select(
      <<-SQL
      data,
      #{Taxonomy.table_name}.name AS taxonomy_name,
      #{TaxonConcept.table_name}.id,
      full_name
      SQL
      ).
      joins(:taxonomy).order(:full_name)

    @taxonomy_id = options[:taxonomy] && options[:taxonomy][:id]
    if @taxonomy_id
      @taxon_concepts = @taxon_concepts.where(:taxonomy_id => @taxonomy_id)
    end

    @rank_id = options[:rank] && options[:rank][:id]
    if @rank_id
      @scope = options[:rank] && options[:rank][:scope] || 0
      rank = Rank.find(@rank_id) if @scope
      if @scope == :parent
        #search at parent ranks. this includes optional ranks, e.g. subfamily
        @taxon_concepts = @taxon_concepts.at_parent_ranks(rank)
      elsif @scope == :ancestors
        #search at ancestor ranks
        @taxon_concepts = @taxon_concepts.at_ancestor_ranks(rank)
      end
    end

    @taxon_concepts = @taxon_concepts.by_scientific_name(options[:scientific_name])
  end

end