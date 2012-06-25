FactoryGirl.define do
  factory :designation do |d|
    d.name 'designation'
  end
  factory :cites_designation, parent: :designation, class: Designation do |d|
    d.name 'CITES'
  end

  factory :rank do |r|
    r.name 'rank'
  end

  factory :taxon_name do |tn|
    tn.scientific_name 'lupus'
  end

  factory :taxon_concept do |tc|
    tc.association :designation
    tc.association :rank
    tc.association :taxon_name
    tc.data {}
  end
  
  %w(kingdom phylum class order family genus species subspecies).each do |rank_name|
    factory :"#{rank_name}_rank", parent: :rank, class: Rank do |r|
      r.name rank_name.upcase
    end

    factory :"#{rank_name}", parent: :taxon_concept, class: TaxonConcept do |tc|
      tc.association :designation, factory: :cites_designation
      tc.association :rank, factory: :"#{rank_name}_rank"
    end
  end

end
