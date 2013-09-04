#Encoding: utf-8
class Checklist::Checklist
  include ActiveModel::SerializerSupport
  include ActionView::Helpers::TextHelper
  attr_accessor :taxon_concepts_rel, :taxon_concepts, :animalia, :plantae,
  :authors, :synonyms, :synonyms_with_authors, :english_names, :spanish_names, :french_names, :total_cnt

  # Constructs a query to retrieve CITES listed taxon concepts based on user
  # defined parameters
  #
  # @param [Hash] a hash of search params and their values
  def initialize(options)
    initialize_params(options)
    initialize_query
  end

  def initialize_params(options)
    options = Checklist::ChecklistParams.sanitize(options)
    options.keys.each { |k| instance_variable_set("@#{k}", options[k]) }
  end

  def initialize_query
    @taxon_concepts_rel = MTaxonConcept.scoped.
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
          {:synonyms => true, :common_names => true, :subspecies => false}
        )
    end

    if @level_of_listing
      @taxon_concepts_rel = @taxon_concepts_rel.at_level_of_listing
    end

    #order
    @taxon_concepts_rel = if @output_layout == :taxonomic
      @taxon_concepts_rel.taxonomic_layout
    else
      @taxon_concepts_rel.alphabetical_layout
    end
  end

  def prepare_queries
    prepare_main_query
    prepare_kingdom_queries
  end

  def prepare_main_query; end
  def prepare_kindom_queries; end

  # Takes the current search query, paginates it and adds metadata
  #
  # @param [Integer] page the current page number to offset by
  # @param [Integer] per_page the number of results per page
  # @return [Array] an array containing a hash of search results and
  #   related metadata
  def generate(page, per_page)
    @taxon_concepts_rel = @taxon_concepts_rel.
      includes(:current_listing_changes).
      without_non_accepted.without_hidden
    page ||= 0
    per_page ||= 20
    @total_cnt = @taxon_concepts_rel.count
    @taxon_concepts_rel = @taxon_concepts_rel.limit(per_page).offset(per_page.to_i * page.to_i)
    @taxon_concepts = @taxon_concepts_rel.all
    @animalia, @plantae = @taxon_concepts.partition{ |item| item.kingdom_position == 0 }
    if @output_layout == :taxonomic
       injector = Checklist::HigherTaxaInjector.new(@animalia)
       @animalia = injector.run
       injector = Checklist::HigherTaxaInjector.new(@plantae)
       @plantae = injector.run
    end
    [self] #TODO just for compatibility with frontend, no sensible reason for this
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
      summary = ["Results from"]  if summary.length == 0

      countries = GeoEntity.find_all_by_id(@countries)

      @countries_count = countries.count
      if (1..3).include?(@countries_count)
        summary << countries.map { |c| c.name }.join(", ")
      elsif @countries_count > 3
        summary << "#{@countries_count} countries"
      end
    end

    # region
    @regions_count = 0
    unless @cites_regions.empty?
      summary = ["Results from"]  if summary.length == 0

      regions = GeoEntity.find_all_by_id(params[:cites_region_ids])

      @regions_count = regions.count
      if @regions_count > 0
        summary << "within"  if @countries_count > 0
        summary << "#{pluralize(regions.count, 'region')}" #uses ActionView::Helpers::TextHelper
      end
    end

    # appendix
    unless @cites_appendices.empty?
      summary = ["Results from"]  if summary.length == 0

      if (!@cites_regions.empty? ||
          !@countries.empty?) &&
         (@countries_count > 0 ||
          @regions_count > 0)
        summary << "on"
      end

      summary << "appx"
      summary << @cites_appendices.join(", ")
    end

    # name
    unless @scientific_name.blank?
      summary = ["Results"]  if summary.length == 0

      summary << "for '#{@scientific_name}'"
    end

    # synonyms
    if @synonyms
      if summary.length == 0
        summary << "All results including synonyms"
      else
        summary << "(showing synonyms)"
      end
    end

    #TODO common names, authors

    if summary.length > 0
      summary.join(" ")
    else
      "All results"
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

    @filename = Digest::SHA1.hexdigest(params
                                       .merge(type: type)
                                       .to_hash
                                       .symbolize_keys!
                                       .sort
                                       .to_s)

    return [Rails.root, '/public/downloads/checklist/', @filename, '.', format].join
  end

end
