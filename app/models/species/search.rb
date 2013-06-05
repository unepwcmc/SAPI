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
  end

  def results
    @taxon_concepts_rel
  end

end
