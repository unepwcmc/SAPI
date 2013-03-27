FactoryGirl.define do

  factory :language do
    sequence(:name_en) { |n| "lng#{n}" }
    sequence(:iso_code1) { |n| "#{n.chr}#{(n+1).chr}" }
    sequence(:iso_code3) { |n| "#{n.chr}#{(n+1).chr}#{(n+1).chr}" }
  end

  factory :taxon_common do
    taxon_concept
    common_name
  end

  factory :common_name do
    name 'Honey badger'
    association :language
  end

end
