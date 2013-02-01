class TaxonConceptPrefixMatcher
  attr_reader :taxon_concepts
  # 'taxonomy' => {'id' => x}
  # 'rank' => {'id' => x, 'scope' => [parent|ancestors]}
  # 'taxon_concept' => {'id' => x, 'scope' => [ancestors]}
  # 'scientific_name'
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

    @taxonomy_id = options['taxonomy'] && options['taxonomy']['id']
    if @taxonomy_id
      @taxon_concepts = @taxon_concepts.where(:taxonomy_id => @taxonomy_id)
    end

    @rank_id = options['rank'] && options['rank']['id']
    if @rank_id
      @rank_scope = options['rank']['scope'] || 0
      rank = Rank.find(@rank_id) if @rank_scope
      if @rank_scope == 'parent'
        #search at parent ranks. this includes optional ranks, e.g. subfamily
        @taxon_concepts = @taxon_concepts.at_parent_ranks(rank)
      elsif @rank_scope == 'ancestors'
        #search at ancestor ranks
        @taxon_concepts = @taxon_concepts.at_ancestor_ranks(rank)
      end
    end

    @taxon_concept_id = options['taxon_concept'] && options['taxon_concept']['id']
    if @taxon_concept_id
      @taxon_concept_scope = options['taxon_concept']['scope'] || 0
      taxon_concept = TaxonConcept.find(@taxon_concept_id) if @taxon_concept_scope
      if @taxon_concept_scope == 'ancestors'
        #search ancestors
        @taxon_concepts = @taxon_concepts.where([
          "lft < ? AND rgt > ?", taxon_concept.lft, taxon_concept.rgt
        ])
      end
    end

    @taxon_concepts = @taxon_concepts.by_scientific_name(options['scientific_name'])
  end

end