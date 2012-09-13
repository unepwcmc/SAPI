#Encoding: utf-8
class Checklist
  attr_accessor :taxon_concepts_rel

  # Constructs a query to retrieve taxon concepts based on user defined
  # parameters
  #
  # @param [Hash] a hash of search params and their values
  def initialize(options)
    @params = options
    #possible output layouts are:
    #taxonomic (hierarchic, taxonomic order)
    #checklist (flat, alphabetical order)
    @output_layout = options[:output_layout] || :alphabetical
    @designation = options[:designation] || Designation::CITES

    @taxon_concepts_rel = TaxonConcept.scoped.
      select([:"taxon_concepts.id", :"taxon_concepts.data", :"taxon_concepts.listing", :"taxon_concepts.depth"]).
      by_designation(@designation).without_nc.
      with_countries_ids.with_history

    #filtering options
    @cites_regions = options[:cites_region_ids] || []
    @countries = options[:country_ids] || []
    @cites_appendices = options[:cites_appendices] || []
    @scientific_name = options[:scientific_name]

    unless @cites_regions.empty? && @countries.empty?
      @taxon_concepts_rel = @taxon_concepts_rel.by_cites_regions_and_countries(@cites_regions, @countries)
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
  def summarise_filters
    # Remove empty and nil params
    @params = @params.delete_if { |_, v| v.nil? || v == "" }
    return ""  if @params.length == 0

    @params = @params.symbolize_keys

    summary = []

    # country
    @countries_count = 0
    unless @params[:country_ids].nil?
      summary = ["Results from"]  if summary.length == 0

      countries = GeoEntity.find_all_by_id(@params[:country_ids])

      @countries_count = countries.count
      if (1..3).include?(@countries_count)
        summary << countries.map { |c| c.name }.join(", ")
      elsif @countries_count > 3
        summary << "#{@countries_count} countries"
      end
    end

    # region
    @regions_count = 0
    unless @params[:cites_region_ids].nil?
      summary = ["Results from"]  if summary.length == 0

      regions = GeoEntity.find_all_by_id(@params[:cites_region_ids])

      @regions_count = regions.count
      if @regions_count > 0
        summary << "within"  if @countries_count > 0
        summary << "#{Checklist.helpers.pluralize(regions.count, 'region')}"
      end
    end

    # appendix
    unless @params[:cites_appendices].nil?
      summary = ["Results from"]  if summary.length == 0

      if (!@params[:cites_region_ids].nil? ||
          !@params[:country_ids].nil?) &&
         (@countries_count > 0 ||
          @regions_count > 0)
        summary << "on"
      end

      summary << "appx"
      summary << @params[:cites_appendices].join(", ")
    end

    # name
    unless @params[:scientific_name].nil?
      summary = ["Results"]  if summary.length == 0

      summary << "for '#{@params[:scientific_name]}'"
    end

    # synonyms
    unless @params[:synonyms].nil? || @params[:synonyms] == false
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
