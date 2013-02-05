FactoryGirl.define do

  factory :geo_entity_type do
    name 'Country'
  end

  factory :geo_entity do
    geo_entity_type
    name 'Wonderland'
    sequence(:iso_code2) {|n| "#{n}X"}

    GeoEntityType.dict.each do |type|
      factory type.downcase.to_sym do
        geo_entity_type { GeoEntityType.find_by_name(type) }
      end
    end

  end

end
