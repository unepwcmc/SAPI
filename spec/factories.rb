FactoryGirl.define do

  factory :taxon_name do |f|
    f.scientific_name 'lupus'
  end

  factory :taxon_concept do |f|
    f.association :designation
    f.association :rank
    f.association :taxon_name
    f.data {}
    f.listing {}
  end

  %w(kingdom phylum class order family genus species subspecies).each do |rank_name|
    factory :"#{rank_name}", parent: :taxon_concept, class: TaxonConcept do |f|
      f.designation { Designation.find_by_name('CITES') }
      f.rank { Rank.find_by_name(rank_name.upcase) }
    end
  end

end
