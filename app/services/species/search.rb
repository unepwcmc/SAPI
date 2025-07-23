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
    @query.count(:all)
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

    @query =
      self.class.apply_geo_entities_filter(
        self.class.apply_visibility_filter(@query, @visibility),
        @geo_entities,
        @geo_entity_scope
      )

    if @scientific_name.present?
      @query = @query.
        by_name(@scientific_name, { synonyms: true, subspecies: true, common_names: true }).
        select(
          'taxon_concepts_mview.*, matching_names.matched_names_ary AS synonyms_ary'
        )
    end
    @query = @query
  end

  def self.apply_visibility_filter(original_query, visibility)
    if visibility == :speciesplus
      return original_query.where(show_in_species_plus: true)
    elsif visibility == :elibrary
      return original_query.where("show_in_species_plus OR name_status = 'N'")
    end

    original_query
  end

  def self.apply_geo_entities_filter(
    original_query, geo_entities, geo_entity_scope
  )
    if geo_entities.blank?
      return original_query
    end

    if geo_entity_scope == :cms
      MTaxonConceptFilterByAppendixPopulationQuery.new(
        original_query, [ 'I', 'II' ], geo_entities
      ).relation('CMS')
    elsif geo_entity_scope == :cites
      MTaxonConceptFilterByAppendixPopulationQuery.new(
        original_query, [ 'I', 'II', 'III' ], geo_entities
      ).relation('CITES')
    elsif geo_entity_scope == :eu
      MTaxonConceptFilterByAppendixPopulationQuery.new(
        original_query, [ 'A', 'B', 'C', 'D' ], geo_entities
      ).relation('EU')
    elsif geo_entity_scope == :occurrences
      MTaxonConceptFilterByAppendixPopulationQuery.new(
        original_query, [], geo_entities
      ).relation
    end
  end
end
