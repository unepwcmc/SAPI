FactoryGirl.define do

  factory :species_listing do
    sequence(:name) { |n| "Appendix #{n}" }
    sequence(:abbreviation) { |n| "#{n}" }
    designation
  end

  factory :change_type do
    sequence(:name) { |n| "change#{n}" }
    display_name_en { name }
    designation
  end

  factory :listing_change do
    species_listing
    change_type
    taxon_concept
    effective_at '2012-01-01'
    parent_id nil
  end

  factory :listing_distribution do
    geo_entity
    is_party true
  end

  factory :annotation, :aliases => [:hash_annotation] do
    symbol '#4'
    parent_symbol 'CoP15'
    short_note_en "I'm a short note"
    full_note_en "I'm a long note"
    display_in_index false
    display_in_footnote false
  end

end
