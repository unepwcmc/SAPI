#Encoding: utf-8
FactoryGirl.define do

  factory :designation do
    sequence(:name) {|n| "CITES#{n}"}
  end

  factory :taxon_name do
    sequence(:scientific_name) {|n| "lupus#{n}"}
  end

  factory :rank do
    sequence(:name) {|n| "Kingdom#{n}"}
    taxonomic_position '1'
  end

  factory :taxon_concept, :aliases => [:other_taxon_concept] do
    designation
    rank
    taxon_name
    taxonomic_position '1'
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

  factory :taxon_concept_reference do
    taxon_concept
    reference
    data {}
  end

end
