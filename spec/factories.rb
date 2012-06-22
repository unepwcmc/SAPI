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
  factory :genus_rank, parent: :rank, class: Rank do |r|
    r.name 'GENUS'
  end
  factory :species_rank, parent: :rank, class: Rank do |r|
    r.name 'SPECIES'
  end
  factory :subspecies_rank, parent: :rank, class: Rank do |r|
    r.name 'SUBSPECIES'
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
  factory :genus, parent: :taxon_concept, class: TaxonConcept do |tc|
    tc.association :designation, factory: :cites_designation
    tc.association :rank, factory: :genus_rank
  end
  factory :species, parent: :taxon_concept, class: TaxonConcept do |tc|
    tc.association :designation, factory: :cites_designation
    tc.association :rank, factory: :species_rank
  end
  factory :subspecies, parent: :taxon_concept, class: TaxonConcept do |tc|
    tc.association :designation, factory: :cites_designation
    tc.association :rank, factory: :subspecies_rank
  end
end
