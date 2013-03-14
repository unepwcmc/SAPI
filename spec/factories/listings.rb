FactoryGirl.define do

  factory :species_listing do
    sequence(:name) {|n| "Appendix #{n}"}
    sequence(:abbreviation) {|n| "#{n}"}
    designation
  end

  factory :change_type do
    name 'ADDITION'
    designation
  end

  factory :listing_change do
    species_listing
    change_type
    taxon_concept
    effective_at '2012-01-01'
    #is_current false
    #inclusion_taxon_concept_id nil
    parent_id nil
  end

  factory :listing_distribution do
    geo_entity
    is_party true
  end

  [Designation::CITES, Designation::EU].each do |designation|
    factory :"#{designation}_deletion", class: ListingChange do
      change_type {
        ChangeType.find_by_name_and_designation_id(
          'DELETION', Designation.find_by_name(designation).id
        )
      }
      taxon_concept
    end
  end

  %w(I II III).each do |a|
    factory :"cites_#{a}_listing_change", parent: :listing_change, class: ListingChange do
      species_listing { SpeciesListing.find_by_abbreviation(a) }
    end
    %w(ADDITION DELETION RESERVATION RESERVATION_WITHDRAWAL EXCEPTION).each do |ch|
      factory :"cites_#{a}_#{ch.downcase}", parent: :"cites_#{a}_listing_change", class: ListingChange do
        change_type {
          ChangeType.find_by_name_and_designation_id(
            ch,
            Designation.find_by_name('CITES').id
          )
        }
      end
    end
  end

  %w(A B C D).each do |a|
    factory :"eu_#{a}_listing_change", parent: :listing_change, class: ListingChange do
      species_listing { SpeciesListing.find_by_abbreviation(a) }
    end
    %w(ADDITION DELETION RESERVATION RESERVATION_WITHDRAWAL EXCEPTION).each do |ch|
      factory :"eu_#{a}_#{ch.downcase}", parent: :"eu_#{a}_listing_change", class: ListingChange do
        change_type {
          ChangeType.find_by_name_and_designation_id(
            ch,
            Designation.find_by_name('EU').id
          )
        }
      end
    end
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
