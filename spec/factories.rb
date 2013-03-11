#Encoding: utf-8
FactoryGirl.define do

  factory :taxonomy do
    sequence(:name) {|n| "WILDLIFE#{n}"}
  end

  factory :designation do
    sequence(:name) {|n| "CITES#{n}"}
    taxonomy
  end

  factory :event do
    sequence(:name) {|n| "CoP#{n}"}
    effective_at '2012-01-01'
    designation

    factory :eu_regulation, :class => EuRegulation
    factory :cites_cop, :class => CitesCop
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

  factory :preset_tag do
    name 'Extinct'
    model 'TaxonConcept'
  end

end
