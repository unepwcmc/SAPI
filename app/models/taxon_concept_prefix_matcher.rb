class TaxonConceptPrefixMatcher < TaxonConceptMatcher

  def initialize(search_params)
    super
    @rank_options = search_params.rank
    @taxon_concept_options = search_params.taxon_concept
  end

  protected

  def build_rel
    super
    apply_rank_options_to_rel
    apply_taxon_concept_options_to_rel
  end

  def initialize_rel
    super.
    select(
      <<-SQL
        data,
        taxonomy_id,
        #{Taxonomy.table_name}.name AS taxonomy_name,
        #{TaxonConcept.table_name}.id,
        full_name,
        name_status
      SQL
    ).
    joins(:taxonomy).order(:full_name)
  end

  def apply_rank_options_to_rel
    @rank_id = @rank_options && @rank_options[:id]
    if @rank_id
      @rank_scope = @rank_options[:scope] || ''
      rank = Rank.find(@rank_id) if @rank_scope
      if @rank_scope.to_sym == :parent
        # search at parent ranks. this includes optional ranks, e.g. subfamily
        @taxon_concepts = @taxon_concepts.at_parent_ranks(rank)
      elsif @rank_scope.to_sym == :ancestors
        # search at ancestor ranks
        @taxon_concepts = @taxon_concepts.at_ancestor_ranks(rank)
      elsif @rank_scope.to_sym == :self_and_ancestors
        # search at self and ancestor ranks
        @taxon_concepts = @taxon_concepts.at_self_and_ancestor_ranks(rank)
      end
    end
  end

  def apply_taxon_concept_options_to_rel
    @taxon_concept_id = @taxon_concept_options && @taxon_concept_options[:id]
    if @taxon_concept_id
      @taxon_concept_scope = @taxon_concept_options[:scope] || ''
      taxon_concept = TaxonConcept.find(@taxon_concept_id) if @taxon_concept_scope
      if @taxon_concept_scope.to_sym == :ancestors
        @taxon_concepts = @taxon_concepts.joins(
          <<-SQL
          INNER JOIN (
            WITH RECURSIVE node AS (
              SELECT h.id, h.parent_id
              FROM taxon_concepts h
              WHERE id = #{taxon_concept.parent_id}

              UNION ALL

              SELECT hi.id, hi.parent_id
              FROM node
              JOIN taxon_concepts hi
              ON hi.id = node.parent_id
            )
            SELECT id FROM node
          ) ancestors
          ON ancestors.id = taxon_concepts.id
          SQL
        )

      elsif @taxon_concept_scope.to_sym == :descendants
        @taxon_concepts = @taxon_concepts.joins(
          <<-SQL
          INNER JOIN (
            WITH RECURSIVE node AS (
              SELECT h.id
              FROM taxon_concepts h
              WHERE parent_id = #{taxon_concept.id}

              UNION ALL

              SELECT hi.id
              FROM node
              JOIN taxon_concepts hi
              ON hi.parent_id = node.id
            )
            SELECT id FROM node
          ) descendants
          ON descendants.id = taxon_concepts.id
          SQL
        )
      end
    end
  end

end
