class Checklist::TaxonConceptPrefixMatcher
  include CacheIterator
  include SearchCache # this provides #cached_results and #cached_total_cnt

  def initialize(options)
    @options = options
    @scientific_name = options[:scientific_name]
    initialize_query
  end

  def results
    @scientific_name && @query.limit(@options[:per_page]).all || []
  end

  def total_cnt
    @scientific_name && @query.count || 0
  end

  protected

  def initialize_query
    @query = MTaxonConcept.by_cites_eu_taxonomy.without_non_accepted.without_hidden
    if @scientific_name
      @scientific_name = @scientific_name.upcase.chomp
      @query = @query.select(
        ActiveRecord::Base.send(:sanitize_sql_array, [
        "DISTINCT id, ARRAY_LENGTH(REGEXP_SPLIT_TO_ARRAY(taxonomic_position,'\.'), 1),
        full_name, rank_name,
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
        :sci_name_prefix => "#{@scientific_name}%", :sci_name_infix => "%#{@scientific_name}%"
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
      ", :sci_name_prefix => "#{@scientific_name}%", :sci_name_infix => "%#{@scientific_name}%"
      ]).order("ARRAY_LENGTH(REGEXP_SPLIT_TO_ARRAY(taxonomic_position,'.'), 1), full_name")
    end
  end
end

