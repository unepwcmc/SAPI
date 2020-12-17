class Checklist::Checklist
  include ActiveModel::SerializerSupport
  include CacheIterator
  include SearchCache # this provides #cached_results and #cached_total_cnt
  attr_accessor :animalia, :plantae, :authors, :synonyms, :synonyms_with_authors,
  :english_common_names, :spanish_common_names, :french_common_names, :total_cnt
  attr_reader :query

  # Constructs a query to retrieve CITES listed taxon concepts based on user
  # defined parameters
  #
  # @param [Hash] a hash of search params and their values
  def initialize(options)
    initialize_params(options)
    initialize_query
  end

  def results
    @query.limit(@per_page).offset(@per_page * (@page - 1)).to_a
  end

  def total_cnt
    @query.count
  end

  def initialize_params(options)
    @options = Checklist::ChecklistParams.sanitize(options)
    @options.keys.each { |k| instance_variable_set("@#{k}", @options[k]) }
  end

  def initialize_query
    @taxon_concepts_rel = MTaxonConcept.all.
      by_cites_eu_taxonomy

    if @cites_regions.empty? && @countries.empty? && !@cites_appendices.empty?
      @taxon_concepts_rel = MTaxonConceptFilterByAppendixQuery.new(
        @taxon_concepts_rel, @cites_appendices
      ).relation
    elsif !(@cites_regions.empty? && @countries.empty?)
      @taxon_concepts_rel = MTaxonConceptFilterByAppendixPopulationQuery.new(
        @taxon_concepts_rel, @cites_appendices, @cites_regions + @countries
      ).relation
    end

    unless @scientific_name.blank?
      @taxon_concepts_rel = @taxon_concepts_rel.
        by_name(
          @scientific_name,
          { :synonyms => true, :common_names => true, :subspecies => false }
        )
    end

    if @level_of_listing
      @taxon_concepts_rel = @taxon_concepts_rel.at_level_of_listing
    end

    # order
    @taxon_concepts_rel =
      if @output_layout == :taxonomic
        @taxon_concepts_rel.taxonomic_layout
      else
        @taxon_concepts_rel.alphabetical_layout
      end

    @query = @taxon_concepts_rel.
      includes(:current_cites_additions).
      without_non_accepted.without_hidden
  end

  def prepare_queries
    prepare_main_query
    prepare_kingdom_queries
  end

  def prepare_main_query; end

  def prepare_kindom_queries; end

  # Takes the current search query and adds metadata
  # TODO: there is probably no need to return animals and plants separately
  #
  # @return [Array] an array containing a hash of search results and
  #   related metadata
  def generate
    @animalia, @plantae = cached_results.partition { |item| item.kingdom_position == 0 }
    if @output_layout == :taxonomic
      injector = Checklist::HigherTaxaInjector.new(@animalia)
      @animalia = injector.run
      injector = Checklist::HigherTaxaInjector.new(@plantae)
      @plantae = injector.run
    end
    [self] # TODO: just for compatibility with frontend, no sensible reason for this
  end

  # Converts a list of search filters into a limited length
  # summary of what the search covers
  #
  # e.g. Results from 4 countries on appx I or II for 'Abyssopathes'
  #
  # @param [Hash] a hash of search params and their values
  # @return [String] a summary of the search params
  def self.summarise_filters(params)
    summary = []

    options = Checklist::ChecklistParams.sanitize(params)
    options.keys.each { |k| instance_variable_set("@#{k}", options[k]) }

    # country
    @countries_count = 0
    unless @countries.empty?
      summary = [I18n.t('filter_summary.when_no_taxon')] if summary.empty?

      countries = GeoEntity.where(id: @countries).to_a

      @countries_count = countries.count
      if (1..3).include?(@countries_count)
        summary << countries.map { |c| c.name }.join(", ")
      elsif @countries_count > 3
        summary << "#{@countries_count} #{I18n.t('filter_summary.countries')}"
      end
    end

    # region
    @regions_count = 0
    unless @cites_regions.empty?
      summary = [I18n.t('filter_summary.when_no_taxon')] if summary.empty?

      regions = GeoEntity.where(id: params[:cites_region_ids]).to_a

      @regions_count = regions.count
      if @regions_count > 0
        summary << I18n.t('filter_summary.within_regions') if @countries_count > 0
        summary << "#{regions.count} #{'region'.pluralize(regions.count)}"
      end
    end

    # appendix
    unless @cites_appendices.empty?
      summary = [I18n.t('filter_summary.when_no_taxon')] if summary.empty?

      if (!@cites_regions.empty? ||
          !@countries.empty?) &&
         (@countries_count > 0 ||
          @regions_count > 0)
        summary << I18n.t('filter_summary.on_appx')
      else
        summary << I18n.t('filter_summary.from_appx')
      end

      summary << @cites_appendices.join(", ")
    end

    # name
    unless @scientific_name.blank?
      summary = [I18n.t('filter_summary.when_taxon')] if summary.empty?

      summary << "'#{@scientific_name}'"
    end

    # synonyms
    if @synonyms
      if summary.empty?
        summary << I18n.t('filter_summary.all_with_synonyms')
      else
        summary << I18n.t('filter_summary.with_synonyms')
      end
    end

    # TODO: common names, authors

    if !summary.empty?
      summary.join(" ")
    else
      I18n.t('filter_summary.all')
    end
  end

  # Returns a file path where a download can be stored.
  #
  # Used in Checklist::[Pdf|Csv]::[History|Index] to handle cached file
  # names. A digest of the user's provided params and the document type
  # is generated and used as the filename prior to any processing, so
  # already generated documents are simply returned.
  #
  # @returns String download file path, including filename and ext
  def download_location(params, type, format)
    require 'digest/sha1'

    params.delete(:action)
    params.delete(:controller)

    @filename = Digest::SHA1.hexdigest(
      params.
      merge(type: type).
      merge(locale: I18n.locale).
      to_hash.
      symbolize_keys!.
      sort.
      to_s
    )

    return [Rails.root, '/public/downloads/checklist/', @filename, '.', format].join
  end

end
