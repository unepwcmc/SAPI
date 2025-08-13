class Species::TaxonConceptSuggestSearch < Species::Search
  def results
    filtered_results = []

    @query.order(
      'length(name_for_matching) ASC'
    ).limit(@per_page * 2).order('name_for_matching').each do |row, i|
      # filter out 'panthera leo leo' if we have already seen 'panthera leo'
      seen_before =
        filtered_results.find do |existing_result|
          (" #{ row.matched_name } ").include? " #{ existing_result.matched_name } "
        end

      if !seen_before
        filtered_results.push(row)
      end
    end

    filtered_results.slice(0, @per_page)
  end

private

  def initialize_params(options)
    @options = Species::SearchParams.sanitize(options)
    @options.keys.each { |k| instance_variable_set("@#{k}", @options[k]) }
    @page = 1
    @per_page = 20
    @taxon_concept_query = @options[:taxon_concept_query]
  end

  def initialize_query
    @query = MAutoCompleteTaxonConcept.where_fuzzily_matches(
      @taxon_concept_query
    )

    @query =
      if @taxonomy == :cms
        @query.by_cms_taxonomy
      else
        @query.by_cites_eu_taxonomy
      end

    @query = self.class.apply_geo_entities_filter(
      self.class.apply_visibility_filter(
        MTaxonConcept.from(
          (
            <<-SQL.squish
              (
                SELECT ac.*, tc.countries_ids_ary, tc.show_in_species_plus, tc.name_status
                FROM taxon_concepts_mview tc
                JOIN (#{@query.to_sql}) AS ac ON ac.id = tc.id
              ) taxon_concepts_mview
            SQL
          ),
          'taxon_concepts_mview'
        ), @visibility
      ), @geo_entities, @geo_entity_scope
    )

    @query =
      MAutoCompleteTaxonConcept.from(
        <<-SQL.squish
          (
            SELECT DISTINCT name_for_matching
            FROM (
              SELECT
                DISTINCT ON(
                  matched_name, length(name_for_matching), name_for_matching
                ) matched_name, length(name_for_matching), name_for_matching
              FROM (#{@query.to_sql}) i
              ORDER BY matched_name, length(name_for_matching), name_for_matching
            ) ii
          ) iii
        SQL
      ).order_by_fuzzy_match_on(
        @taxon_concept_query
      ).select('lower(name_for_matching) AS matched_name')

    @query
  end
end
