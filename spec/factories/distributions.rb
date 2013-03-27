FactoryGirl.define do

  factory :geo_entity_type do
    name 'Country'
  end

  factory :geo_entity do
    geo_entity_type
    name 'Wonderland'
    sequence(:iso_code2) {|n| "#{n}X"}
  end

  factory :distribution do
    taxon_concept
    geo_entity
  end

end
