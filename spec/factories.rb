FactoryGirl.define do

  factory :user do
    sequence(:name) { |n| "user#{n}" }
    email { "#{name}@test.pl" }
    password 'asdfasdf'
    password_confirmation { password }
    role User::MANAGER
    is_cites_authority false
    organisation 'WCMC'
  end

  factory :taxonomy do
    sequence(:name) { |n| "WILDLIFE#{n}" }
  end

  factory :designation do
    sequence(:name) { |n| "CITES#{n}" }
    taxonomy
  end

  factory :instrument do
    sequence(:name) { |n| "ACAP#{n}" }
    designation
  end

  factory :taxon_instrument do
    taxon_concept
    instrument
  end

  factory :event do
    sequence(:name) { |n| "CoP#{n}" }
    effective_at '2011-01-01'
    published_at '2011-02-01'
    designation

    factory :eu_regulation, :class => EuRegulation do
      end_date '2012-01-01'
    end
    factory :eu_suspension_regulation, :class => EuSuspensionRegulation
    factory :eu_implementing_regulation, :class => EuImplementingRegulation
    factory :eu_council_regulation, :class => EuCouncilRegulation
    factory :cites_cop, :class => CitesCop
    factory :cites_ac, :class => CitesAc
    factory :cites_pc, :class => CitesPc
    factory :cites_tc, :class => CitesTc
    factory :cites_extraordinary_meeting, :class => CitesExtraordinaryMeeting
    factory :ec_srg, :class => EcSrg
    factory :cites_suspension_notification, :class => CitesSuspensionNotification,
      :aliases => [:start_notification] do
      end_date '2012-01-01'
    end
  end

  factory :taxon_name do
    sequence(:scientific_name) { |n| "Lupus#{n}" }
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
    geo_entity
    eu_decision_type

    factory :eu_opinion, class: EuOpinion do
      start_date Date.new(2013, 1, 1)
    end

    factory :eu_suspension, class: EuSuspension
  end

  factory :eu_decision_type do
    sequence(:name) { |n| "Opinion#{n}" }
    decision_type "NO_OPINION"
  end

  factory :ahoy_event, :class => Ahoy::Event do
    id { SecureRandom.uuid }
    user
  end

  factory :ahoy_visit, :class => Ahoy::Visit do
    id { SecureRandom.uuid }
    user
  end
end
