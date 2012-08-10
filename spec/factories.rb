#Encoding: utf-8
FactoryGirl.define do

  factory :designation do
    name 'CITES'
  end

  factory :taxon_name do
    scientific_name 'lupus'
  end

  factory :rank do
    name 'family'
  end

  factory :taxon_concept, :aliases => [:other_taxon_concept] do
    rank
    taxon_name
    data {}
    listing {}

    %w(kingdom phylum class order family genus species subspecies).each do |rank_name|
      factory :"#{rank_name}" do
        designation { Designation.find_by_name('CITES') }
        rank { Rank.find_by_name(rank_name.upcase) }
      end
    end

  end

  factory :reference do
    author 'Bolek'
    title 'Przygód kilka wróbla ćwirka'
  end

end
