class DashboardStats

  include ActiveModel::Serializers::JSON

  attr_reader :geo_entity, :kingdom, :time_range_start, :time_range_end,
    :trade_limit

  def initialize(geo_entity, options)
    @geo_entity = geo_entity
    @kingdom = options[:kingdom] || 'Animalia'
    @trade_limit = options[:trade_limit]
    @time_range_start = options[:time_range_start] || (Time.now.year - 7) # 2007
    @time_range_end = options[:time_range_end] || (Time.now.year - 2) # 2012
  end

  def species
    {
      :cites_eu => species_stats_per_taxonomy(Taxonomy::CITES_EU),
      :cms => species_stats_per_taxonomy(Taxonomy::CMS)
    }
  end

  def trade
    {
      :exports => trade_stats_per_reporter_type(:exporter),
      :imports => trade_stats_per_reporter_type(:importer)
    }
  end

  private

  def species_stats_per_taxonomy(taxonomy_name)
    taxonomy = Taxonomy.find_by_name(taxonomy_name)
    classes = taxonomy && MTaxonConcept.where(
      :taxonomy_id => taxonomy.id,
      :rank_name => Rank::CLASS,
      :kingdom_name => @kingdom
    )
    designation_name = (taxonomy_name == Taxonomy::CMS ? :cms : :cites)
    classes && classes.map do |klass|
      cnt = MTaxonConcept.where(:class_id => klass.id).
        where("countries_ids_ary && ARRAY[#{@geo_entity.id}]").
        where("#{designation_name}_listed IS NOT NULL").count
      {
        :name => klass.full_name,
        :common_name_en => klass.english_names.first,
        :count => cnt
      }
    end || []
  end

  def trade_stats_per_reporter_type(reporter_type)
    source = Source.find_by_code('W')
    term = Term.find_by_code('LIV')
    purpose = Purpose.find_by_code('T')
    shipments_for_country = Trade::Shipment.where(
      :country_of_origin_id => nil,
      :term_id => term.id,
      :unit_id => nil,
      :source_id => source.id,
      :purpose_id => purpose.id,
      :"#{reporter_type}_id" => @geo_entity.id,
      :reported_by_exporter => (reporter_type == :exporter)
    )

    if @time_range_start && @time_range_end &&
      @time_range_start <= @time_range_end
      shipments_for_country = shipments_for_country.where(
        ["year >= ? AND year <= ?", @time_range_start, @time_range_end]
      )
    end

    top_traded_taxa_for_country = shipments_for_country.
      joins(<<-SQL
        JOIN taxon_concepts_mview tc
        ON tc.id = trade_shipments.taxon_concept_id
        AND kingdom_name = '#{@kingdom}'
        AND cites_listed IS NOT NULL
      SQL
      ).
      includes(:m_taxon_concept).
      select("taxon_concept_id, sum(quantity) as count_all").
      group(:taxon_concept_id).
      order("count_all desc").
      limit(@trade_limit)
    {
      :totals => shipments_for_country.count,
      :top_traded => top_traded_taxa_for_country.map do |t|
        {
          :name => t.m_taxon_concept.full_name,
          :common_name_en => t.m_taxon_concept.english_names.first,
          :count => t.count_all.to_i
        }
      end
    }
  end

end
