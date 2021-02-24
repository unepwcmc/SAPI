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
      offset(@options[:per_page] * (@options[:page] - 1)).to_a || []
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
    @query = MAutoCompleteTaxonConcept.all

    @query =
      if @visibility == :trade
        @query.order(:full_name)
      else
        @query.order([:rank_order, :full_name])
      end

    unless @ranks.empty?
      @query = @query.where(:rank_name => @ranks)
    end

    @query =
      if @taxonomy == :cms
        @query.by_cms_taxonomy
      else
        @query.by_cites_eu_taxonomy
      end

    @query =
      if @visibility == :trade_internal && @include_synonyms
        @query # no filter on name_status for internal search on reported taxon
      elsif @visibility == :trade_internal && !@include_synonyms
        @query.where(:show_in_trade_internal_ac => true)
      elsif @visibility == :trade
        @query.where(:show_in_trade_ac => true)
      elsif @visibility == :elibrary
        @query.where("show_in_species_plus_ac OR name_status = 'N'")
      else
        @query.where(:show_in_species_plus_ac => true)
      end

    # different types of name matching are required
    # in Species+ & Checklist the name may match any of: scientific name, synonyms,
    # common names as well as not CITES listed subspecies
    # in trade dropdowns the matching on subspecies does not occur
    # in addition, the 'reported taxon' in internal trade matches only on self
    types_of_match =
      if @visibility == :trade_internal && @include_synonyms
        ['SELF']
      elsif [:trade_internal, :trade].include? @visibility
        ['SELF', 'SYNONYM', 'COMMON_NAME']
      else
        ['SELF', 'SYNONYM', 'COMMON_NAME', 'SUBSPECIES']
      end

    @query = @query.
      select('id, full_name, rank_name, name_status,
        ARRAY_AGG_NOTNULL(
          DISTINCT CASE
            WHEN matched_name != full_name THEN matched_name ELSE NULL
          END
          ORDER BY CASE
            WHEN matched_name != full_name THEN matched_name ELSE NULL
          END
        ) AS matching_names_ary,
        rank_display_name_en, rank_display_name_es, rank_display_name_fr').
      where(type_of_match: types_of_match).
      group([
        :id, :full_name, :rank_name, :name_status, :rank_order,
        :rank_display_name_en, :rank_display_name_es, :rank_display_name_fr
      ])

    if @taxon_concept_query
      @query = @query.where(
        ActiveRecord::Base.send(:sanitize_sql_array, [
          "name_for_matching LIKE :sci_name_prefix",
          :sci_name_prefix => "#{@taxon_concept_query}%"
        ])
      )
    end
    @query
  end

end
