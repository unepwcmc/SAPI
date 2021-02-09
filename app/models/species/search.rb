class Species::Search
  include CacheIterator
  include SearchCache # this provides #cached_results and #cached_total_cnt
  attr_reader :page, :per_page

  # Constructs a query to retrieve taxon concepts based on user defined
  # parameters
  #
  # @param [Hash] a hash of search params and their values
  def initialize(options)
    initialize_params(options)
    initialize_query
  end

  def results
    @query.limit(@per_page).
      offset(@per_page * (@page - 1)).to_a
  end

  def total_cnt
    @query.count
  end

  def ids
    @query.pluck(:id)
  end

  private

  def initialize_params(options)
    @options = Species::SearchParams.sanitize(options)
    @options.keys.each { |k| instance_variable_set("@#{k}", @options[k]) }
    @scientific_name = @taxon_concept_query
  end

  def initialize_query
    @query = MTaxonConcept.taxonomic_layout

    @query =
      if @taxonomy == :cms
        @query.by_cms_taxonomy
      else
        @query.by_cites_eu_taxonomy
      end

    if @visibility == :speciesplus
      @query = @query.where(:show_in_species_plus => true)
    elsif @visibility == :elibrary
      @query = @query.where("show_in_species_plus OR name_status = 'N'")
    end

    if !@geo_entities.empty? && @geo_entity_scope == :cms
      @query = MTaxonConceptFilterByAppendixPopulationQuery.new(
        @query, ['I', 'II'], @geo_entities
      ).relation('CMS')
    elsif !@geo_entities.empty? && @geo_entity_scope == :cites
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
        by_name(@scientific_name, { :synonyms => true, :subspecies => true, :common_names => true }).
        select(
          "taxon_concepts_mview.*, matching_names.matched_names_ary AS synonyms_ary"
        )
    end
    @query = @query
  end

end
