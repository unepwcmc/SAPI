class Species::TaxonConceptSuggestSearch
  include CacheIterator
  include SearchCache # this provides #cached_results and #cached_total_cnt
  attr_reader :page, :per_page

  def initialize(options)
    initialize_params(options)
    initialize_query
  end

  def results
    @query.limit(@per_page).to_a
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

    if @visibility == :speciesplus
      @query = @query.where(show_in_species_plus: true)
    elsif @visibility == :elibrary
      @query = @query.where("show_in_species_plus OR name_status = 'N'")
    end

    @query = MAutoCompleteTaxonConcept.from(
      "(#{@query.to_sql}) AS auto_complete_taxon_concept_mview"
    ).select('DISTINCT matched_name')

    @query
  end
end
