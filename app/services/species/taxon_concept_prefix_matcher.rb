class Species::TaxonConceptPrefixMatcher
  include CacheIterator
  include SearchCache # this provides #cached_results and #cached_total_cnt

  def initialize(options)
    initialize_options(options)
    initialize_query
  end

  def text_search_strategies
    @text_search_strategies ||= detect_match_strategies @taxon_concept_query

    @text_search_strategies
  end

  def results
    (
      (
        text_search_strategies[:prefix_match] || text_search_strategies[:full_text_match] || !@ranks.empty?
      ) && @query.limit(
        @options[:per_page]
      ).offset(
        @options[:per_page] * (@options[:page] - 1)
      ).to_a
    ) || []
  end

  def total_cnt
    if text_search_strategies[:prefix_match] || text_search_strategies[:full_text_match] || !@ranks.empty?
      @query.count(:all) || 0
    else
      0
    end
  end

private

  def initialize_options(options)
    @options = Species::SearchParams.sanitize(options)
    @options.keys.each { |k| instance_variable_set("@#{k}", @options[k]) }
  end

  def initialize_query
    @query = MAutoCompleteTaxonConcept.all

    unless @ranks.empty?
      @query = @query.where(rank_name: @ranks)
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
        @query.where(show_in_trade_internal_ac: true)
      elsif @visibility == :trade
        @query.where(show_in_trade_ac: true)
      elsif @visibility == :checklist
        @query.where(show_in_checklist_ac: true)
      elsif @visibility == :elibrary
        @query.where("show_in_species_plus_ac OR name_status = 'N'")
      else
        @query.where(show_in_species_plus_ac: true)
      end

    @query =
      if text_search_strategies[:full_text_match]
        @query.where_substring_matches @taxon_concept_query
      elsif text_search_strategies[:prefix_match]
        @query.where_prefix_matches @taxon_concept_query
      else
        @query.where 'FALSE'
      end

    desired_order =
      if @visibility == :trade
        [ :full_name ]
      else
        [ :rank_order, :full_name ]
      end

    # Important to set @query and not just return it
    @query = apply_match_types(@query).reorder(desired_order)

    @query
  end

private

  def apply_match_types(original_query, also_group = [])
    # different types of name matching are required
    # in Species+ & Checklist the name may match any of: scientific name, synonyms,
    # common names as well as not CITES listed subspecies
    # in trade dropdowns the matching on subspecies does not occur
    # in addition, the 'reported taxon' in internal trade matches only on self
    types_of_match =
      if @visibility == :trade_internal && @include_synonyms
        [ 'SELF' ]
      elsif [ :trade_internal, :trade ].include? @visibility
        [ 'SELF', 'SYNONYM', 'COMMON_NAME' ]
      else
        [ 'SELF', 'SYNONYM', 'COMMON_NAME', 'SUBSPECIES' ]
      end

    original_query.reselect(
      <<-SQL.squish
        id, full_name, rank_name, name_status, author_year,
        ARRAY_AGG_NOTNULL(
          DISTINCT CASE
            WHEN matched_name != full_name THEN matched_name ELSE NULL
          END
          ORDER BY CASE
            WHEN matched_name != full_name THEN matched_name ELSE NULL
          END
        ) AS matching_names_ary,
        rank_display_name_en, rank_display_name_es, rank_display_name_fr
      SQL
    ).where(
      type_of_match: types_of_match
    ).group(
      [
        :id, :full_name, :rank_name, :name_status, :author_year, :rank_order,
        :rank_display_name_en, :rank_display_name_es, :rank_display_name_fr
      ]
    )
  end

private

  ##
  # Determine which matching strategy should be applied, based on the length of the text and the
  # script of the characters within it:
  #
  # - prefix_match
  # - full_text_match: full-text searching
  #
  # See detect_script_type for more.
  def detect_match_strategies (text)
    trimmed_text = (text || '').squish

    match_options = detect_script_type trimmed_text

    {
      prefix_match: match_options[:min_prefix_match] && trimmed_text.size >= match_options[:min_prefix_match],
      full_text_match: match_options[:min_full_text_match] && trimmed_text.size >= match_options[:min_full_text_match]
    }
  end

  def detect_script_type (text)
    if text =~ /\p{Han}/
      {
        type: :ideographic,
        min_prefix_match: 1,
        min_full_text_match: 1
      }
    elsif text =~ /\p{Arab}/
      {
        type: :abjad,
        min_prefix_match: 2,
        min_full_text_match: 2
      }
    elsif text =~ /\p{Hira}|\p{Kana}|\p{Hang}/
      {
        type: :syllabary,
        min_prefix_match: 2,
        min_full_text_match: nil
      }
    else
      {
        type: :default,
        min_prefix_match: 3,
        min_full_text_match: 5
      }
    end
  end
end
