FactoryGirl.define do

  factory :language do |f|
    f.name 'English'
    f.abbreviation 'E'
  end

  factory :common_name do |f|
    f.name 'Honey badger'
    f.association :language
  end

  factory :english_common_name, parent: :common_name, class: CommonName do |f|
    f.language { Language.find_by_name('English') }
  end

  factory :spanish_common_name, parent: :common_name, class: CommonName do |f|
    f.language { Language.find_by_name('Spanish') }
  end

  factory :french_common_name, parent: :common_name, class: CommonName do |f|
    f.language { Language.find_by_name('French') }
  end

end
