#Encoding: utf-8
class Checklist
  attr_accessor :taxon_concepts_rel

  # Constructs a query to retrieve taxon concepts based on user defined
  # parameters
  #
  # @param [Hash] a hash of search params and their values
  def initialize(options)

    #possible output layouts are:
    #taxonomic (hierarchic, taxonomic order)
    #checklist (flat, alphabetical order)
    @output_layout = options[:output_layout] || :alphabetical
    @designation = options[:designation] || Designation::CITES

    @taxon_concepts_rel = TaxonConcept.scoped.
      select([:"taxon_concepts.id", :"taxon_concepts.data", :"taxon_concepts.listing", :"taxon_concepts.depth"]).
      by_designation(@designation).without_nc(@output_layout)

    #filtering options
    @geo_entities = [
      options[:country_ids], options[:cites_region_ids]
    ].compact

    @cites_appendices = options[:cites_appendices] || []
    @scientific_name = options[:scientific_name]



    unless @geo_entities.empty?
      @taxon_concepts_rel = @taxon_concepts_rel.by_geo_entities(@geo_entities)
    end

    unless @cites_appendices.empty?
      @taxon_concepts_rel = @taxon_concepts_rel.
        by_cites_appendices(@cites_appendices)
    end

    unless @scientific_name.blank?
      @taxon_concepts_rel = @taxon_concepts_rel.
        by_scientific_name(@scientific_name)
    end

    # optional data
    unless options[:synonyms].nil? || options[:synonyms] == false
      @synonyms = true
      @taxon_concepts_rel = @taxon_concepts_rel.with_synonyms
    end

    unless options[:common_names].nil?
      @common_names = true
      @taxon_concepts_rel = @taxon_concepts_rel.with_common_names(options[:common_names])
    end

      #order
     @taxon_concepts_rel = @taxon_concepts_rel.order("taxon_concepts.data->'kingdom_name'")#animalia first
     @taxon_concepts_rel = if @output_layout == :taxonomic
      @taxon_concepts_rel.taxonomic_layout
    else
      @taxon_concepts_rel.alphabetical_layout
    end

  end

  # Takes the current search query, paginates it and adds metadata
  #
  # @param [Integer] page the current page number to offset by
  # @param [Integer] per_page the number of results per page
  # @return [Array] an array containing a hash of search results and
  #   related metadata
  def generate(page, per_page)
    page ||= 0
    per_page ||= 50
    total_cnt = @taxon_concepts_rel.count
    @taxon_concepts_rel = @taxon_concepts_rel.limit(per_page).offset(per_page.to_i * page.to_i)
    [{
      :taxon_concepts => @taxon_concepts_rel.all,
      :animalia_idx => 0,
      :plantae_idx => @taxon_concepts_rel.
        where("taxon_concepts.data->'kingdom_name' = 'Animalia'").count,
      :result_cnt => @taxon_concepts_rel.count,
      :total_cnt => total_cnt
    }]
  end

  # Converts a list of search filters into a limited length
  # summary of what the search covers
  #
  # e.g. Results from 4 countries on appx I or II for 'Abyssopathes'
  #
  # @param [Hash] a hash of search params and their values
  # @return [String] a summary of the search params
  def self.summarise_filters(options)
    # Remove empty and nil params
    options = options.delete_if { |_, v| v.nil? || v == "" }
    return ""  if options.length == 0

    options = options.symbolize_keys

    summary = []

    # country
    @countries_count = 0
    unless options[:country_ids].nil?
      summary = ["Results from"]  if summary.length == 0

      countries = GeoEntity.find_all_by_id(options[:country_ids])

      @countries_count = countries.count
      if (1..3).include?(@countries_count)
        summary << countries.map { |c| c.name }.join(", ")
      elsif @countries_count > 3
        summary << "#{@countries_count} countries"
      end
    end

    # region
    @regions_count = 0
    unless options[:cites_region_ids].nil?
      summary = ["Results from"]  if summary.length == 0

      regions = GeoEntity.find_all_by_id(options[:cites_region_ids])

      @regions_count = regions.count
      if @regions_count > 0
        summary << "within"  if @countries_count > 0
        summary << "#{helpers.pluralize(regions.count, 'region')}"
      end
    end

    # appendix
    unless options[:cites_appendices].nil?
      summary = ["Results from"]  if summary.length == 0

      if (!options[:cites_region_ids].nil? ||
          !options[:country_ids].nil?) &&
         (@countries_count > 0 ||
          @regions_count > 0)
        summary << "on"
      end

      summary << "appx"
      summary << options[:cites_appendices].join(", ")
    end

    # name
    unless options[:scientific_name].nil?
      summary = ["Results"]  if summary.length == 0

      summary << "for '#{options[:scientific_name]}'"
    end

    # synonyms
    unless options[:synonyms].nil? || options[:synonyms] == false
      if summary.length == 0
        summary << "All results including synonyms"
      else
        summary << "(showing synonyms)"
      end
    end

    summary.join(" ")
  end

  private

  def self.helpers
    ActionController::Base.helpers
  end
end
