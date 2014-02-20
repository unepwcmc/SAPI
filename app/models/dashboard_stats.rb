class DashboardStats

  include ActiveModel::Serializers::JSON

  attr_reader :geo_entity, :kingdom, :trade_limit

  def initialize (geo_entity, kingdom='Animalia', trade_limit=5)
    @kingdom = kingdom
    @trade_limit = trade_limit
    @geo_entity = geo_entity
  end

  def get_species_classes taxonomy
    taxonomy_id = Taxonomy.where(:name => taxonomy.upcase).select('id').first
    MTaxonConcept.where(
      :rank_name => 'CLASS', :kingdom_name => @kingdom, :taxonomy_id => taxonomy_id).
      select([:class_name, :english_names_ary]).uniq.
      map do |s| 
        {:name => s.class_name, :common_name_en => s.english_names.first}
      end
  end

  def species
    species_results = []
    get_species_classes(:cites_eu).each do |species_class|
      search = MTaxonConcept.where(
        "cites_listed IS NOT NULL
        AND class_name = '#{species_class[:name]}'
        AND countries_ids_ary && ARRAY[#{@geo_entity.id}]")
      result = { 
        :name => species_class[:name],
        :common_name_en => species_class[:common_name_en],
        :count => search.count
      }
      species_results << result
    end
    species_results
  end

  def trade
    trade_results = {}
    trade_results[:exports] = get_trade_stats 'exports'
    trade_results[:imports] = get_trade_stats 'imports'
    trade_results
  end

  def meta 
    {
      :trade => {   
        :country_of_origin_id => nil,
        :term => "LIV",
        :unit => nil,
        :source => "W"
      },
      :species => {
        :cites_listed => 'IS NOT NULL'
      }
    }
  end

  private

  def get_trade_stats trade_type
    hash = {:top_traded => []}
    geo_id = trade_type == "exports" ? :exporter_id : :importer_id
    totals = Trade::ShipmentView.where(
      geo_id => @geo_entity.id,
      :country_of_origin_id => nil,
      :term => "LIV",
      :unit => nil,
      :source => "W"
    ).count
    hash[:totals] = totals
    tops = Trade::ShipmentView.
      select("taxon_concept_id, count(*) as count_all").
      where(
        geo_id => @geo_entity.id,
        :country_of_origin_id => nil,
        :term => "LIV",
        :unit => nil,
        :source => "W"
      ).
      group(:taxon_concept_id).
      order("count_all desc").
      limit(@trade_limit)
    tops.each do |top|
      taxon_concept = MTaxonConcept.find(top.taxon_concept_id)
      top_traded = {
        :name => taxon_concept[:full_name],
        :common_name_en => taxon_concept.english_names.first,
        :count => top.count_all.to_i
      }
      hash[:top_traded] << top_traded
    end
    hash
  end 

end