FactoryGirl.define do

  factory :language do
    name 'English'
    abbreviation 'E'
  end

  factory :common_name do
    name 'Honey badger'
    association :language

    ['English', 'Spanish', 'French'].each do |lng|
      factory :"#{lng.downcase}_common_name" do
        language { Language.find_by_name(lng) }
      end
    end

  end

end
