#!/usr/bin/ruby

require 'json'
require '../../config/environment.rb'

results = { :cites_eu => [], :cms => [] }
countries = GeoEntity.where("geo_entity_type_id = 1")

countries.each do |country|
  [:cites_eu, :cms].each do |taxonomy|
    params = {
      :taxonomy => taxonomy.to_s, :taxon_concept_query => "",
      :geo_entities_ids => ["#{country.id}"], :page => "1"
    }
    search = Species::Search.new(params)
    result = {
      :iso_2 => country.iso_code2,
      :total_listed_species => search.results.count
    }
    results[taxonomy] << result
  end
end

puts JSON.pretty_generate(results)
