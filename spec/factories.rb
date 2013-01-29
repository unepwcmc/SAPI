#Encoding: utf-8
FactoryGirl.define do

  factory :taxonomy do
    sequence(:name) {|n| "WILDLIFE#{n}"}
  end

  factory :designation do
    sequence(:name) {|n| "CITES#{n}"}
    taxonomy
  end

  factory :taxon_name do
    sequence(:scientific_name) {|n| "lupus#{n}"}
  end

  factory :rank do
    sequence(:name) {|n| "Kingdom#{n}"}
    taxonomic_position '1'
  end

  factory :taxon_concept, :aliases => [:other_taxon_concept] do
    taxonomy
    rank
    taxon_name
    taxonomic_position '1'
    name_status 'A'
    data {}
    listing {}
    parent_scientific_name ''
    accepted_scientific_name ''
    hybrid_parent_scientific_name ''
    other_hybrid_parent_scientific_name ''

    %w(kingdom phylum class order family genus species subspecies).each do |rank_name|
      factory :"#{rank_name}" do
        taxonomy { Taxonomy.find_by_name(Taxonomy::WILDLIFE_TRADE) }
        rank { Rank.find_by_name(rank_name.upcase) }
      end
    end

  end

  #TODO use traits instead of inheritance for taxon concept ranks?

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
