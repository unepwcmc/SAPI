#Encoding: utf-8
class Checklist
  attr_accessor :taxon_concepts_rel

  # Constructs a query to retrieve taxon concepts based on user defined
  # parameters
  #
  # @param [Hash] a hash of search params and their values
  def initialize(options)
    @designation = options[:designation] || Designation::CITES

    @taxon_concepts_rel = TaxonConcept.scoped.
      select([:"taxon_concepts.id", :"taxon_concepts.data", :"taxon_concepts.listing", :"taxon_concepts.depth"]).
      joins(:designation).
      where('designations.name' => @designation)

    #filter by geo entities
    @geo_options = []
    @geo_options += options[:country_ids] unless options[:country_ids].nil?
    @geo_options += options[:cites_region_ids] unless options[:cites_region_ids].nil?
    unless @geo_options.empty?
      @taxon_concepts_rel = @taxon_concepts_rel.by_geo_entities(@geo_options)
    end

    #filter by species listing
    unless options[:cites_appendices].nil?
      @taxon_concepts_rel = @taxon_concepts_rel.by_cites_appendices(options[:cites_appendices])
    else
      @taxon_concepts_rel = @taxon_concepts_rel.where("
        data->'rank_name' NOT IN ('SPECIES','SUBSPECIES')
        OR listing->'cites_listing' != ''
        AND listing->'cites_listing' != 'NC'
      ")
    end

    #possible output layouts are:
    #taxonomic (hierarchic, taxonomic order)
    #checklist (flat, alphabetical order)
    @output_layout = options[:output_layout] || :alphabetical
    @taxon_concepts_rel = if @output_layout == :taxonomic
      @taxon_concepts_rel.taxonomic_layout
    else
      @taxon_concepts_rel.alphabetical_layout
    end.order("taxon_concepts.data->'kingdom_name'")#animalia first

    #show synonyms?
    unless options[:synonyms].nil?
      @taxon_concepts_rel = @taxon_concepts_rel.with_synonyms
    end

    #show common names?
    unless options[:common_names].nil?
      @taxon_concepts_rel = @taxon_concepts_rel.with_common_names(options[:common_names])
    end

    #filter by scientific name
    unless options[:scientific_name].nil?
      @taxon_concepts_prev = @taxon_concepts_rel

      @taxon_concepts_rel = @taxon_concepts_rel.where("data->'full_name' ILIKE '#{options[:scientific_name]}%'")
      ids = @taxon_concepts_rel.map { |hash| hash.id }.join(', ')

      @taxon_concepts_rel = @taxon_concepts_prev.joins(
        <<-SQL
        INNER JOIN (
          WITH RECURSIVE q AS (
            SELECT h, h.id, data->'full_name' AS full_name
            FROM taxon_concepts h
            WHERE id IN (#{ids})

            UNION ALL

            SELECT hi, hi.id, data->'full_name'
            FROM q
            JOIN taxon_concepts hi
            ON hi.parent_id = (q.h).id
          ) SELECT DISTINCT id, full_name FROM q
        ) descendants ON taxon_concepts.id = descendants.id
        SQL
      ) unless ids.empty?
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
    return ""  if options.length == 0

    summary = []

    # country
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
    unless options[:synonyms].nil?
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
