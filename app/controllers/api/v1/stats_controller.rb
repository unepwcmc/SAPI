class Api::V1::StatsController < ApplicationController

  def index
    iso_code = params['iso_code']
    geo_entity = GeoEntity.where(:iso_code2 => iso_code).first
    species_classes = [
      "Actinopterygii", 
      "Amphibia",
      "Anthozoa",
      "Arachnida",
      "Aves",
      "Bivalvia",
      "Elasmobranchii",
      "Gastropoda",
      "Hirudinoidea",
      "Holothuroidea",
      "Hydrozoa",
      "Insecta",
      "Mammalia",
      "Reptilia",
      "Sarcopterygii"
    ]

    results = {}
    
    species_results = {}
    [:cites_eu, :cms].each do |taxonomy|
      species_results[taxonomy] = []
      species_classes.each do |species_class|
        params = {
          :taxonomy => taxonomy.to_s, 
          :taxon_concept_query => species_class,
          :geo_entities_ids => ["#{geo_entity.id}"] 
        }
        search = Species::Search.new(params)
        result = { 
          :name => species_class,
          :count => search.cached_total_cnt
        }
        species_results[taxonomy] << result
      end
    end
    results['species_results'] = species_results

    trade_results = {}
    exports = Trade::Shipment.where(
      :importer_id => iso_code
    ).count
    trade_results['exports'] = exports
    imports = Trade::Shipment.where(
      :exporter_id => iso_code
    ).count
    trade_results['imports'] = imports
    results['trade_results'] = trade_results

    render :json => results
  end

end