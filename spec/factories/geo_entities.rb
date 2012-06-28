FactoryGirl.define do

  factory :geo_entity_type do |f|
    f.name 'Country'
  end

  factory :geo_entity do |f|
    f.association :geo_entity_type
    f.name 'Wonderland'
    f.iso_code2 'XX'
  end

  GeoEntityType.dict.each do |type|
    factory type.downcase.to_sym, parent: :geo_entity, class: GeoEntity do |f|
      f.geo_entity_type { GeoEntityType.find_by_name(type) }
    end
  end

end