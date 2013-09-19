class Species::Search
  include CacheIterator
  include SearchCache # this provides #cached_results and #cached_total_cnt

  # Constructs a query to retrieve taxon concepts based on user defined
  # parameters
  #
  # @param [Hash] a hash of search params and their values
  def initialize(options)
    @id = 1
    initialize_params(options)
    initialize_query
  end

  def results
    @query.limit(@options[:per_page]).offset(@options[:page]).all
  end

  def total_cnt
    @query.count
  end

private

  def initialize_params(options)
    @options = Species::SearchParams.sanitize(options)
    @options.keys.each { |k| instance_variable_set("@#{k}", @options[k]) }
    @scientific_name = @taxon_concept_query
  end

  def initialize_query
    @query = MTaxonConcept.taxonomic_layout.
      where(:rank_name => @ranks, :name_status => 'A')

    @query = if @taxonomy == :cms
      @query.by_cms_taxonomy
    else
      @query.by_cites_eu_taxonomy
    end

    if !@geo_entities.empty? && @geo_entity_scope == :cites
      @query = MTaxonConceptFilterByAppendixPopulationQuery.new(
        @query, ['I', 'II', 'III'], @geo_entities
      ).relation('CITES')
    elsif !@geo_entities.empty? && @geo_entity_scope == :eu
      @query = MTaxonConceptFilterByAppendixPopulationQuery.new(
        @query, ['A', 'B', 'C', 'D'], @geo_entities
      ).relation('EU')
    elsif !@geo_entities.empty? && @geo_entity_scope == :occurrences
      @query = MTaxonConceptFilterByAppendixPopulationQuery.new(
        @query, [], @geo_entities
      ).relation
    end

    unless @scientific_name.blank?
      @query = @query.
        by_name(@scientific_name, {:synonyms => true, :subspecies => true, :common_names => false}).
        select(<<-SQL
                taxon_concepts_mview.*,
                ARRAY(
                  SELECT * FROM UNNEST(synonyms_ary) name WHERE name ILIKE '#{@scientific_name}%'
                ) AS synonyms_ary
               SQL
        )
    end
    @query = @query
  end

end
