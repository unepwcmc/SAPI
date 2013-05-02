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

  factory :suspension do
    taxon_concept
    publication_date Date.new(2012, 12, 3)
  end

  factory :trade_code do
    factory :source, :class => Source do
      sequence(:code) { |n| (65 + n%26).chr }
      name_en "Wild"
    end

    factory :purpose, :class => Purpose do
      sequence(:code) { |n| (65 + n%26).chr }
      name_en "Zoo"
    end

    factory :term, :class => Term do
      sequence(:code) { |n| [n, n+1, n+2].map{ |i|  (65 + i%26).chr }.join }
      name_en "Bones"
    end

    factory :unit, :class => Unit do
      sequence(:code) { |n| [n, n+1, n+2].map{ |i|  (65 + i%26).chr }.join }
      name_en "Boxes"
    end
  end

  factory :quota do
    taxon_concept
    unit
    publication_date Date.new(2012, 12, 3)
    quota '10'
  end

  factory :reference do
    author 'Bolek'
    title 'Przygód kilka wróbla ćwirka'
  end

  factory :taxon_concept_reference do
    taxon_concept
    reference
  end

  factory :preset_tag do
    name 'Extinct'
    model 'TaxonConcept'
  end

  factory :eu_decision do
    taxon_concept
    restriction 'b'
    start_date Date.new(2013,1,1)
  end

  factory :eu_opinion do
    taxon_concept
    restriction 'b'
    start_date Date.new(2013,1,1)
  end

  factory :eu_suspension do
    taxon_concept
    restriction 'b'
    start_date Date.new(2013,1,1)
  end
end
