FactoryGirl.define do

  factory :geo_relationship_type do
    sequence(:name) { |n| "CONTAINS#{n}" }
  end

  factory :geo_relationship do
    geo_relationship_type
    geo_entity
    related_geo_entity
  end

  factory :geo_entity_type do
    name 'COUNTRY'
  end

  factory :geo_entity, :aliases => [:related_geo_entity, :trading_country, :importer, :exporter] do
    geo_entity_type
    name_en 'Wonderland'
    sequence(:iso_code2) { |n| [n, n + 1].map { |i| (65 + i % 26).chr }.join }
    is_current true
  end

  factory :distribution do
    taxon_concept
    geo_entity
  end

end
