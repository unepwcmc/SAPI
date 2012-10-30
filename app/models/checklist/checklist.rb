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
    #possible output layouts are:
    #taxonomic (hierarchic, taxonomic order)
    #alphabetical (flat, alphabetical order)
    @output_layout = options[:output_layout] && options[:output_layout].to_sym || :alphabetical
    @level_of_listing = (options[:level_of_listing] == '1')

    #filtering options
    @cites_regions = options[:cites_region_ids] || []
    @countries = options[:country_ids] || []
    @cites_appendices = options[:cites_appendices] || []
    @scientific_name = options[:scientific_name]

    # optional data
    @synonyms = (options[:show_synonyms] == '1')
    @authors = (options[:show_author] == '1')

    @english_common_names = (options[:show_english] == '1')
    @spanish_common_names = (options[:show_spanish] == '1')
    @french_common_names = (options[:show_french] == '1')
    @common_names =
      @english_common_names || @spanish_common_names || @french_common_names
    @locale = options[:locale] || 'en'
  end

  def initialize_query
    @taxon_concepts_rel = MTaxonConcept.scoped.
      select(sql_columns).
      by_designation(Designation::CITES)

    unless @cites_regions.empty? && @countries.empty?
      @taxon_concepts_rel = @taxon_concepts_rel.
        by_cites_regions_and_countries(@cites_regions, @countries)
    end

    unless @cites_appendices.empty?
      @taxon_concepts_rel = @taxon_concepts_rel.
        by_cites_appendices(@cites_appendices)
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

  def taxon_concepts_columns
    sql_columns = [:"taxon_concepts_mview.id", 
      :species_name, :genus_name, :family_name, :order_name,
      :class_name, :phylum_name, :kingdom_name,
      :full_name, :rank_name,
      :current_listing, :cites_accepted, :listing_updated_at,
      :specific_annotation_symbol, :generic_annotation_symbol,
      :"taxon_concepts_mview.countries_ids_ary",
      :kingdom_position, :taxonomic_position
    ]

    if @synonyms && @authors
      sql_columns << <<-SEL
    ARRAY(
      SELECT synonym || 
      CASE
      WHEN author_year IS NOT NULL
      THEN ' ' || author_year
      ELSE ''
      END
      FROM ( 
        (SELECT synonym, ROW_NUMBER() OVER() AS id FROM (SELECT * FROM UNNEST(synonyms_ary) AS synonym) q) synonyms 
        LEFT JOIN
        (SELECT author_year, ROW_NUMBER() OVER() AS id FROM (SELECT * FROM UNNEST(synonyms_author_years_ary) AS author_year) q) author_years
        ON synonyms.id = author_years.id
      )
    ) AS synonyms_ary
    SEL
    elsif @synonyms
      sql_columns << :synonyms_ary
    end

    sql_columns << :author_year if @authors
    sql_columns << :english_names_ary if @english_common_names
    sql_columns << :spanish_names_ary if @spanish_common_names
    sql_columns << :french_names_ary if @french_common_names

    if @output_layout == :taxonomic
      sql_columns += [:family_id, :order_id, :class_id, :phylum_id]
    end
    sql_columns
  end

  def listing_changes_columns
    sql_columns = [
      :change_type_name, :species_listing_name,
      :party_id, :party_name, :effective_at, :is_current,
      :"listing_changes_mview.countries_ids_ary"
    ]
    if @locale == 'en'
      sql_columns +=
        [:generic_english_full_note, :english_full_note, :english_short_note]
    elsif @locale == 'es'
      sql_columns +=
        [:generic_spanish_full_note, :spanish_full_note, :spanish_short_note]
    elsif @locale == 'fr'
      sql_columns +=
        [:generic_french_full_note, :french_full_note, :french_short_note]
    end
    sql_columns
  end

  def sql_columns
    taxon_concepts_columns + listing_changes_columns
  end

  def taxon_concepts_json_options
    json_options = {
      :only => [
        :id, :full_name, :rank_name, :current_listing, :cites_accepted,
        :species_name, :genus_name, :family_name, :order_name,
        :class_name, :phylum_name, :kingdom_name,
        :specific_annotation_symbol, :generic_annotation_symbol,
        :generic_annotation_parent_symbol
      ],
      :methods => [:countries_ids, :ancestors_path, :recently_changed]
    }

    json_options[:only] << :author_year if @authors
    json_options[:methods] << :english_names if @english_common_names
    json_options[:methods] << :spanish_names if @spanish_common_names
    json_options[:methods] << :french_names if @french_common_names
    json_options[:methods] << :synonyms if @synonyms
    json_options
  end

  def listing_changes_json_options
    json_options = {
      :only => [:id, :change_type_name, :species_listing_name,
        :party_name, :is_current],
      :methods => [:countries_ids, :effective_at_formatted]
    }
    json_options[:methods] += [:specific_note, :generic_note]

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
      joins('LEFT JOIN "listing_changes_mview"
        ON "listing_changes_mview"."taxon_concept_id" ="taxon_concepts_mview"."id"
        AND "listing_changes_mview"."is_current" = \'t\'').
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
    [{
      animalia: @animalia.as_json(json_options),
      plantae: @plantae.as_json(json_options),
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

    summary.join(" ")
  end

  private

  def self.helpers
    ActionController::Base.helpers
  end
end
