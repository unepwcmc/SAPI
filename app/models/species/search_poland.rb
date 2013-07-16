class Species::Search

  # Constructs a query to retrieve taxon concepts based on user defined
  # parameters
  #
  # @param [Hash] a hash of search params and their values
  def initialize(options)
    @id = 1
    initialize_params(options)
    initialize_query
  end

  def initialize_params(options)
    options = Species::SearchParams.sanitize(options)
    options.keys.each { |k| instance_variable_set("@#{k}", options[k]) }
  end

  def initialize_query
    @taxon_concepts_rel = MTaxonConcept.taxonomic_layout.
      where(:rank_name => [Rank::SPECIES, Rank::SUBSPECIES, Rank::VARIETY])

    @taxon_concepts_rel = if @taxonomy == :cms
      @taxon_concepts_rel.by_cms_taxonomy
    else
      @taxon_concepts_rel.by_cites_eu_taxonomy
    end

    if !@geo_entities.empty? && @geo_entity_scope == :cites
      @taxon_concepts_rel = MTaxonConceptFilterByAppendixPopulationQuery.new(
        @taxon_concepts_rel, ['I', 'II', 'III'], @geo_entities
      ).relation('CITES')
    elsif !@geo_entities.empty? && @geo_entity_scope == :eu
      @taxon_concepts_rel = MTaxonConceptFilterByAppendixPopulationQuery.new(
        @taxon_concepts_rel, ['A', 'B', 'C', 'D'], @geo_entities
      ).relation('EU')
    elsif !@geo_entities.empty? && @geo_entity_scope == :occurrences
      @taxon_concepts_rel = MTaxonConceptFilterByAppendixPopulationQuery.new(
        @taxon_concepts_rel, [], @geo_entities
      ).relation
    end

    unless @scientific_name.blank?
      @taxon_concepts_rel = @taxon_concepts_rel.
        by_scientific_name(@scientific_name)
    end

    sql =<<-SQL
    JOIN (
    WITH RECURSIVE occurrences AS (
    select id, parent_id, full_name, author_year, rank_name, taxonomic_position ,
    
    from taxon_concepts_mview 
    where countries_ids_ary @> ARRAY[253]
    and taxonomy_is_cites_eu

    UNION

    select hi.id, hi.parent_id, hi.full_name, hi.author_year, hi.rank_name, hi.taxonomic_position
    from taxon_concepts_mview hi
    join occurrences on occurrences.parent_id = hi.id
    ) SELECT * FROM occurrences
    ) q ON q.id = taxon_concepts_mview.id

SQL

    @taxon_concepts_rel = MTaxonConcept.joins(sql).order('taxonomic_position')
  end

  def results
    @taxon_concepts_rel
  end

end
