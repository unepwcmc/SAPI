class Species::TaxonConceptPrefixMatcher
  include CacheIterator
  include SearchCache # this provides #cached_results and #cached_total_cnt

  def initialize(options)
    initialize_options(options)
    return [] unless @taxon_concept_query || !@ranks.empty?
    initialize_query
  end

  def results
    @query.limit(@options[:per_page]).
      offset(@options[:per_page] * (@options[:page] - 1)).all
  end

  def total_cnt
    @query.count
  end

  private

  def initialize_options(options)
    @options = Species::SearchParams.sanitize(options)
    @options.keys.each { |k| instance_variable_set("@#{k}", @options[k]) }
  end

  def initialize_query
    @query = MTaxonConcept.order("ARRAY_LENGTH(REGEXP_SPLIT_TO_ARRAY(taxonomic_position,'\.'), 1), full_name")
    unless @ranks.empty?
      @query = @query.where(:rank_name => @ranks)
    end

    @query = if @taxonomy == :cms
      @query.by_cms_taxonomy
    else
      @query.by_cites_eu_taxonomy
    end

    if @taxon_concept_query
      @query = @query.select(
        ActiveRecord::Base.send(:sanitize_sql_array, [
        "id, full_name, rank_name,
        ARRAY_LENGTH(REGEXP_SPLIT_TO_ARRAY(taxonomic_position,'\.'), 1),
        ARRAY(
          SELECT * FROM UNNEST(synonyms_ary) name WHERE UPPER(name) LIKE :sci_name_prefix
        ) AS synonyms_ary",
        :sci_name_prefix => "#{@taxon_concept_query}%"
        ])
      ).
      where([
        "UPPER(full_name) LIKE :sci_name_prefix
        OR
        EXISTS (
          SELECT * FROM UNNEST(synonyms_ary) name WHERE UPPER(name) LIKE :sci_name_prefix
        )
      ", :sci_name_prefix => "#{@taxon_concept_query}%"
      ]).where(:name_status => 'A')
    end
  end

end

