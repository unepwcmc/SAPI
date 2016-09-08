FactoryGirl.define do

  factory :language do
    sequence(:name_en) { |n| "lng#{n}" }
    sequence(:iso_code1) { |n| [n, n + 1].map { |i| (65 + i % 26).chr }.join }
    sequence(:iso_code3) { |n| [n, n + 1, n + 2].map { |i| (65 + i % 26).chr }.join }
  end

  factory :taxon_common do
    taxon_concept
    common_name
  end

  factory :common_name do
    language
    sequence(:name) { |n| "Honey badger #{n}" }
  end

end
