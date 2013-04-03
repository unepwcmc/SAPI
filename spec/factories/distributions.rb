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
    name 'Country'
  end

  factory :geo_entity, :aliases => [:related_geo_entity] do
    geo_entity_type
    name 'Wonderland'
    sequence(:iso_code2) {|n| "#{n}X"}
  end

  factory :distribution do
    taxon_concept
    geo_entity
  end

end
