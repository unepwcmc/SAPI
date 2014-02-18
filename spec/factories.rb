#Encoding: utf-8
FactoryGirl.define do

  factory :taxonomy do
    sequence(:name) {|n| "WILDLIFE#{n}"}
  end

  factory :designation do
    sequence(:name) {|n| "CITES#{n}"}
    taxonomy
  end

  factory :instrument do
    sequence(:name) {|n| "ACAP#{n}"}
    designation
  end

  factory :taxon_instrument do
    taxon_concept
    instrument
  end

  factory :event do
    sequence(:name) {|n| "CoP#{n}"}
    effective_at '2011-01-01'
    designation

    factory :eu_regulation, :class => EuRegulation do
      end_date '2012-01-01'
    end
    factory :eu_suspension_regulation, :class => EuSuspensionRegulation
    factory :cites_cop, :class => CitesCop
    factory :cites_suspension_notification, :class => CitesSuspensionNotification,
      :aliases => [:start_notification] do
      end_date '2012-01-01'
    end
  end

  factory :taxon_name do
    sequence(:scientific_name) {|n| "Lupus#{n}"}
  end

  factory :rank do
    sequence(:name) {|n| "rank#{n}"}
    display_name_en { name }
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

  factory :cites_suspension do
    taxon_concept
    start_notification
  end

  factory :quota do
    taxon_concept
    unit
    publication_date Date.new(2012, 12, 3)
    quota '10'
  end

  factory :reference do
    citation 'Przygód kilka wróbla ćwirka'
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
    eu_decision_type
    start_date Date.new(2013,1,1)
  end

  factory :eu_decision_type do
    sequence(:name) {|n| "Opinion#{n}"}
    decision_type "NO_OPINION"
  end

  factory :eu_opinion do
    taxon_concept
    eu_decision_type
    start_date Date.new(2013,1,1)
  end

  factory :eu_suspension do
    taxon_concept
    eu_decision_type
    start_date Date.new(2013,1,1)
  end
end
