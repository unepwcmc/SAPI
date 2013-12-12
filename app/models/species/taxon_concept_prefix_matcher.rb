class Species::TaxonConceptPrefixMatcher
  include CacheIterator
  include SearchCache # this provides #cached_results and #cached_total_cnt

  def initialize(options)
    initialize_options(options)
    initialize_query
  end

  def results
    (@taxon_concept_query || !@ranks.empty?) &&
    @query.limit(@options[:per_page]).
      offset(@options[:per_page] * (@options[:page] - 1)).all || []
  end

  def total_cnt
    (@taxon_concept_query || !@ranks.empty?) && @query.count || 0
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

    @query = if @from_checklist
      @query.without_hidden
    else
      @query.without_hidden_subspecies
    end

    if @taxon_concept_query
      @query = @query.select(
        ActiveRecord::Base.send(:sanitize_sql_array, [
        "id, full_name, rank_name,
        ARRAY_LENGTH(REGEXP_SPLIT_TO_ARRAY(taxonomic_position,'\.'), 1),
        ARRAY(
          SELECT * FROM UNNEST(synonyms_ary) name WHERE UPPER(name) LIKE :sci_name_prefix
        ) AS synonyms_ary,
        ARRAY(
          SELECT * FROM UNNEST(english_names_ary) name WHERE UPPER(name) LIKE :sci_name_infix
        ) AS english_names_ary,
        ARRAY(
          SELECT * FROM UNNEST(french_names_ary) name WHERE UPPER(name) LIKE :sci_name_prefix
        ) AS french_names_ary,
        ARRAY(
          SELECT * FROM UNNEST(spanish_names_ary) name WHERE UPPER(name) LIKE :sci_name_prefix
        ) AS spanish_names_ary",
        :sci_name_prefix => "#{@taxon_concept_query}%", :sci_name_infix => "%#{@taxon_concept_query}%"
        ])
      ).
      where([
        "UPPER(full_name) LIKE :sci_name_prefix
        OR
        EXISTS (
          SELECT * FROM UNNEST(synonyms_ary) name WHERE UPPER(name) LIKE :sci_name_prefix
          UNION
          SELECT * FROM UNNEST(english_names_ary) name WHERE UPPER(name) LIKE :sci_name_infix
          UNION
          SELECT * FROM UNNEST(french_names_ary) name WHERE UPPER(name) LIKE :sci_name_prefix
          UNION
          SELECT * FROM UNNEST(spanish_names_ary) name WHERE UPPER(name) LIKE :sci_name_prefix
        )
      ", :sci_name_prefix => "#{@taxon_concept_query}%", :sci_name_infix => "%#{@taxon_concept_query}%"
      ]).where(:name_status => 'A')
    end
  end

end

