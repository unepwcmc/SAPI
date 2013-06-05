class Species::Search
  include ActiveModel::SerializerSupport
  attr_reader :id, :results, :result_cnt, :total_cnt

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
    @taxon_concepts_rel = MTaxonConcept.alphabetical_layout

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

 # Takes the current search query, paginates it and adds metadata
  #
  # @param [Integer] page the current page number to offset by
  # @param [Integer] per_page the number of results per page
  # @return [Array] an array containing a hash of search results and
  #   related metadata
  def generate(page, per_page)
    page ||= 0
    per_page ||= 20
    @total_cnt = @taxon_concepts_rel.count
    @taxon_concepts_rel = @taxon_concepts_rel.limit(per_page).offset(per_page.to_i * page.to_i)
    @results = @taxon_concepts_rel.all
    @result_cnt = @results.length
    self
  end

end
