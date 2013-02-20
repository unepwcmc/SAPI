#Encoding: utf-8
class Checklist::Checklist
  attr_accessor :taxon_concepts_rel, :taxon_concepts

  # Constructs a query to retrieve taxon concepts based on user defined
  # parameters
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
        @taxon_concepts_rel = @taxon_concepts_rel.
        by_cites_appendices(@cites_appendices)
      elsif !(@cites_regions.empty? && @countries.empty?)
        @taxon_concepts_rel = @taxon_concepts_rel.
          by_cites_populations_and_appendices(
            @cites_regions, @countries,
            @cites_appendices.empty? ? nil : @cites_appendices
          )
      end

    unless @scientific_name.blank?
      @taxon_concepts_rel = @taxon_concepts_rel.
        by_scientific_name(@scientific_name)
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

  def taxon_concepts_json_options
    json_options = {
      :only => [
        :id, :full_name, :rank_name, :current_listing, :cites_accepted,
        :species_name, :genus_name, :family_name, :order_name,
        :class_name, :phylum_name, :kingdom_name, :hash_ann_symbol
      ],
      :methods => [:countries_ids, :ancestors_path, :recently_changed,
        :current_parties_ids]
    }

    json_options[:only] << :author_year if @authors
    json_options[:methods] << :english_names if @english_common_names
    json_options[:methods] << :spanish_names if @spanish_common_names
    json_options[:methods] << :french_names if @french_common_names
    if @synonyms && @authors
      json_options[:methods] << :synonyms_with_authors
    elsif @synonyms
      json_options[:methods] << :synonyms
    end
    json_options
  end

  def listing_changes_json_options
    json_options = {
      :only => [:id, :change_type_name, :species_listing_name, :party_name,
        :party_id, :is_current, :symbol,
        :short_note_en, :full_note_en, :hash_full_note_en],
      :methods => [:countries_ids, :effective_at_formatted]
    }
    json_options
  end

  def json_options
    json_options = taxon_concepts_json_options
    json_options[:include] = {
      :current_listing_changes => listing_changes_json_options
    }
    json_options
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
      without_nc.without_hidden
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
    self
  end

  def as_json(options={})
    checklist_json_options = json_options
    [{
      animalia: @animalia.as_json(checklist_json_options),
      plantae: @plantae.as_json(checklist_json_options),
      result_cnt: @taxon_concepts.size,
      total_cnt: @total_cnt
    }]
  end

  # Converts a list of search filters into a limited length
  # summary of what the search covers
  #
  # e.g. Results from 4 countries on appx I or II for 'Abyssopathes'
  #
  # @param [Hash] a hash of search params and their values
  # @return [String] a summary of the search params
  def summarise_filters
    summary = []

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

      regions = GeoEntity.find_all_by_id(@params[:cites_region_ids])

      @regions_count = regions.count
      if @regions_count > 0
        summary << "within"  if @countries_count > 0
        summary << "#{Checklist::Checklist.helpers.pluralize(regions.count, 'region')}"
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

    return [Rails.root, '/public/downloads/', @filename, '.', format].join
  end

  private

  def self.helpers
    ActionController::Base.helpers
  end
end
