FactoryGirl.define do

  factory :language do
    sequence(:name_en) { |n| "lng#{n}" }
    sequence(:iso_code1) { |n| "#{n.chr}#{(n+1).chr}" }
  end

  factory :common_name do
    name 'Honey badger'
    association :language

    ['English', 'Spanish', 'French'].each do |lng|
      factory :"#{lng.downcase}_common_name" do
        language { Language.find_by_name_en(lng) }
      end
    end

  end

end
